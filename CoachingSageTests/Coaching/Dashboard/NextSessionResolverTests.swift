// CoachingSageTests/Coaching/Dashboard/NextSessionResolverTests.swift
// Tests paramétriques tri prochaine séance :
//   - per-program planned + deadline : blocage doux Story 3.11 + tri (weekNumber, day)
//   - per-program ondemand : retourne la 1re session non complétée (ordre week/day)
//   - completion : skip les sessions déjà dans completionState
//   - multi-prog : effectiveDate = now toujours → tie-break ordre alphabétique sport
//
// Depuis la refonte vue semaine (Story 3.12), les sessions n'ont plus de
// `plannedDate` — l'`effectiveDate` retournée par le resolver est toujours `now`.
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class NextSessionResolverTests: XCTestCase {

    private let resolver = NextSessionResolver()
    private let now = Date(timeIntervalSince1970: 1_700_000_000) // mardi 14 nov 2023 22:13 UTC

    // MARK: - Per-program — ondemand mode

    func testOndemandReturnsFirstUncompletedByWeekDayOrder() {
        let s1 = makeSession(weekNumber: 1, day: 1)
        let s2 = makeSession(weekNumber: 1, day: 2)
        let s3 = makeSession(weekNumber: 2, day: 1)
        let record = makeRecord(mode: .ondemand, sessions: [s3, s1, s2]) // pas dans l'ordre

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s1.id)
        XCTAssertEqual(result?.effectiveDate, now)
    }

    func testOndemandSkipsCompletedSessions() {
        let s1 = makeSession(weekNumber: 1, day: 1)
        let s2 = makeSession(weekNumber: 1, day: 2)
        let record = makeRecord(
            mode: .ondemand,
            sessions: [s1, s2],
            completed: [s1.id]
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s2.id)
    }

    // MARK: - Per-program — planned mode + routineCyclic

    func testPlannedRoutineCyclicReturnsFirstUncompletedByWeekDayOrder() {
        let s1 = makeSession(weekNumber: 1, day: 1)
        let s2 = makeSession(weekNumber: 1, day: 2)
        let s3 = makeSession(weekNumber: 2, day: 1)
        let record = makeRecord(
            mode: .planned,
            sessions: [s3, s1, s2],
            durationMode: .routineCyclic
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s1.id)
        XCTAssertEqual(result?.effectiveDate, now)
    }

    // MARK: - Multi-program

    func testNextSessionAcrossTieBreakOnSportCodeAlphabetical() {
        // Tous les programmes ont effectiveDate = now → tie-break alphabétique sport.
        let progRunning = makeRecord(
            sportCode: "running",
            mode: .ondemand,
            sessions: [makeSession(weekNumber: 1, day: 1)]
        )
        let progCycling = makeRecord(
            sportCode: "cycling",
            mode: .ondemand,
            sessions: [makeSession(weekNumber: 1, day: 1)]
        )

        let result = resolver.nextSession(across: [progRunning, progCycling], now: now)

        XCTAssertEqual(result?.program.sportCode, "cycling") // c < r
    }

    func testNextSessionAcrossReturnsNilWhenAllDormant() {
        let prog = makeRecord(
            mode: .ondemand,
            sessions: [makeSession(weekNumber: 1, day: 1)],
            weekStartDate: nil  // dormant
        )

        XCTAssertNil(resolver.nextSession(across: [prog], now: now))
    }

    func testNextSessionAcrossReturnsNilWhenAllCompleted() {
        let s1 = makeSession(weekNumber: 1, day: 1)
        let prog = makeRecord(
            mode: .ondemand,
            sessions: [s1],
            completed: [s1.id]
        )

        XCTAssertNil(resolver.nextSession(across: [prog], now: now))
    }

    // MARK: - Story 3.11 — blocage doux (AC1-AC5)

    /// Helper : `weekStartDate` = `now` − N semaines.
    private func weekStart(weeksAgo: Int, from now: Date) -> Date {
        now.addingTimeInterval(TimeInterval(-weeksAgo * 7 * 86_400))
    }

    func testBlocksOnIncompleteWeek_Planned_deadlineFixed() {
        // S1 incomplète (2 sessions, 1 complétée + 1 pending), date courante = S+2.
        // Attendu : prochaine = la pending de S1 (day=2), ignorant les pending de S2/S3.
        let s1d1 = makeSession(weekNumber: 1, day: 1)
        let s1d2 = makeSession(weekNumber: 1, day: 2)
        let s2d1 = makeSession(weekNumber: 2, day: 1)
        let s3d1 = makeSession(weekNumber: 3, day: 1)
        let record = makeRecord(
            mode: .planned,
            sessions: [s1d1, s1d2, s2d1, s3d1],
            completed: [s1d1.id],
            durationMode: .deadlineFixed,
            weekStartDate: weekStart(weeksAgo: 2, from: now)
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s1d2.id)
        XCTAssertEqual(result?.session.weekNumber, 1)
        XCTAssertEqual(result?.session.day, 2)
    }

    func testWeekOneCompleteJumpsToWeekTwo_Planned_deadlineFixed() {
        // S1 entièrement complétée, date courante = S+2.
        // Attendu : prochaine = 1ʳᵉ pending de S2.
        let s1d1 = makeSession(weekNumber: 1, day: 1)
        let s1d2 = makeSession(weekNumber: 1, day: 2)
        let s2d1 = makeSession(weekNumber: 2, day: 1)
        let s2d2 = makeSession(weekNumber: 2, day: 2)
        let s3d1 = makeSession(weekNumber: 3, day: 1)
        let record = makeRecord(
            mode: .planned,
            sessions: [s1d1, s1d2, s2d1, s2d2, s3d1],
            completed: [s1d1.id, s1d2.id],
            durationMode: .deadlineFixed,
            weekStartDate: weekStart(weeksAgo: 2, from: now)
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s2d1.id)
        XCTAssertEqual(result?.session.weekNumber, 2)
    }

    func testBlocksOnIncompleteWeek_Planned_deadlineEstimated() {
        // Idem mais durationMode = .deadlineEstimated.
        let s1d1 = makeSession(weekNumber: 1, day: 1)
        let s2d1 = makeSession(weekNumber: 2, day: 1)
        let record = makeRecord(
            mode: .planned,
            sessions: [s1d1, s2d1],
            completed: [],
            durationMode: .deadlineEstimated,
            weekStartDate: weekStart(weeksAgo: 2, from: now)
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s1d1.id)
    }

    func testOndemandLegacyBehaviorUnchanged_AC3() {
        // **AC3** — mode .ondemand, tri (weekNumber, day) inchangé.
        let s1d1 = makeSession(weekNumber: 1, day: 1)
        let s2d1 = makeSession(weekNumber: 2, day: 1)
        let record = makeRecord(
            mode: .ondemand,
            sessions: [s1d1, s2d1],
            durationMode: .deadlineFixed,  // ignoré en .ondemand
            weekStartDate: weekStart(weeksAgo: 2, from: now)
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s1d1.id)
        XCTAssertEqual(result?.effectiveDate, now)
    }

    func testDormantReturnsNil_AC4() {
        // **AC4** — programme dormant (`weekStartDate == nil`) → résolveur retourne nil.
        let s = makeSession(weekNumber: 1, day: 1)
        let record = makeRecord(
            mode: .ondemand,
            sessions: [s],
            durationMode: .deadlineFixed,
            weekStartDate: nil
        )

        XCTAssertNil(resolver.nextSession(for: record, now: now))
    }

    // MARK: - Helpers

    private func makeSession(
        weekNumber: Int,
        day: Int
    ) -> PersistedSession {
        PersistedSession(
            id: UUID(),
            weekNumber: weekNumber,
            weekTheme: "W\(weekNumber)",
            weekGoal: "G\(weekNumber)",
            day: day,
            name: "S W\(weekNumber)D\(day)",
            durationMinutes: 30,
            type: .endurance,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
    }

    private func makeRecord(
        sportCode: String = "running",
        mode: ProgramMode,
        sessions: [PersistedSession],
        completed: [UUID] = [],
        durationMode: ProgramDurationMode = .routineCyclic,
        weekStartDate: Date? = Date()
    ) -> AdaptedProgramRecord {
        let completionState = ProgramCompletionState(
            sessionRecords: Dictionary(
                uniqueKeysWithValues: completed.map { id in
                    (id, SessionCompletionRecord(completedAt: Date()))
                }
            )
        )
        return AdaptedProgramRecord(
            userId: UUID(),
            sportCode: sportCode,
            level: "beginner",
            templateId: "test",
            adaptedAt: Date(timeIntervalSince1970: 1_699_000_000),
            weekStartDate: weekStartDate,
            mode: mode,
            sessions: sessions,
            completionState: completionState,
            durationMode: durationMode
        )
    }
}
