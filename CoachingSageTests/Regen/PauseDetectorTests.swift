// CoachingSageTests/Regen/PauseDetectorTests.swift
// Story 3.4 Phase A.3 — tests détection de pause d'entraînement.
//
// Couvre les 2 signaux (historique completionRate + jours HK), leur fusion
// (max des deux niveaux), les seuils ACSM (4/8/15 jours), et les edge cases
// (full rest week, daysSinceLastWorkout négatif/nil, série brisée par semaine
// haute).
import XCTest
@testable import CoachingSage

final class PauseDetectorTests: XCTestCase {

    private typealias F = RegenTestFixtures

    // MARK: - Signal jours HK seul (recentReports vide)

    func testNoReportsNoDays_returnsNone() {
        let result = PauseDetector.detect(recentReports: [], daysSinceLastWorkout: nil)
        XCTAssertEqual(result.level, .none)
        XCTAssertNil(result.daysSinceLastWorkout)
        XCTAssertEqual(result.consecutiveLowWeeks, 0)
    }

    func testNoReports3Days_returnsNone() {
        // 3j < seuil light (4j) → encore normal.
        let result = PauseDetector.detect(recentReports: [], daysSinceLastWorkout: 3)
        XCTAssertEqual(result.level, .none)
    }

    func testNoReports4Days_returnsLight() {
        let result = PauseDetector.detect(recentReports: [], daysSinceLastWorkout: 4)
        XCTAssertEqual(result.level, .light)
    }

    func testNoReports7Days_returnsLight() {
        // Bord supérieur light (avant le seuil moderate à 8j).
        let result = PauseDetector.detect(recentReports: [], daysSinceLastWorkout: 7)
        XCTAssertEqual(result.level, .light)
    }

    func testNoReports8Days_returnsModerate() {
        let result = PauseDetector.detect(recentReports: [], daysSinceLastWorkout: 8)
        XCTAssertEqual(result.level, .moderate)
    }

    func testNoReports14Days_returnsModerate() {
        // Bord supérieur moderate (avant seuil extended à 15j).
        let result = PauseDetector.detect(recentReports: [], daysSinceLastWorkout: 14)
        XCTAssertEqual(result.level, .moderate)
    }

    func testNoReports15Days_returnsExtended() {
        let result = PauseDetector.detect(recentReports: [], daysSinceLastWorkout: 15)
        XCTAssertEqual(result.level, .extended)
    }

    func testNoReports30Days_returnsExtended() {
        let result = PauseDetector.detect(recentReports: [], daysSinceLastWorkout: 30)
        XCTAssertEqual(result.level, .extended)
    }

    func testNegativeDaysTreatedAsNone() {
        // Cas dégénéré : si une horloge mal calibrée renvoie -1, on traite
        // comme "aucun signal" plutôt que de matcher un seuil négatif.
        let result = PauseDetector.detect(recentReports: [], daysSinceLastWorkout: -1)
        XCTAssertEqual(result.level, .none)
    }

    // MARK: - Signal historique seul (daysSinceLastWorkout nil)

    func testRecentWeekFine_returnsNone() {
        // Dernière sem 80% → série brisée dès l'index 0, consecutiveLow=0.
        let report = F.makeReport(completedSessionCount: 4, completionRate: 0.80)
        let result = PauseDetector.detect(recentReports: [report], daysSinceLastWorkout: nil)
        XCTAssertEqual(result.level, .none)
        XCTAssertEqual(result.consecutiveLowWeeks, 0)
    }

    func testOneWeekLow_returnsLight() {
        // 1 sem complète sous le seuil 30% → light.
        let report = F.makeReport(completedSessionCount: 0, completionRate: 0.0)
        let result = PauseDetector.detect(recentReports: [report], daysSinceLastWorkout: nil)
        XCTAssertEqual(result.level, .light)
        XCTAssertEqual(result.consecutiveLowWeeks, 1)
    }

    func testTwoWeeksLow_returnsModerate() {
        let r1 = F.makeReport(weekNumber: 5, completedSessionCount: 0, completionRate: 0.0)
        let r2 = F.makeReport(weekNumber: 4, completedSessionCount: 0, completionRate: 0.0)
        let result = PauseDetector.detect(recentReports: [r1, r2], daysSinceLastWorkout: nil)
        XCTAssertEqual(result.level, .moderate)
        XCTAssertEqual(result.consecutiveLowWeeks, 2)
    }

    func testThreeWeeksLow_returnsExtended() {
        let r1 = F.makeReport(weekNumber: 5, completedSessionCount: 0, completionRate: 0.0)
        let r2 = F.makeReport(weekNumber: 4, completedSessionCount: 0, completionRate: 0.0)
        let r3 = F.makeReport(weekNumber: 3, completedSessionCount: 0, completionRate: 0.0)
        let result = PauseDetector.detect(recentReports: [r1, r2, r3], daysSinceLastWorkout: nil)
        XCTAssertEqual(result.level, .extended)
        XCTAssertEqual(result.consecutiveLowWeeks, 3)
    }

