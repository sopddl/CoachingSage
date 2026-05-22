// CoachingSageTests/Coaching/Dashboard/WeeklyStatsServiceTests.swift
// Story 3.8 sous-tâche 8 — couvre les 3 stats du mini-widget « Cette semaine ».
import XCTest
import TemplateModel

@MainActor
final class WeeklyStatsServiceTests: XCTestCase {

    private let userId = UUID()
    private let now = Date(timeIntervalSince1970: 1_715_000_000) // 2024-05-06 lundi
    private var calendar: Calendar = {
        var c = Calendar(identifier: .iso8601)
        c.firstWeekday = 2
        c.timeZone = TimeZone(identifier: "Europe/Paris")!
        return c
    }()

    func testEmptyProgramsReturnsEmpty() {
        let stats = WeeklyStatsService().computeCurrentWeek(programs: [], now: now, calendar: calendar)
        XCTAssertEqual(stats, .empty)
    }

    func testCompletedCountAndVolumeFromActualDuration() {
        let session = PersistedSession(
            id: UUID(), weekNumber: 1, weekTheme: "W", weekGoal: "G",
            day: 1, name: "S", durationMinutes: 30,
            type: .endurance, warmup: nil, exercises: [], cooldown: nil
        )
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "running", level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: [session]
        )
        var state = ProgramCompletionState.empty
        state.sessionRecords[session.id] = SessionCompletionRecord(
            completedAt: now,
            actualDurationMinutes: 42
        )
        prog.completionState = state

        let stats = WeeklyStatsService().computeCurrentWeek(programs: [prog], now: now, calendar: calendar)
        XCTAssertEqual(stats.completedCount, 1)
        XCTAssertEqual(stats.totalMinutes, 42, "Doit utiliser actualDurationMinutes en priorité")
    }

    func testFallsBackToTemplateDurationWhenActualMissing() {
        let session = PersistedSession(
            id: UUID(), weekNumber: 1, weekTheme: "W", weekGoal: "G",
            day: 1, name: "S", durationMinutes: 35,
            type: .endurance, warmup: nil, exercises: [], cooldown: nil
        )
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "running", level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: [session]
        )
        var state = ProgramCompletionState.empty
        state.sessionRecords[session.id] = SessionCompletionRecord(completedAt: now, actualDurationMinutes: nil)
        prog.completionState = state

        let stats = WeeklyStatsService().computeCurrentWeek(programs: [prog], now: now, calendar: calendar)
        XCTAssertEqual(stats.totalMinutes, 35)
    }

    func testStreakCountsConsecutiveDays() {
        let s1 = makeSession(day: 1)
        let s2 = makeSession(day: 2)
        let s3 = makeSession(day: 3)
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "running", level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: [s1, s2, s3]
        )

        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let dayBefore = calendar.date(byAdding: .day, value: -2, to: now)!

        var state = ProgramCompletionState.empty
        state.sessionRecords[s1.id] = SessionCompletionRecord(completedAt: dayBefore)
        state.sessionRecords[s2.id] = SessionCompletionRecord(completedAt: yesterday)
        state.sessionRecords[s3.id] = SessionCompletionRecord(completedAt: now)
        prog.completionState = state

        let stats = WeeklyStatsService().computeCurrentWeek(programs: [prog], now: now, calendar: calendar)
        XCTAssertEqual(stats.streakDays, 3)
    }

    func testStreakZeroWhenNoCompletionToday() {
        let session = makeSession(day: 1)
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "running", level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: [session]
        )
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        var state = ProgramCompletionState.empty
        state.sessionRecords[session.id] = SessionCompletionRecord(completedAt: twoDaysAgo)
        prog.completionState = state

        let stats = WeeklyStatsService().computeCurrentWeek(programs: [prog], now: now, calendar: calendar)
        XCTAssertEqual(stats.streakDays, 0, "Streak rompu si rien aujourd'hui ni hier")
    }

    private func makeSession(day: Int) -> PersistedSession {
        PersistedSession(
            id: UUID(), weekNumber: 1, weekTheme: "W", weekGoal: "G",
            day: day, name: "S\(day)", durationMinutes: 30,
            type: .endurance, warmup: nil, exercises: [], cooldown: nil
        )
    }

    // MARK: - Story 3.9 — period extension

    func testMonthPeriodAggregatesLast30Days() {
        let session1 = makeSession(day: 1)
        let session2 = makeSession(day: 2)
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "running", level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: [session1, session2]
        )
        // 1 séance il y a 5 jours (DANS la fenêtre 30j), 1 séance il y a 40 jours (HORS).
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: now)!
        let fortyDaysAgo = calendar.date(byAdding: .day, value: -40, to: now)!
        var state = ProgramCompletionState.empty
        state.sessionRecords[session1.id] = SessionCompletionRecord(completedAt: fiveDaysAgo, actualDurationMinutes: 45)
        state.sessionRecords[session2.id] = SessionCompletionRecord(completedAt: fortyDaysAgo, actualDurationMinutes: 60)
        prog.completionState = state

        let stats = WeeklyStatsService().compute(programs: [prog], now: now, period: .month, calendar: calendar)
        XCTAssertEqual(stats.completedCount, 1, "Seule la séance dans la fenêtre 30j compte")
        XCTAssertEqual(stats.totalMinutes, 45)
    }

    func testQuarterPeriodAggregatesLast90Days() {
        let session1 = makeSession(day: 1)
        let session2 = makeSession(day: 2)
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "running", level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: [session1, session2]
        )
        let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: now)!
        let hundredDaysAgo = calendar.date(byAdding: .day, value: -100, to: now)!
        var state = ProgramCompletionState.empty
        state.sessionRecords[session1.id] = SessionCompletionRecord(completedAt: sixtyDaysAgo, actualDurationMinutes: 50)
        state.sessionRecords[session2.id] = SessionCompletionRecord(completedAt: hundredDaysAgo, actualDurationMinutes: 70)
        prog.completionState = state

        let stats = WeeklyStatsService().compute(programs: [prog], now: now, period: .quarter, calendar: calendar)
        XCTAssertEqual(stats.completedCount, 1, "Seule la séance dans la fenêtre 90j compte")
        XCTAssertEqual(stats.totalMinutes, 50)
    }

    func testStreakIndependentOfPeriod() {
        let s1 = makeSession(day: 1)
        let s2 = makeSession(day: 2)
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "running", level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: [s1, s2]
        )
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        var state = ProgramCompletionState.empty
        state.sessionRecords[s1.id] = SessionCompletionRecord(completedAt: yesterday)
        state.sessionRecords[s2.id] = SessionCompletionRecord(completedAt: now)
        prog.completionState = state

        let week = WeeklyStatsService().compute(programs: [prog], now: now, period: .week, calendar: calendar)
        let quarter = WeeklyStatsService().compute(programs: [prog], now: now, period: .quarter, calendar: calendar)
        XCTAssertEqual(week.streakDays, 2)
        XCTAssertEqual(quarter.streakDays, 2, "Streak global, ne dépend pas de la fenêtre")
    }
}
