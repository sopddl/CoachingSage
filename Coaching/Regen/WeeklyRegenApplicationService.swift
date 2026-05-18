// Coaching/Regen/WeeklyRegenApplicationService.swift
// Story 3.4 Phase B.2 — orchestrateur applicatif de la regen hebdo.
//
// Compose :
//   - Phase A.4 `WeeklyRegenEngine.regenerate(...)` → `WeeklyRegenDecision`
//   - Phase B.1 `AdaptedProgramRepository` + `WeeklyRegenRepository`
//   - Phase B.1 mappers `WeeklyExecutionReport+Snapshot`
//   - Phase B.2 `SessionVolumeScaler` (mutation durée), `Level.regressedForRestart`
//
// Responsabilités :
//   1. `applyDecision(...)` : applique une décision déjà calculée à un record
//      (mutation sessions S+1, persist record, écrit `RegenJournalEntry`,
//      écrit `WeeklyExecutionReportSnapshot` de S).
//   2. `checkAndApplyIfDue(userId:now:)` : orchestrateur idempotent. Pour
//      chaque programme actif du user, détermine si une regen S+1 est due
//      (semaine S close, journal `(recordId, targetWeek)` absent), demande
//      au `WeeklyRegenInputsProviding` (Phase B.3) de construire la décision,
//      puis applique. Re-entrance guard par userId.
//
// Décisions archi :
//   - Mutation `record.sessions[i].durationMinutes` via `SessionVolumeScaler`
//     pour les cas standard (`progress` / `maintain` / `reduce`). Les sessions
//     `.rest` ne sont jamais touchées.
//   - Pour `.restart` (= `requiresRebuild == true`), V1 applique multiplier 0.5
//     + rétrograde `record.level` d'un cran. Un vrai rebuild from template avec
//     re-roulage du `ProgramAdapter` est différé V2 (dépendrait du
//     `TemplateLoader` + `CoachingSportProfileRepository`, surface
//     incompatible avec le scope Phase B). Le journal porte `requiresRebuild=true`
//     pour signaler à l'UI que ce n'est pas un simple multiplier.
//   - Sources de vérité : le journal pour l'idempotence, le snapshot pour
//     l'historique PauseDetector. Les deux sont écrits dans la MÊME transaction
//     logique (séquentielle, pas de batch SwiftData — `update` puis `save`).
//   - Re-entrance guard par `userId` (pas par `recordId`) : si l'app appelle
//     `checkAndApplyIfDue` deux fois en parallèle pour le même user, le second
//     no-op silencieusement.
import Foundation
import TemplateModel

// MARK: - WeeklyRegenInputsProviding

/// Seam que Phase B.3 (`RegenInputsBuilder`) viendra remplir. Construit la
/// `WeeklyRegenDecision` à partir du contexte courant (workouts HK live,
/// rapports précédents, jours depuis dernier workout, hrMax). Retourne nil si
/// la regen ne s'applique pas (ex. semaine S inexistante, pas assez d'inputs).
@MainActor
protocol WeeklyRegenInputsProviding {
    func makeDecision(
        for record: AdaptedProgramRecord,
        analyzedWeekNumber: Int,
        now: Date
    ) async throws -> WeeklyRegenDecision?
}

// MARK: - WeeklyRegenApplicationService

@MainActor
protocol WeeklyRegenApplicationService {
    /// Orchestrateur idempotent. Itère sur les programmes actifs du user, et
    /// applique la regen S+1 sur ceux dont la semaine S est close et qui n'ont
    /// pas encore d'entrée de journal pour `(recordId, targetWeek)`.
    func checkAndApplyIfDue(userId: UUID, now: Date) async throws

    /// Applique une `WeeklyRegenDecision` à un record. Mute les sessions de S+1,
    /// persiste le record (delegated au repo), écrit le journal et le snapshot
    /// de S. **L'appelant doit avoir vérifié l'idempotence avant** (sinon il
    /// crée des doublons de journal).
    func applyDecision(
        _ decision: WeeklyRegenDecision,
        to record: AdaptedProgramRecord,
        userId: UUID,
        now: Date
    ) async throws -> RegenJournalEntry
}

// MARK: - DefaultWeeklyRegenApplicationService

@MainActor
final class DefaultWeeklyRegenApplicationService: WeeklyRegenApplicationService {
    private let adaptedProgramRepository: AdaptedProgramRepository
    private let regenRepository: WeeklyRegenRepository
    private let inputsProvider: WeeklyRegenInputsProviding

    /// Re-entrance guard. Set d'userId actuellement en train de calculer leur
    /// regen — empêche un second appel concurrent de doubler la mutation.
    private var inFlight: Set<UUID> = []

    init(
        adaptedProgramRepository: AdaptedProgramRepository,
        regenRepository: WeeklyRegenRepository,
        inputsProvider: WeeklyRegenInputsProviding
    ) {
        self.adaptedProgramRepository = adaptedProgramRepository
        self.regenRepository = regenRepository
        self.inputsProvider = inputsProvider
    }