    func testSeriesBreaksAtHighWeek_returnsNone() {
        // Sem la plus récente OK → break à l'index 0, consecutiveLow=0
        // même si les semaines suivantes sont low.
        let r1 = F.makeReport(weekNumber: 5, completedSessionCount: 3, completionRate: 1.0)
        let r2 = F.makeReport(weekNumber: 4, completedSessionCount: 0, completionRate: 0.0)
        let result = PauseDetector.detect(recentReports: [r1, r2], daysSinceLastWorkout: nil)
        XCTAssertEqual(result.level, .none)
        XCTAssertEqual(result.consecutiveLowWeeks, 0)
    }

    func testLowAtThresholdExactly_doesNotCountAsLow() {
        // completionRate exactement 0.30 = seuil — strictement inférieur exigé,
        // donc 0.30 NE déclenche PAS pause.
        let report = F.makeReport(completedSessionCount: 1, completionRate: 0.30)
        let result = PauseDetector.detect(recentReports: [report], daysSinceLastWorkout: nil)
        XCTAssertEqual(result.level, .none)
    }

    func testFullRestWeekDoesNotCountAsLow() {
        // Semaine planifiée 100% rest : completionRate=0 par convention de
        // l'analyzer, mais ce n'est pas une pause subie. Le detector doit
        // sauter ces semaines.
        let restWeek = F.makeReport(
            weekNumber: 5,
            plannedActiveSessionCount: 0,
            completedSessionCount: 0,
            completionRate: 0.0
        )
        let lowWeek = F.makeReport(
            weekNumber: 4,
            plannedActiveSessionCount: 3,
            completedSessionCount: 0,
            completionRate: 0.0
        )
        let result = PauseDetector.detect(recentReports: [restWeek, lowWeek], daysSinceLastWorkout: nil)
        XCTAssertEqual(result.level, .none, "Une semaine de décharge planifiée doit briser la série, pas l'étendre")
        XCTAssertEqual(result.consecutiveLowWeeks, 0)
    }

    // MARK: - Fusion des 2 signaux

    func testDaysExtendedOverridesHistoryLight() {
        // Historique = 1 sem low (light) mais HK dit 20j sans workout (extended).
        // On retient le pire des deux : extended.
        let lowWeek = F.makeReport(completedSessionCount: 0, completionRate: 0.0)
        let result = PauseDetector.detect(recentReports: [lowWeek], daysSinceLastWorkout: 20)
        XCTAssertEqual(result.level, .extended)
    }

    func testHistoryModerateOverridesDaysLight() {
        // Historique = 2 sem low (moderate) mais HK dit 5j seulement (light).
        // On retient le pire : moderate.
        let r1 = F.makeReport(weekNumber: 5, completedSessionCount: 0, completionRate: 0.0)
        let r2 = F.makeReport(weekNumber: 4, completedSessionCount: 0, completionRate: 0.0)
        let result = PauseDetector.detect(recentReports: [r1, r2], daysSinceLastWorkout: 5)
        XCTAssertEqual(result.level, .moderate)
    }

    func testBothSignalsConsistent_returnsSameLevel() {
        // Cas nominal sans incohérence : 2 sem low + 10 jours = moderate des deux côtés.
        let r1 = F.makeReport(weekNumber: 5, completedSessionCount: 0, completionRate: 0.0)
        let r2 = F.makeReport(weekNumber: 4, completedSessionCount: 0, completionRate: 0.0)
        let result = PauseDetector.detect(recentReports: [r1, r2], daysSinceLastWorkout: 10)
        XCTAssertEqual(result.level, .moderate)
        XCTAssertEqual(result.daysSinceLastWorkout, 10)
        XCTAssertEqual(result.consecutiveLowWeeks, 2)
    }

    // MARK: - Boundary completionRate

    func testJustBelowThreshold_countsAsLow() {
        // 0.29 < 0.30 → low.
        let report = F.makeReport(completedSessionCount: 1, completionRate: 0.29)
        let result = PauseDetector.detect(recentReports: [report], daysSinceLastWorkout: nil)
        XCTAssertEqual(result.level, .light)
        XCTAssertEqual(result.consecutiveLowWeeks, 1)
    }

    func testJustAboveThreshold_doesNotCountAsLow() {
        let report = F.makeReport(completedSessionCount: 1, completionRate: 0.31)
        let result = PauseDetector.detect(recentReports: [report], daysSinceLastWorkout: nil)
        XCTAssertEqual(result.level, .none)
    }
}
