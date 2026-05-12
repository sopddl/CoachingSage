// CoachingSageTests/Regen/RegressionRuleTests.swift
// Story 3.4 Phase A.3 — tests décision ajustement volume S+1.
//
// Couvre les 7 branches de priorité (pauseExtended > pauseModerate > pauseLight
// > overExecuting > missedSessions > lowQuality > onTrack) + edge cases
// (full rest week, 1 seule séance complétée, multiplicateur math).
import XCTest
@testable import CoachingSage

final class RegressionRuleTests: XCTestCase {

    private typealias F = RegenTestFixtures

    // MARK: - Branche 7 — onTrack (default)

    func testOnTrackProgresses10() {
        let report = F.makeReport(
            completedSessionCount: 3,
            completionRate: 1.0,
            globalQuality: 85.0
        )
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .none)
        XCTAssertEqual(decision.reason, .onTrack)
        XCTAssertEqual(decision.adjustment, .progress(percent: 0.10))
        XCTAssertEqual(decision.adjustment.multiplier, 1.10, accuracy: 0.0001)
    }

    // MARK: - Branche 6 — lowQuality

    func testLowQualityMaintains() {
        // 3 séances faites, qualité 55 < 60 → maintain.
        let report = F.makeReport(
            completedSessionCount: 3,
            completionRate: 1.0,
            globalQuality: 55.0
        )
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .none)
        XCTAssertEqual(decision.reason, .lowQuality)
        XCTAssertEqual(decision.adjustment, .maintain)
        XCTAssertEqual(decision.adjustment.multiplier, 1.0)
    }

    func testLowQualityIgnoredWithSingleSession() {
        // 1 seule séance complétée → trop noisy pour juger, fallback onTrack.
        // (completionRate=0.5 sur 2 actives → faut basculer en missedSessions ?
        // Non : 0.5 n'est PAS strictement < 0.50, donc on continue.)
        let report = F.makeReport(
            plannedActiveSessionCount: 2,
            completedSessionCount: 1,
            completionRate: 0.5,
            globalQuality: 40.0
        )
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .none)
        XCTAssertEqual(decision.reason, .onTrack)
    }

    func testQualityExactly60_doesNotTriggerLowQuality() {
        // Bord seuil : strictement inférieur exigé.
        let report = F.makeReport(
            completedSessionCount: 3,
            completionRate: 1.0,
            globalQuality: 60.0
        )
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .none)
        XCTAssertEqual(decision.reason, .onTrack)
    }

    // MARK: - Branche 5 — missedSessions

    func testMissedSessionsReduces25() {
        // 4 actives planifiées, 1 complétée → completionRate 0.25 < 0.50.
        let report = F.makeReport(
            plannedActiveSessionCount: 4,
            completedSessionCount: 1,
            completionRate: 0.25,
            globalQuality: 80.0
        )
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .none)
        XCTAssertEqual(decision.reason, .missedSessions)
        XCTAssertEqual(decision.adjustment, .reduce(percent: 0.25))
        XCTAssertEqual(decision.adjustment.multiplier, 0.75, accuracy: 0.0001)
    }

    func testCompletionRateExactly50_doesNotTriggerMissed() {
        // 0.50 n'est PAS strictement < 0.50 → on file en lowQuality si applicable,
        // sinon onTrack.
        let report = F.makeReport(
            plannedActiveSessionCount: 4,
            completedSessionCount: 2,
            completionRate: 0.50,
            globalQuality: 85.0
        )
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .none)
        XCTAssertEqual(decision.reason, .onTrack)
    }

    func testFullRestWeekDoesNotTriggerMissed() {
        // 0 active planifiée, completionRate=0 par convention. Ne doit pas
        // déclencher missedSessions (rien à manquer).
        let report = F.makeReport(
            plannedActiveSessionCount: 0,
            completedSessionCount: 0,
            completionRate: 0.0,
            globalQuality: 0.0
        )
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .none)
        XCTAssertEqual(decision.reason, .onTrack)
    }

    // MARK: - Branche 4 — overExecuting

    func testOverExecutionReduces10() {
        let report = F.makeReport(
            completedSessionCount: 3,
            completionRate: 1.0,
            globalQuality: 95.0,
            overExecutedCount: 2,
            isOverallOverExecuted: true
        )
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .none)
        XCTAssertEqual(decision.reason, .overExecuting)
        XCTAssertEqual(decision.adjustment, .reduce(percent: 0.10))
        XCTAssertEqual(decision.adjustment.multiplier, 0.90, accuracy: 0.0001)
    }

    func testOverExecutionBeatsMissedSessions() {
        // Hypothèse : user a over-réalisé MAIS aussi raté la moitié des séances.
        // Cas peu probable en pratique (si tu rates, tu over-réalises pas) mais
        // testable. Priorité doctrine : safety (frein over) > adhérence.
        let report = F.makeReport(
            plannedActiveSessionCount: 4,
            completedSessionCount: 1,
            completionRate: 0.25,
            globalQuality: 95.0,
            overExecutedCount: 2,
            isOverallOverExecuted: true
        )
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .none)
        XCTAssertEqual(decision.reason, .overExecuting)
    }

    // MARK: - Branches 1-3 — pause

    func testPauseLightReduces10() {
        let report = F.makeReport(completedSessionCount: 3, completionRate: 1.0)
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .light)
        XCTAssertEqual(decision.reason, .pauseLight)
        XCTAssertEqual(decision.adjustment, .reduce(percent: 0.10))
    }

    func testPauseModerateReduces25() {
        let report = F.makeReport(completedSessionCount: 3, completionRate: 1.0)
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .moderate)
        XCTAssertEqual(decision.reason, .pauseModerate)
        XCTAssertEqual(decision.adjustment, .reduce(percent: 0.25))
    }

    func testPauseExtendedRestarts() {
        let report = F.makeReport(completedSessionCount: 0, completionRate: 0.0)
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .extended)
        XCTAssertEqual(decision.reason, .pauseExtended)
        XCTAssertEqual(decision.adjustment, .restart)
        XCTAssertEqual(decision.adjustment.multiplier, 0.5, accuracy: 0.0001)
    }

    func testPauseExtendedBeatsAllOtherFlags() {
        // User over-execute ET miss la moitié ET qualité basse, mais pause
        // détectée → restart prime.
        let report = F.makeReport(
            plannedActiveSessionCount: 4,
            completedSessionCount: 1,
            completionRate: 0.25,
            globalQuality: 40.0,
            overExecutedCount: 1,
            isOverallOverExecuted: true
        )
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .extended)
        XCTAssertEqual(decision.reason, .pauseExtended)
    }

    func testPauseLightBeatsOverExecution() {
        let report = F.makeReport(
            completedSessionCount: 3,
            completionRate: 1.0,
            overExecutedCount: 2,
            isOverallOverExecuted: true
        )
        let decision = RegressionRule.decide(currentWeek: report, pauseLevel: .light)
        XCTAssertEqual(decision.reason, .pauseLight)
    }

    // MARK: - Multiplicateur math

    func testVolumeAdjustmentMultiplierMath() {
        XCTAssertEqual(VolumeAdjustment.progress(percent: 0.10).multiplier, 1.10, accuracy: 0.0001)
        XCTAssertEqual(VolumeAdjustment.maintain.multiplier, 1.0)
        XCTAssertEqual(VolumeAdjustment.reduce(percent: 0.25).multiplier, 0.75, accuracy: 0.0001)
        XCTAssertEqual(VolumeAdjustment.reduce(percent: 0.50).multiplier, 0.50, accuracy: 0.0001)
        XCTAssertEqual(VolumeAdjustment.restart.multiplier, 0.5)
    }
}