    // MARK: checkAndApplyIfDue

    func checkAndApplyIfDue(userId: UUID, now: Date) async throws {
        guard !inFlight.contains(userId) else { return }
        inFlight.insert(userId)
        defer { inFlight.remove(userId) }

        let records = try await adaptedProgramRepository.fetchActive(for: userId)
        for record in records {
            // **Story 3.10** — programme dormant (`weekStartDate == nil`) :
            // pas de semaine close à analyser, skip silencieux.
            guard let weekStartDate = record.weekStartDate else { continue }

            let currentWeekNumber = Self.currentWeekNumber(
                weekStartDate: weekStartDate,
                now: now
            )
            // currentWeek ≤ 1 → on est encore dans S1, pas de S à analyser.
            guard currentWeekNumber >= 2 else { continue }

            let analyzedWeek = currentWeekNumber - 1
            let targetWeek = currentWeekNumber

            // **Story 3.11 AC18** — Idempotence par `(recordId, targetWeek,
            // shiftGeneration)`. Les entries d'un shiftGeneration antérieur
            // sont ignorées : un shift week invalide les regens passées et
            // permet de re-recevoir une regen sur la même `targetWeek`.
            if try await regenRepository.fetchJournal(
                recordId: record.id,
                targetWeek: targetWeek,
                shiftGeneration: record.shiftGeneration
            ) != nil {
                continue
            }

            guard let decision = try await inputsProvider.makeDecision(
                for: record,
                analyzedWeekNumber: analyzedWeek,
                now: now
            ) else { continue }

            _ = try await applyDecision(
                decision,
                to: record,
                userId: userId,
                now: now
            )
        }
    }

    // MARK: applyDecision

    func applyDecision(
        _ decision: WeeklyRegenDecision,
        to record: AdaptedProgramRecord,
        userId: UUID,
        now: Date
    ) async throws -> RegenJournalEntry {
        // 1. Mutation des sessions de S+1 (= targetWeekNumber). Les `.rest` sont
        // épargnées. `SessionVolumeScaler` clampe le résultat dans [5, 240].
        let multiplier = decision.adjustment.multiplier
        var sessions = record.sessions
        var affected: [UUID] = []

        for i in sessions.indices where sessions[i].weekNumber == decision.targetWeekNumber {
            let original = sessions[i]
            guard original.type != .rest else { continue }
            let newDuration = SessionVolumeScaler.scale(
                durationMinutes: original.durationMinutes,
                multiplier: multiplier
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
                plannedDate: original.plannedDate
            )
            affected.append(original.id)
        }
        record.sessions = sessions

        // 2. Restart → rétrograde `record.level` d'un cran (doctrine detraining).
        // Le rebuild from template proper est V2 ; en V1 on combine 0.5× + level
        // regressé, marqué `requiresRebuild=true` dans le journal pour l'UI.
        if decision.adjustment.requiresRebuild,
           let level = Level(rawValue: record.level) {
            record.level = level.regressedForRestart().rawValue
        }

        try await adaptedProgramRepository.update(record)

        // 3. Journal — trace machine-readable de la regen appliquée.
        // **Story 3.11 AC18** — porte le `shiftGeneration` courant du record
        // pour permettre la ré-application post-shift week.
        let entry = RegenJournalEntry(
            userId: userId,
            recordId: record.id,
            analyzedWeekNumber: decision.analyzedWeekNumber,
            targetWeekNumber: decision.targetWeekNumber,
            appliedAt: now,
            reason: decision.reason,
            multiplier: multiplier,
            pauseLevel: decision.pauseLevel,
            requiresRebuild: decision.adjustment.requiresRebuild,
            affectedSessionIds: affected,
            shiftGeneration: record.shiftGeneration
        )
        try await regenRepository.saveJournal(entry)

        // 4. Snapshot de S — historique pour PauseDetector des semaines suivantes.
        try await regenRepository.saveReport(
            decision.report.snapshot,
            recordId: record.id,
            userId: userId,
            sportCode: record.sportCode
        )

        return entry
    }

    // MARK: - Helpers

    /// Calcule le numéro de la semaine courante du programme depuis
    /// `weekStartDate` (= lundi 00:00 de S1). Premier ISO week = 1.
    /// `now` antérieur à `weekStartDate` → retourne 1 (on n'a pas encore démarré
    /// — cas edge où le programme vient juste d'être créé un dimanche soir).
    ///
    /// `nonisolated` car pure math Date/Calendar, pas besoin de MainActor.
    /// Évite d'imposer un contexte async à tous les call-sites helpers/tests.
    nonisolated static func currentWeekNumber(
        weekStartDate: Date,
        now: Date,
        calendar: Calendar = .current
    ) -> Int {
        let days = calendar.dateComponents([.day], from: weekStartDate, to: now).day ?? 0
        guard days >= 0 else { return 1 }
        return (days / 7) + 1
    }
}
