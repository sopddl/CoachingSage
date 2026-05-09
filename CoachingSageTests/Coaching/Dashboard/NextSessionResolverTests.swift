// CoachingSageTests/Coaching/Dashboard/NextSessionResolverTests.swift
// Story 3.8 — tests paramétriques tri prochaine séance (cf spec AC) :
//   - per-program planned : ne retient que les sessions ≥ aujourd'hui
//   - per-program ondemand : retourne la 1re session non complétée (ordre week/day)
//   - completion : skip les sessions déjà dans completionState
//   - multi-prog : retient la plus proche, tie-break ordre alphabétique sport
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class NextSessionResolverTests: XCTestCase {

    private let resolver = NextSessionResolver()
    private let now = Date(timeIntervalSince1970: 1_700_000_000) // mardi 14 nov 2023 22:13 UTC

    // MARK: - Per-program — planned mode

    func testPlannedReturnsClosestUpcomingSession() {
        let dayBefore = now.addingTimeInterval(-86400)
        let today = now
        let dayAfter = now.addingTimeInterval(86400)
        let twoDaysAfter = now.addingTimeInterval(86400 * 2)

        let record = makeRecord(
            mode: .planned,
            sessions: [
                makeSession(weekNumber: 1, day: 1, plannedDate: dayAfter),
                makeSession(weekNumber: 1, day: 2, plannedDate: twoDaysAfter),
                makeSession(weekNumber: 1, day: 3, plannedDate: dayBefore),
                makeSession(weekNumber: 2, day: 1, plannedDate: today)
            ]
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.session.day, 1)
        XCTAssertEqual(result?.session.weekNumber, 2)  // celle du jour
    }

    func testPlannedReturnsNilWhenAllPastOrCompleted() {
        let yesterday = now.addingTimeInterval(-86400)
        let record = makeRecord(
            mode: .planned,
            sessions: [makeSession(weekNumber: 1, day: 1, plannedDate: yesterday)]
        )

        XCTAssertNil(resolver.nextSession(for: record, now: now))
    }

    // MARK: - Per-program — ondemand mode

    func testOndemandReturnsFirstUncompletedByWeekDayOrder() {
        let s1 = makeSession(weekNumber: 1, day: 1)
        let s2 = makeSession(weekNumber: 1, day: 2)
        let s3 = makeSession(weekNumber: 2, day: 1)
        let record = makeRecord(mode: .ondemand, sessions: [s3, s1, s2]) // pas dans l'ordre

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s1.id)
        XCTAssertEqual(result?.effectiveDate, now) // .ondemand → aujourd'hui
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

    // MARK: - Multi-program

    func testNextSessionAcrossPicksClosestEffectiveDate() {
        let tomorrow = now.addingTimeInterval(86400)
        let inTwoDays = now.addingTimeInterval(86400 * 2)

        // Programme A en .planned dans 2 jours.
        let progA = makeRecord(
            sportCode: "running",
            mode: .planned,
            sessions: [makeSession(weekNumber: 1, day: 1, plannedDate: inTwoDays)]
        )
        // Programme B en .planned demain — devrait gagner.
        let progB = makeRecord(
            sportCode: "cycling",
            mode: .planned,
            sessions: [makeSession(weekNumber: 1, day: 1, plannedDate: tomorrow)]
        )

        let result = resolver.nextSession(across: [progA, progB], now: now)

        XCTAssertEqual(result?.program.sportCode, "cycling")
    }

    func testNextSessionAcrossOndemandTreatedAsToday() {
        let tomorrow = now.addingTimeInterval(86400)

        // .ondemand traité comme « aujourd'hui » → bat un .planned demain.
        let progA = makeRecord(
            sportCode: "running",
            mode: .ondemand,
            sessions: [makeSession(weekNumber: 1, day: 1)]
        )
        let progB = makeRecord(
            sportCode: "cycling",
            mode: .planned,
            sessions: [makeSession(weekNumber: 1, day: 1, plannedDate: tomorrow)]
        )

        let result = resolver.nextSession(across: [progA, progB], now: now)

        XCTAssertEqual(result?.program.sportCode, "running")
    }

    func testNextSessionAcrossTieBreakOnSportCodeAlphabetical() {
        // Deux .ondemand → effectiveDate = now identique → tie-break alpha sport.
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

    func testNextSessionAcrossReturnsNilWhenNoCandidate() {
        let yesterday = now.addingTimeInterval(-86400)
        let prog = makeRecord(
            mode: .planned,
            sessions: [makeSession(weekNumber: 1, day: 1, plannedDate: yesterday)]
        )

        XCTAssertNil(resolver.nextSession(across: [prog], now: now))
    }

    // MARK: - Helpers

    private func makeSession(
        weekNumber: Int,
        day: Int,
        plannedDate: Date? = nil
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
            cooldown: nil,
            plannedDate: plannedDate
        )
    }

    private func makeRecord(
        sportCode: String = "running",
        mode: ProgramMode,
        sessions: [PersistedSession],
        completed: [UUID] = []
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
            weekStartDate: Date(),
            mode: mode,
            sessions: sessions,
            completionState: completionState
        )
    }
}
