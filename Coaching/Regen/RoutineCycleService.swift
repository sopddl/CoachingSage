// Coaching/Regen/RoutineCycleService.swift
// Story 3.31 — cycle de vie de fin de routine (`ProgramDurationMode.routineCyclic`).
//
// Deux responsabilités :
//   1. `renewalState(for:now:)` : calcule l'état d'une routine (notDue / due /
//      cycleCompleted) pour piloter la bannière dashboard. Pur lecture.
//   2. `renew(recordId:now:)` : génère le cycle suivant. Réutilise le MÊME record
//      (continuité de la routine) — applique le multiplier de cycle aux durées
//      des sessions, remet la complétion à zéro, repart à la semaine 1,
//      incrémente `cycleNumber` et `shiftGeneration` (invalide le journal regen
//      hebdo du cycle précédent), met à jour `adaptedAt`.
//
// Décision archi (cf doc story 3.31) : on NE re-roule PAS depuis le template via
// `ProgramAdapter`. Le record ne stocke pas l'`AdapterSportProfile`
// (équipement / contraintes type knee-injury), donc un re-roll perdrait les
// substitutions déjà appliquées. On re-scale les sessions existantes (qui
// portent déjà toutes les adaptations) — borné par `SessionVolumeScaler` [5,240]
// et autorégulé (le multiplier dérive de l'exécution du cycle écoulé).
import Foundation
import os
import TemplateModel

// MARK: - RoutineCycleService

@MainActor
protocol RoutineCycleService {
    /// État de renouvellement d'une routine. `.notApplicable` pour tout ce qui
    /// n'est pas un `routineCyclic` actif.
    func renewalState(for record: AdaptedProgramRecord, now: Date) -> RoutineRenewalState

    /// Génère le cycle suivant d'une routine et le persiste sur le même record.
    /// Idempotent : un re-entrance guard par `recordId` évite le double
    /// renouvellement (double tap / refresh concurrent). Throw si le record est
    /// introuvable ou n'est pas une routine.
    @discardableResult
    func renew(recordId: UUID, now: Date) async throws -> RoutineCycleDecision
}

enum RoutineCycleError: Error {
    case recordNotFound
    case notARoutine
}

// MARK: - DefaultRoutineCycleService

@MainActor
final class DefaultRoutineCycleService: RoutineCycleService {
    private let adaptedProgramRepository: AdaptedProgramRepository
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "routine-cycle")

    /// Re-entrance guard : recordIds en cours de renouvellement.
    private var inFlight: Set<UUID> = []

    init(adaptedProgramRepository: AdaptedProgramRepository) {
        self.adaptedProgramRepository = adaptedProgramRepository
    }

    // MARK: renewalState

    func renewalState(for record: AdaptedProgramRecord, now: Date) -> RoutineRenewalState {
        guard record.isActive, record.durationMode == .routineCyclic else {
            return .notApplicable
        }
        let sessions = record.sessions
        guard !sessions.isEmpty else { return .notApplicable }

        // Cycle dormant (jamais démarré) → rien à renouveler tant qu'il n'a pas
        // tourné. On attend le premier markStarted.
        guard let weekStart = record.weekStartDate else { return .notDue }

        let totalWeeks = sessions.map(\.weekNumber).max() ?? 0
        let currentWeek = DefaultWeeklyRegenApplicationService.currentWeekNumber(
            weekStartDate: weekStart,
            now: now
        )

        // Terminé par le temps : on a dépassé la dernière semaine du cycle.
        if currentWeek > totalWeeks {
            return .cycleCompleted(cycleNumber: record.cycleNumber)
        }

        // Terminé en avance : toutes les séances actives sont faites.
        let activeIds = Set(sessions.filter { $0.type != .rest }.map(\.id))
        if !activeIds.isEmpty {
            let activeDone = record.completionState.sessionRecords.keys.filter { activeIds.contains($0) }.count
            if activeDone >= activeIds.count {
                return .cycleCompleted(cycleNumber: record.cycleNumber)
            }
        }

        // J−14 : début de la semaine (totalWeeks − 1), soit la semaine 11 sur 12.
        if totalWeeks >= 2, currentWeek >= totalWeeks - 1 {
            return .due(cycleNumber: record.cycleNumber)
        }

        return .notDue
    }

    // MARK: renew

    @discardableResult
    func renew(recordId: UUID, now: Date) async throws -> RoutineCycleDecision {
        guard !inFlight.contains(recordId) else {
            // Renouvellement déjà en cours : no-op neutre (reconduction).
            return RoutineCycleDecision(multiplier: 1.0, reason: .maintain)
        }
        inFlight.insert(recordId)
        defer { inFlight.remove(recordId) }

        guard let record = try await adaptedProgramRepository.fetchById(recordId: recordId) else {
            throw RoutineCycleError.recordNotFound
        }
        guard record.durationMode == .routineCyclic else {
            throw RoutineCycleError.notARoutine
        }

        // Borne la complétion aux semaines déjà entamées (cf P1 review 3.31) :
        // un renouvellement J−14 ne doit pas pénaliser les 2 dernières semaines
        // pas encore dues. À cycle terminé, `elapsed == totalWeeks` → tout compte.
        let totalWeeks = record.sessions.map(\.weekNumber).max() ?? 0
        let elapsedWeeks: Int
        if let weekStart = record.weekStartDate {
            elapsedWeeks = min(
                DefaultWeeklyRegenApplicationService.currentWeekNumber(weekStartDate: weekStart, now: now),
                totalWeeks
            )
        } else {
            elapsedWeeks = totalWeeks
        }
        let decision = CycleRenewalPlanner.plan(
            sessions: record.sessions,
            completionState: record.completionState,
            elapsedWeeks: elapsedWeeks
        )

        // 1. Applique le multiplier aux durées des sessions actives (les `.rest`
        // sont épargnées). `SessionVolumeScaler` clampe à [5, 240].
        if decision.multiplier != 1.0 {
            var sessions = record.sessions
            for i in sessions.indices where sessions[i].type != .rest {
                let original = sessions[i]
                let newDuration = SessionVolumeScaler.scale(
                    durationMinutes: original.durationMinutes,
                    multiplier: decision.multiplier
                )
                guard newDuration != original.durationMinutes else { continue }
                sessions[i] = PersistedSession(
                    id: original.id,
                    weekNumber: original.weekNumber,
                    weekTheme: original.weekTheme,
                    weekGoal: original.weekGoal,
                    day: original.day,
                    name: original.name,
                    durationMinutes: newDuration,
                    type: original.type,
                    warmup: original.warmup,
                    exercises: original.exercises,
                    cooldown: original.cooldown,
                    warmupMinutes: original.warmupMinutes,
                    cooldownMinutes: original.cooldownMinutes
                )
            }
            record.sessions = sessions
        }

        // 2. Repart à neuf : complétion vidée, semaine 1 = maintenant.
        record.completionState = .empty
        record.weekStartDate = AdaptedProgramRecord.startOfCurrentWeek(now: now)
        record.adaptedAt = now

        // 3. Incrémente le cycle + invalide le journal regen hebdo du cycle
        // précédent (les entries `(recordId, week, shiftGeneration−1)` ne
        // matcheront plus → la regen hebdo repartira proprement sur le neuf).
        record.cycleNumber += 1
        record.shiftGeneration += 1

        try await adaptedProgramRepository.update(record)
        Self.logger.debug("routineCycle.renew applied cycle \(record.cycleNumber) multiplier \(decision.multiplier)")
        return decision
    }
}
