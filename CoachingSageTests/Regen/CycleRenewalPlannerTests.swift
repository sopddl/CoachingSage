// CoachingSageTests/Regen/CycleRenewalPlannerTests.swift
// Story 3.31 — tests de l'algo deterministic d'autorégulation du prochain cycle
// d'une routine (complétion + RPE moyen → multiplier de volume + raison).
import XCTest
import TemplateModel

final class CycleRenewalPlannerTests: XCTestCase {

    // MARK: - Helpers

    private func makeSession(id: UUID = UUID(), type: SessionType = .endurance) -> PersistedSession {
        PersistedSession(
            id: id,
            weekNumber: 1,
            weekTheme: "t",
            weekGoal: "g",
            day: 1,
            name: "S",
            durationMinutes: 30,
            type: type,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
    }

    /// Construit un état de complétion : pour chaque session passée, un record
    /// (avec RPE optionnel). Les sessions non listées restent non complétées.
    private func completion(_ entries: [(PersistedSession, Int?)]) -> ProgramCompletionState {
        var records: [UUID: SessionCompletionRecord] = [:]
        for (session, rpe) in entries {
            records[session.id] = SessionCompletionRecord(
                completedAt: Date(timeIntervalSince1970: 1_700_000_000),
                perceivedEffort: rpe
            )
        }
        return ProgramCompletionState(sessionRecords: records)
    }

    // MARK: - Progression

    func testFullCompletionNoRPE_progresses() {
        let s = (0..<5).map { _ in makeSession() }
        let decision = CycleRenewalPlanner.plan(
            sessions: s,
            completionState: completion(s.map { ($0, nil) })
        )
        XCTAssertEqual(decision.reason, .progress)
        XCTAssertEqual(decision.multiplier, CycleRenewalPlanner.progressMultiplier)
    }

    func testHighCompletionComfortableRPE_progresses() {
        let s = (0..<5).map { _ in makeSession() }
        // 5/5 complétées, RPE moyen 4 (confortable).
        let decision = CycleRenewalPlanner.plan(
            sessions: s,
            completionState: completion(s.map { ($0, 4) })
        )
        XCTAssertEqual(decision.reason, .progress)
    }

    // MARK: - Allègement

    func testHighCompletionButHighRPE_recovers() {
        let s = (0..<5).map { _ in makeSession() }
        // Complétion parfaite mais RPE moyen 8.5 → fatigue, on allège.
        let decision = CycleRenewalPlanner.plan(
            sessions: s,
            completionState: completion(s.map { ($0, 9) })
        )
        XCTAssertEqual(decision.reason, .recover)
        XCTAssertEqual(decision.multiplier, CycleRenewalPlanner.recoverMultiplier)
    }

    func testLowCompletion_recovers() {
        let s = (0..<10).map { _ in makeSession() }
        // 3/10 = 30 % < 50 % → on allège.
        let decision = CycleRenewalPlanner.plan(
            sessions: s,
            completionState: completion(Array(s.prefix(3)).map { ($0, 5) })
        )
        XCTAssertEqual(decision.reason, .recover)
    }

    // MARK: - Reconduction

    func testMidCompletionModerateRPE_maintains() {
        let s = (0..<10).map { _ in makeSession() }
        // 7/10 = 70 %, RPE moyen 6 (ni confortable ni élevé) → reconduction.
        let decision = CycleRenewalPlanner.plan(
            sessions: s,
            completionState: completion(Array(s.prefix(7)).map { ($0, 6) })
        )
        XCTAssertEqual(decision.reason, .maintain)
        XCTAssertEqual(decision.multiplier, 1.0)
    }

    // MARK: - Edge cases

    func testRestOnlySessions_maintains() {
        let s = (0..<3).map { _ in makeSession(type: .rest) }
        let decision = CycleRenewalPlanner.plan(sessions: s, completionState: .empty)
        XCTAssertEqual(decision.reason, .maintain)
        XCTAssertEqual(decision.multiplier, 1.0)
    }

    // MARK: - elapsedWeeks scoping (P1 fix)

    func testElapsedWeeksScoping_adherentUserAtJ14Progresses() {
        // Routine 12 sem × 1 session active. Au J−14 (semaine 11), un user assidu
        // a fait les semaines 1-10. Avec scoping elapsedWeeks=11 : 10/11 = 91 %
        // → progression. Sans scoping ça plafonnerait à 10/12 = 83 % → maintain.
        var sessions: [PersistedSession] = []
        for w in 1...12 {
            sessions.append(PersistedSession(
                id: UUID(), weekNumber: w, weekTheme: "t", weekGoal: "g",
                day: 1, name: "S\(w)", durationMinutes: 30,
                type: .endurance, warmup: nil, exercises: [], cooldown: nil
            ))
        }
        let done = sessions.filter { $0.weekNumber <= 10 }.map { ($0, Int?.some(4)) }

        let scoped = CycleRenewalPlanner.plan(
            sessions: sessions, completionState: completion(done), elapsedWeeks: 11
        )
        XCTAssertEqual(scoped.reason, .progress, "10/11 semaines entamées = 91 % → progression")

        let unscoped = CycleRenewalPlanner.plan(
            sessions: sessions, completionState: completion(done) // elapsedWeeks = .max
        )
        XCTAssertEqual(unscoped.reason, .maintain, "10/12 = 83 % → reconduction (sans scoping)")
    }

    func testRestSessionsExcludedFromCompletionRate() {
        // 4 actives + 2 rest. 4/4 actives faites → complétion 100 % (les rest
        // ne comptent pas au dénominateur).
        let active = (0..<4).map { _ in makeSession() }
        let rest = (0..<2).map { _ in makeSession(type: .rest) }
        let decision = CycleRenewalPlanner.plan(
            sessions: active + rest,
            completionState: completion(active.map { ($0, 3) })
        )
        XCTAssertEqual(decision.reason, .progress)
    }
}
