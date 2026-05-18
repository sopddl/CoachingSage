// Coaching/Replanify/ReplanifyService.swift
// Story 3.11 — opérations de re-planification d'un programme adapté.
//
// 2 actions exposées au caller :
//   - `reportSession(programId:sessionId:)` (AC12-13) :
//       déplace la séance en fin de semaine bloquante.
//       Si la semaine est pleine (`maxDayInWeek == 7`), fallback en 1ʳᵉ
//       position de la semaine suivante.
//   - `shiftWeek(programId:to:)` (AC15-16) :
//       décale la semaine en cours à la date choisie. Sémantique :
//       `newWeekStartDate = pickedWeekStart - (currentWeekNumber - 1) * 7j`
//       — la progression des semaines passées est préservée.
//       Incrémente `record.shiftGeneration` pour invalider l'idempotence
//       regen post-shift (cf `WeeklyRegenApplicationService`).
//
// Garde-fous AC21-22 : refuse les programmes `.routineCyclic` (throw
// `UnsupportedForRoutineMode`). L'UI ne doit pas câbler le bouton Replanifier
// pour les routines, mais on filet défensif au cas où.
import Foundation

@MainActor
protocol ReplanifyService {
    /// **AC12** — Déplace la séance courante en fin de semaine, ou en 1ʳᵉ position
    /// S+1 si débordement.
    /// Throw `ReplanifyError.programNotFound` si record introuvable.
    /// Throw `ReplanifyError.sessionNotFound` si session introuvable.
    /// Throw `ReplanifyError.unsupportedForRoutineMode` si durationMode = .routineCyclic.
    func reportSession(programId: UUID, sessionId: UUID) async throws

    /// **AC15-16** — Décale la semaine en cours à la date choisie. Calcule
    /// `newWeekStartDate` pour que la semaine courante (`currentWeekNumber`)
    /// tombe sur la `pickedWeekStart` (= lundi ISO de `date`). Incrémente
    /// `shiftGeneration`. No-op si `newWeekStartDate == record.weekStartDate`.
    /// Throw `ReplanifyError.programNotFound` si record introuvable.
    /// Throw `ReplanifyError.dormantProgram` si `weekStartDate == nil` (cas
    /// dégénéré : on ne shift pas un programme jamais démarré).
    /// Throw `ReplanifyError.unsupportedForRoutineMode` si durationMode = .routineCyclic.
    func shiftWeek(programId: UUID, to date: Date) async throws
}

enum ReplanifyError: Error, Equatable {
    case programNotFound
    case sessionNotFound
    case unsupportedForRoutineMode
    case dormantProgram
}

@MainActor
final class DefaultReplanifyService: ReplanifyService {
    private let adaptedProgramRepository: any AdaptedProgramRepository
    private let nowProvider: () -> Date
    private let calendar: Calendar

    init(
        adaptedProgramRepository: any AdaptedProgramRepository,
        nowProvider: @escaping () -> Date = Date.init,
        calendar: Calendar = DefaultReplanifyService.isoMondayCalendar()
    ) {
        self.adaptedProgramRepository = adaptedProgramRepository
        self.nowProvider = nowProvider
        self.calendar = calendar
    }

    // MARK: - reportSession

    func reportSession(programId: UUID, sessionId: UUID) async throws {
        let record = try await fetchRecord(programId: programId)
        try assertNotRoutineCyclic(record)

        guard let sessionIndex = record.sessions.firstIndex(where: { $0.id == sessionId }) else {
            throw ReplanifyError.sessionNotFound
        }

        let target = record.sessions[sessionIndex]
        let weekN = target.weekNumber
        let sameWeekDays = record.sessions
            .filter { $0.weekNumber == weekN }
            .map(\.day)
        let maxDay = sameWeekDays.max() ?? 7

        var newSessions = record.sessions
        if maxDay < 7 {
            // Glisse en fin de semaine bloquante.
            newSessions[sessionIndex] = PersistedSession(
                id: target.id,
                weekNumber: target.weekNumber,
                weekTheme: target.weekTheme,
                weekGoal: target.weekGoal,
                day: maxDay + 1,
                name: target.name,
                durationMinutes: target.durationMinutes,
                type: target.type,
                warmup: target.warmup,
                exercises: target.exercises,
                cooldown: target.cooldown
            )
        } else {
            // Fallback S+1, day=1 (AC12 reco B).
            newSessions[sessionIndex] = PersistedSession(
                id: target.id,
                weekNumber: target.weekNumber + 1,
                weekTheme: target.weekTheme,
                weekGoal: target.weekGoal,
                day: 1,
                name: target.name,
                durationMinutes: target.durationMinutes,
                type: target.type,
                warmup: target.warmup,
                exercises: target.exercises,
                cooldown: target.cooldown
            )
        }
        record.sessions = newSessions
        record.lastUpdatedAt = nowProvider()
        try await adaptedProgramRepository.update(record)
    }

    // MARK: - shiftWeek

    func shiftWeek(programId: UUID, to date: Date) async throws {
        let record = try await fetchRecord(programId: programId)
        try assertNotRoutineCyclic(record)

        guard let currentWeekStart = record.weekStartDate else {
            throw ReplanifyError.dormantProgram
        }

        // **AC16** — calcule `pickedWeekStart` = lundi de la semaine ISO de `date`.
        let pickedWeekStart = startOfWeek(for: date)
        // currentWeekNumber AVANT mutation.
        let currentWeek = max(1, NextSessionResolver.currentWeekNumber(
            weekStartDate: currentWeekStart,
            now: nowProvider(),
            calendar: calendar
        ))
        // `newWeekStartDate = pickedWeekStart - (currentWeek - 1) * 7j`.
        let offsetDays = (currentWeek - 1) * 7
        let newWeekStartDate = calendar.date(
            byAdding: .day,
            value: -offsetDays,
            to: pickedWeekStart
        ) ?? pickedWeekStart

        // **AC16.4** — no-op si on retombe sur la même semaine ISO.
        if calendar.isDate(newWeekStartDate, inSameDayAs: currentWeekStart) {
            return
        }

        record.weekStartDate = newWeekStartDate
        record.shiftGeneration += 1
        record.lastUpdatedAt = nowProvider()
        try await adaptedProgramRepository.update(record)
    }

    // MARK: - Helpers

    private func fetchRecord(programId: UUID) async throws -> AdaptedProgramRecord {
        guard let record = try await adaptedProgramRepository.fetchById(recordId: programId) else {
            throw ReplanifyError.programNotFound
        }
        return record
    }

    private func assertNotRoutineCyclic(_ record: AdaptedProgramRecord) throws {
        if record.durationMode == .routineCyclic {
            throw ReplanifyError.unsupportedForRoutineMode
        }
    }

    private func startOfWeek(for date: Date) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps) ?? date
    }

    /// Calendar ISO firstWeekday=2 (lundi). Helper statique pour cohérence avec
    /// `AdaptedProgramRecord.startOfCurrentWeek`. `nonisolated` pour pouvoir
    /// servir de valeur par défaut dans l'`init`.
    nonisolated static func isoMondayCalendar() -> Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2
        return cal
    }
}

