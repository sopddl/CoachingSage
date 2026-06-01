// CoachingSageTests/Coaching/Dashboard/LeonDashboardTipBuilderTests.swift
// Story 3.29 — couvre `LeonDashboardTipBuilder.build` (7 variantes + ordre de
// priorité) et la résolution i18n `LeonTip.message(locale:)`.
import XCTest
import TemplateModel

final class LeonDashboardTipBuilderTests: XCTestCase {

    // MARK: - Helpers

    private func makeSession(type: SessionType = .interval) -> PersistedSession {
        PersistedSession(
            weekNumber: 2,
            weekTheme: "theme",
            weekGoal: "goal",
            day: 1,
            name: "Fractionné 8×400m",
            durationMinutes: 45,
            type: type,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
    }

    private func makeSummary(
        nextSession: PersistedSession? = nil,
        nextSessionIsLate: Bool = false,
        weekCompletedSessions: Int = 0,
        weekTotalSessions: Int = 3,
        totalSessionsCompleted: Int = 0,
        totalSessions: Int = 12
    ) -> ProgramSummary {
        ProgramSummary(
            id: UUID(),
            templateName: "Course — 10K",
            sport: .running,
            weekStartDate: Date(),
            durationMode: .routineCyclic,
            mode: .planned,
            nextSession: nextSession,
            currentWeekNumber: 2,
            weekCompletedSessions: weekCompletedSessions,
            weekTotalSessions: weekTotalSessions,
            totalSessionsCompleted: totalSessionsCompleted,
            totalSessions: totalSessions,
            lastUpdatedAt: Date(),
            nextSessionIsLate: nextSessionIsLate,
            goalCode: "10k",
            secondaryGoals: [],
            isUserRenamed: false
        )
    }

    private func stats(streak: Int = 0, minutes: Int = 0, completed: Int = 0) -> WeeklyStats {
        WeeklyStats(totalMinutes: minutes, completedCount: completed, streakDays: streak)
    }

    // MARK: - Variantes individuelles

    func testLateTakesTopPriority() {
        // En retard ET série active : le retard gagne.
        let summary = makeSummary(nextSession: makeSession(type: .endurance), nextSessionIsLate: true)
        let tip = LeonDashboardTipBuilder.build(summary: summary, stats: stats(streak: 10))
        XCTAssertEqual(tip, .late(nextType: .endurance))
    }

    func testStreakWhenAtThreshold() {
        let summary = makeSummary(
            nextSession: makeSession(type: .interval),
            weekCompletedSessions: 1,
            weekTotalSessions: 3
        )
        let tip = LeonDashboardTipBuilder.build(summary: summary, stats: stats(streak: 3))
        XCTAssertEqual(tip, .streak(days: 3, nextType: .interval))
    }

    func testStreakBelowThresholdDoesNotFire() {
        // streak 2 < seuil 3 → on tombe sur séances restantes.
        let summary = makeSummary(
            nextSession: makeSession(type: .interval),
            weekCompletedSessions: 1,
            weekTotalSessions: 3
        )
        let tip = LeonDashboardTipBuilder.build(summary: summary, stats: stats(streak: 2))
        XCTAssertEqual(tip, .sessionsLeft(count: 2, nextType: .interval))
    }

    func testProgramCompletedBeatsWeekCompleted() {
        // Tout fait : programme terminé doit gagner sur semaine bouclée.
        let summary = makeSummary(
            weekCompletedSessions: 3,
            weekTotalSessions: 3,
            totalSessionsCompleted: 12,
            totalSessions: 12
        )
        let tip = LeonDashboardTipBuilder.build(summary: summary, stats: stats(streak: 0))
        XCTAssertEqual(tip, .programCompleted)
    }

    func testWeekCompletedWhenWeekDoneButProgramNot() {
        let summary = makeSummary(
            weekCompletedSessions: 3,
            weekTotalSessions: 3,
            totalSessionsCompleted: 3,
            totalSessions: 12
        )
        let tip = LeonDashboardTipBuilder.build(summary: summary, stats: stats(streak: 0))
        XCTAssertEqual(tip, .weekCompleted)
    }

    func testSessionsLeftPlural() {
        let summary = makeSummary(
            nextSession: makeSession(type: .strength),
            weekCompletedSessions: 1,
            weekTotalSessions: 4
        )
        let tip = LeonDashboardTipBuilder.build(summary: summary, stats: stats(streak: 0))
        XCTAssertEqual(tip, .sessionsLeft(count: 3, nextType: .strength))
    }

    func testHalfwayWhenNoWeekSessionsButHalfProgramDone() {
        // weekTotal 0 → ni semaine bouclée ni séances restantes ; ≥50 % du
        // programme fait → mi-parcours.
        let summary = makeSummary(
            nextSession: nil,
            weekCompletedSessions: 0,
            weekTotalSessions: 0,
            totalSessionsCompleted: 6,
            totalSessions: 12
        )
        let tip = LeonDashboardTipBuilder.build(summary: summary, stats: stats(streak: 0))
        XCTAssertEqual(tip, .halfway)
    }

    func testGenericFallback() {
        // Rien de saillant : pas de séance, pas de série, <50 % fait.
        let summary = makeSummary(
            nextSession: nil,
            weekCompletedSessions: 0,
            weekTotalSessions: 0,
            totalSessionsCompleted: 1,
            totalSessions: 12
        )
        let tip = LeonDashboardTipBuilder.build(summary: summary, stats: stats(streak: 0))
        XCTAssertEqual(tip, .generic)
    }

    // MARK: - i18n message

    func testMessageResolvesAndDiffersFRvsEN() {
        let tip = LeonTip.streak(days: 4, nextType: .interval)
        let fr = tip.message(locale: Locale(identifier: "fr"))
        let en = tip.message(locale: Locale(identifier: "en"))
        XCTAssertFalse(fr.isEmpty)
        XCTAssertFalse(en.isEmpty)
        XCTAssertNotEqual(fr, en)
        // Le nombre de jours est interpolé.
        XCTAssertTrue(fr.contains("4"), "streak FR doit contenir le nombre de jours, got: \(fr)")
    }

    func testSessionsLeftSingularUsesOneVariant() {
        let one = LeonTip.sessionsLeft(count: 1, nextType: .endurance)
        let many = LeonTip.sessionsLeft(count: 3, nextType: .endurance)
        let frOne = one.message(locale: Locale(identifier: "fr"))
        let frMany = many.message(locale: Locale(identifier: "fr"))
        XCTAssertFalse(frOne.isEmpty)
        XCTAssertNotEqual(frOne, frMany, "singulier et pluriel doivent différer")
        XCTAssertTrue(frMany.contains("3"), "pluriel doit contenir le compte, got: \(frMany)")
    }
}
