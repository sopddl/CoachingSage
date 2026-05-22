// CoachingSageTests/Coaching/Progress/PersonalRecordsEngineTests.swift
// Story 3.9 — détection PR (V1 : longestSession par sport).
import XCTest
import TemplateModel

@MainActor
final class PersonalRecordsEngineTests: XCTestCase {

    private let userId = UUID()
    // Jeudi 9 mai 2024 — milieu de semaine ISO. Pris au lieu d'un lundi pour
    // que `daysAgo: 1` tombe mercredi (DANS la fenêtre `.week` qui démarre
    // lundi 00:00 ISO). Sinon les "sessions récentes" du test seraient hors
    // fenêtre et les PR ne seraient pas détectés.
    private let now = Date(timeIntervalSince1970: 1_715_259_200)
    private var calendar: Calendar = {
        var c = Calendar(identifier: .iso8601)
        c.firstWeekday = 2
        c.timeZone = TimeZone(identifier: "Europe/Paris")!
        return c
    }()

    func testEmptyProgramsReturnsNothing() {
        let prs = PersonalRecordsEngine().detectRecent(period: .week, programs: [], now: now, calendar: calendar)
        XCTAssertEqual(prs, [])
    }

    func testInsufficientHistoryReturnsNothing() {
        // Une seule session historique avant la fenêtre → pas assez de base.
        let prog = makeProgram(sport: "running", completions: [
            (daysAgo: 10, duration: 40),
            (daysAgo: 1, duration: 90)
        ])
        let prs = PersonalRecordsEngine().detectRecent(period: .week, programs: [prog], now: now, calendar: calendar)
        XCTAssertEqual(prs, [], "Avec moins de 3 sessions historiques, on n'émet pas de PR")
    }

    func testDetectsLongestSessionPRWhenBeaten() {
        // 3 sessions historiques hors fenêtre (durées 30, 45, 50) + 1 dans la fenêtre (75).
        let prog = makeProgram(sport: "running", completions: [
            (daysAgo: 15, duration: 30),
            (daysAgo: 20, duration: 45),
            (daysAgo: 25, duration: 50),
            (daysAgo: 1, duration: 75)
        ])
        let prs = PersonalRecordsEngine().detectRecent(period: .week, programs: [prog], now: now, calendar: calendar)
        XCTAssertEqual(prs.count, 1)
        XCTAssertEqual(prs[0].sportCode, "running")
        XCTAssertEqual(prs[0].valueMinutes, 75)
        XCTAssertEqual(prs[0].previousBestMinutes, 50)
    }

    func testNoPRIfWindowValueDoesNotBeatHistory() {
        let prog = makeProgram(sport: "running", completions: [
            (daysAgo: 15, duration: 90),
            (daysAgo: 20, duration: 80),
            (daysAgo: 25, duration: 70),
            (daysAgo: 1, duration: 60)
        ])
        let prs = PersonalRecordsEngine().detectRecent(period: .week, programs: [prog], now: now, calendar: calendar)
        XCTAssertEqual(prs, [])
    }

    func testCapsAtThreePRs() {
        // 4 sports avec PR battu → on n'en garde que 3 (les plus impressionnants par delta).
        let sports = ["running", "cycling", "swimming", "yoga"]
        let programs = sports.enumerated().map { idx, sport in
            makeProgram(sport: sport, completions: [
                (daysAgo: 15, duration: 30),
                (daysAgo: 20, duration: 40),
                (daysAgo: 25, duration: 50),
                (daysAgo: 1, duration: 60 + (idx * 10)) // delta croissant
            ])
        }
        let prs = PersonalRecordsEngine().detectRecent(period: .week, programs: programs, now: now, calendar: calendar)
        XCTAssertEqual(prs.count, 3, "Plafond visuel à 3 PR")
        // Le plus gros delta (yoga, +40) doit être en tête.
        XCTAssertEqual(prs[0].sportCode, "yoga")
    }

    // MARK: - Helpers

    private func makeProgram(
        sport: String,
        completions: [(daysAgo: Int, duration: Int)]
    ) -> AdaptedProgramRecord {
        let sessions = completions.indices.map { i in
            PersistedSession(
                id: UUID(), weekNumber: 1, weekTheme: "W", weekGoal: "G",
                day: 1, name: "S\(i)", durationMinutes: 30,
                type: .endurance, warmup: nil, exercises: [], cooldown: nil
            )
        }
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: sport, level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: sessions
        )
        var state = ProgramCompletionState.empty
        for (i, c) in completions.enumerated() {
            let date = calendar.date(byAdding: .day, value: -c.daysAgo, to: now)!
            state.sessionRecords[sessions[i].id] = SessionCompletionRecord(
                completedAt: date,
                actualDurationMinutes: c.duration
            )
        }
        prog.completionState = state
        return prog
    }
}
