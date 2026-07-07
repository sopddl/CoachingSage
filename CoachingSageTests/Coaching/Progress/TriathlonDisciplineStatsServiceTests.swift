// CoachingSageTests/Coaching/Progress/TriathlonDisciplineStatsServiceTests.swift
// Chantier récap hebdo triathlon (2026-07-06/07) — bloc 5 Progrès : répartition
// nage/vélo/course des séances complétées d'un programme triathlon.
import XCTest
import TemplateModel

@MainActor
final class TriathlonDisciplineStatsServiceTests: XCTestCase {

    private let userId = UUID()
    private let now = Date(timeIntervalSince1970: 1_715_000_000) // 2024-05-06 lundi
    private var calendar: Calendar = {
        var c = Calendar(identifier: .iso8601)
        c.firstWeekday = 2
        c.timeZone = TimeZone(identifier: "Europe/Paris")!
        return c
    }()

    private func session(_ name: String, day: Int) -> PersistedSession {
        PersistedSession(
            id: UUID(), weekNumber: 1, weekTheme: "W", weekGoal: "G",
            day: day, name: LocalizedText(fr: name), durationMinutes: 30,
            type: .endurance, warmup: nil, exercises: [], cooldown: nil
        )
    }

    func testEmptyProgramsReturnsEmpty() {
        let rows = TriathlonDisciplineStatsService().compute(programs: [], now: now, period: .week, calendar: calendar)
        XCTAssertEqual(rows, [])
    }

    func testNonTriathlonProgramReturnsEmpty() {
        let swim = session("Natation — technique crawl", day: 1)
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "swimming", level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: [swim]
        )
        var state = ProgramCompletionState.empty
        state.sessionRecords[swim.id] = SessionCompletionRecord(completedAt: now)
        prog.completionState = state

        let rows = TriathlonDisciplineStatsService().compute(programs: [prog], now: now, period: .week, calendar: calendar)
        XCTAssertEqual(rows, [], "Un programme mono-sport ne doit jamais produire de répartition")
    }

    func testTriathlonProgramCountsByDisciplineOrderedSwimBikeRun() {
        let swim = session("Natation — technique crawl", day: 1)
        let bike1 = session("Vélo — sortie endurance", day: 2)
        let bike2 = session("Vélo — sortie longue", day: 3)
        let run = session("Course — sortie facile", day: 4)
        let strength = session("Renfo fondation triathlon", day: 5)
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "triathlon", level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: [swim, bike1, bike2, run, strength]
        )
        var state = ProgramCompletionState.empty
        for s in [swim, bike1, bike2, run, strength] {
            state.sessionRecords[s.id] = SessionCompletionRecord(completedAt: now)
        }
        prog.completionState = state

        let rows = TriathlonDisciplineStatsService().compute(programs: [prog], now: now, period: .week, calendar: calendar)
        XCTAssertEqual(rows.map(\.sportCode), ["swimming", "cycling", "running"])
        XCTAssertEqual(rows.map(\.completedCount), [1, 2, 1])
        XCTAssertEqual(rows.first(where: { $0.sportCode == "cycling" })?.ratio, 1.0, "Vélo = max (2 séances) → ratio 1.0")
    }

    func testExcludesSessionsOutsideWindowAndFallbackDays() {
        let swim = session("Natation — technique crawl", day: 1)
        let strengthOnly = session("Renfo fondation triathlon", day: 2)
        let oldRun = session("Course — sortie facile", day: 3)
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "triathlon", level: "beginner",
            templateId: "t", adaptedAt: now, weekStartDate: now,
            mode: .ondemand, sessions: [swim, strengthOnly, oldRun]
        )
        let fortyDaysAgo = calendar.date(byAdding: .day, value: -40, to: now)!
        var state = ProgramCompletionState.empty
        state.sessionRecords[swim.id] = SessionCompletionRecord(completedAt: now)
        state.sessionRecords[strengthOnly.id] = SessionCompletionRecord(completedAt: now)
        state.sessionRecords[oldRun.id] = SessionCompletionRecord(completedAt: fortyDaysAgo)
        prog.completionState = state

        let rows = TriathlonDisciplineStatsService().compute(programs: [prog], now: now, period: .week, calendar: calendar)
        XCTAssertEqual(rows.map(\.sportCode), ["swimming"], "Renfo exclu (fallback), course hors fenêtre exclue")
        XCTAssertEqual(rows.first?.completedCount, 1)
    }
}
