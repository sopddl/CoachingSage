// CoachingSageTests/Mocks/FakeWeeklyRegenApplicationService.swift
// Story 3.4 Phase B.4 — fake utilisé par les tests qui veulent observer l'auto-trigger
// regen (ex. SessionDashboardViewModelTests) sans dérouler la stack réelle
// (RegenInputsBuilder + HealthKit + repositories SwiftData).
//
// Track : compteur d'appels, dernier `userId`, dernier `now`, plus une closure
// `onCheckAndApply` pour observer l'ordering vis-à-vis d'autres collaborateurs
// (ex. `MockAdaptedProgramRepository.fetchActive`).
import Foundation

@MainActor
final class FakeWeeklyRegenApplicationService: WeeklyRegenApplicationService {
    private(set) var checkAndApplyCallCount = 0
    private(set) var lastUserId: UUID?
    private(set) var lastNow: Date?
    /// Closure synchrone invoquée au moment de `checkAndApplyIfDue`. Utile pour
    /// observer l'ordre des appels (ex. incrémenter un compteur partagé pour
    /// comparer avec `MockAdaptedProgramRepository.fetchActiveCallCount`).
    var onCheckAndApply: (@MainActor (UUID, Date) -> Void)?

    var checkShouldThrow: Bool = false

    func checkAndApplyIfDue(userId: UUID, now: Date) async throws {
        checkAndApplyCallCount += 1
        lastUserId = userId
        lastNow = now
        onCheckAndApply?(userId, now)
        if checkShouldThrow { throw URLError(.notConnectedToInternet) }
    }

    func applyDecision(
        _ decision: WeeklyRegenDecision,
        to record: AdaptedProgramRecord,
        userId: UUID,
        now: Date
    ) async throws -> RegenJournalEntry {
        // Pas utilisé par le wiring dashboard — la VM n'appelle que
        // `checkAndApplyIfDue`. Si un test futur en a besoin, le compléter.
        fatalError("FakeWeeklyRegenApplicationService.applyDecision not implemented")
    }
}
