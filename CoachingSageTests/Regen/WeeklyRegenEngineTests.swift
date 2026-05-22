// CoachingSageTests/Regen/WeeklyRegenEngineTests.swift
// Tests Phase A.4 — vérifient que A.4 chaîne correctement A.2 (rapport),
// A.3 PauseDetector + RegressionRule. On ne re-teste pas la logique de chaque
// brique (déjà couverte par leurs propres tests), seulement la composition :
//   - les bonnes inputs sont passées aux bonnes étapes
//   - les bons signaux remontent dans `WeeklyRegenDecision`
//   - les edge cases d'orchestration (history vide, current vs previous)
import XCTest
import TemplateModel

final class WeeklyRegenEngineTests: XCTestCase {

    // MARK: - Target week number

    func testTargetWeekIsAnalyzedPlusOne() {
        let report = RegenTestFixtures.makeReport(weekNumber: 4)
        let decision = WeeklyRegenEngine.regenerate(currentReport: report)
        XCTAssertEqual(decision.analyzedWeekNumber, 4)
        XCTAssertEqual(decision.targetWeekNumber, 5)
    }

    // MARK: - onTrack default

    func testOnTrackProgressionWhenAllSignalsGreen() {
        let report = RegenTestFixtures.makeReport(
            completionRate: 1.0,
            globalQuality: 90.0
        )
        let decision = WeeklyRegenEngine.regenerate(currentReport: report)

        XCTAssertEqual(decision.reason, .onTrack)
        XCTAssertEqual(decision.pauseLevel, .none)
        XCTAssertEqual(decision.adjustment, .progress(percent: 0.10))
        XCTAssertEqual(decision.multiplier, 1.10, accuracy: 0.0001)
    }

    // MARK: - Pause via daysSinceLastWorkout

    func testDaysSinceLastWorkoutLightPause() {
        let report = RegenTestFixtures.makeReport()
        let decision = WeeklyRegenEngine.regenerate(
            currentReport: report,
            daysSinceLastWorkout: 5
        )
        XCTAssertEqual(decision.pauseLevel, .light)
        XCTAssertEqual(decision.reason, .pauseLight)
        XCTAssertEqual(decision.adjustment, .reduce(percent: 0.10))
        XCTAssertEqual(decision.multiplier, 0.90, accuracy: 0.0001)
    }

    func testDaysSinceLastWorkoutModeratePause() {
        let report = RegenTestFixtures.makeReport()
        let decision = WeeklyRegenEngine.regenerate(
            currentReport: report,
            daysSinceLastWorkout: 10
        )
        XCTAssertEqual(decision.pauseLevel, .moderate)
        XCTAssertEqual(decision.reason, .pauseModerate)
        XCTAssertEqual(decision.adjustment, .reduce(percent: 0.25))
        XCTAssertEqual(decision.multiplier, 0.75, accuracy: 0.0001)
    }

    func testDaysSinceLastWorkoutExtendedTriggersRestart() {
        let report = RegenTestFixtures.makeReport()
        let decision = WeeklyRegenEngine.regenerate(
            currentReport: report,
            daysSinceLastWorkout: 20
        )
        XCTAssertEqual(decision.pauseLevel, .extended)
        XCTAssertEqual(decision.reason, .pauseExtended)
        XCTAssertEqual(decision.adjustment, .restart)
        XCTAssertEqual(decision.multiplier, 0.5, accuracy: 0.0001)
    }

    // MARK: - Pause via history (consecutive low weeks)

    func testHistoryThreeLowWeeksTriggersExtended() {
        // PauseDetector regarde uniquement le passé : 3 sem low archivées →
        // extended, quel que soit le rapport courant.
        let current = RegenTestFixtures.makeReport(completionRate: 1.0)
        let previousReports = (0..<3).map { _ in
            RegenTestFixtures.makeReport(
                completionRate: 0.1,
                globalQuality: 50.0
            )
        }
        let decision = WeeklyRegenEngine.regenerate(
            currentReport: current,
            previousReports: previousReports
        )
        XCTAssertEqual(decision.pauseLevel, .extended)
        XCTAssertEqual(decision.reason, .pauseExtended)
        XCTAssertEqual(decision.pauseDetection.consecutiveLowWeeks, 3)
    }

    func testHistoryTwoLowWeeksTriggersModerate() {
        let current = RegenTestFixtures.makeReport(completionRate: 1.0)
        let previousReports = [
            RegenTestFixtures.makeReport(
                weekNumber: 0,
                completionRate: 0.2,
                globalQuality: 50.0
            ),
            RegenTestFixtures.makeReport(
                weekNumber: -1,
                completionRate: 0.1,
                globalQuality: 40.0
            ),
        ]
        let decision = WeeklyRegenEngine.regenerate(
            currentReport: current,
            previousReports: previousReports
        )
        XCTAssertEqual(decision.pauseLevel, .moderate)
        XCTAssertEqual(decision.reason, .pauseModerate)
        XCTAssertEqual(decision.pauseDetection.consecutiveLowWeeks, 2)
    }

    /// Garde-fou ordre : si Phase B branche une query SQLite qui retourne les
    /// rapports en ordre ASC (plus ancien d'abord), A.4 doit produire le même
    /// résultat que si l'appelant les avait passés DESC. Sort défensif au pas
    /// d'entrée du moteur.
    func testPreviousReportsOrderIndifferent() {
        let current = RegenTestFixtures.makeReport(completionRate: 1.0)
        let calendar = Calendar.current
        let base = RegenTestFixtures.makeWeekStart()
        // 3 rapports low avec des dates strictement décroissantes en partant
        // de base (S-1, S-2, S-3). On les passe ASC pour défier le moteur.
        let weekMinus1Start = calendar.date(byAdding: .day, value: -7, to: base)!
        let weekMinus2Start = calendar.date(byAdding: .day, value: -14, to: base)!
        let weekMinus3Start = calendar.date(byAdding: .day, value: -21, to: base)!
        let report1 = WeeklyExecutionReport(
            weekNumber: 0, weekStartDate: weekMinus1Start,
            plannedSessionCount: 3, plannedActiveSessionCount: 3,
            completedSessionCount: 0, completionRate: 0.1,
            globalQuality: 40, overExecutedCount: 0,
            isOverallOverExecuted: false, matches: []
        )
        let report2 = WeeklyExecutionReport(
            weekNumber: -1, weekStartDate: weekMinus2Start,
            plannedSessionCount: 3, plannedActiveSessionCount: 3,
            completedSessionCount: 0, completionRate: 0.1,
            globalQuality: 40, overExecutedCount: 0,
            isOverallOverExecuted: false, matches: []
        )
        let report3 = WeeklyExecutionReport(
            weekNumber: -2, weekStartDate: weekMinus3Start,
            plannedSessionCount: 3, plannedActiveSessionCount: 3,
            completedSessionCount: 0, completionRate: 0.1,
            globalQuality: 40, overExecutedCount: 0,
            isOverallOverExecuted: false, matches: []
        )

        let decisionASC = WeeklyRegenEngine.regenerate(
            currentReport: current,
            previousReports: [report3, report2, report1]
        )
        let decisionDESC = WeeklyRegenEngine.regenerate(
            currentReport: current,
            previousReports: [report1, report2, report3]
        )
        XCTAssertEqual(decisionASC.pauseLevel, .extended)
        XCTAssertEqual(decisionASC.reason, decisionDESC.reason)
        XCTAssertEqual(decisionASC.adjustment, decisionDESC.adjustment)
        XCTAssertEqual(decisionASC.pauseDetection, decisionDESC.pauseDetection)
    }

    /// Doctrine A.4 : une seule semaine courante sub-seuil isolée n'est PAS
    /// une pause au sens detraining ACSM — c'est un signal `missedSessions`
    /// (programme trop chargé / mauvais alignement rythme). RegressionRule
    /// gère ce cas en reduce 25%, pas PauseDetector en pauseLight 10%.
    func testCurrentLowWeekIsolatedTriggersMissedNotPause() {
        let current = RegenTestFixtures.makeReport(
            plannedActiveSessionCount: 3,
            completedSessionCount: 0,
            completionRate: 0.0,
            globalQuality: 0.0
        )
        let healthyPast = RegenTestFixtures.makeReport(
            weekNumber: 0,
            completionRate: 1.0,
            globalQuality: 90.0
        )
        let decision = WeeklyRegenEngine.regenerate(
            currentReport: current,
            previousReports: [healthyPast]
        )
        XCTAssertEqual(decision.pauseLevel, .none)
        XCTAssertEqual(decision.reason, .missedSessions)
        XCTAssertEqual(decision.adjustment, .reduce(percent: 0.25))
    }

    // MARK: - Days signal wins over history signal

    func testWorstSignalWinsBetweenDaysAndHistory() {
        // History dit "light" (1 sem sub-seuil), HK dit "extended" (20j).
        let current = RegenTestFixtures.makeReport(completionRate: 0.1)
        let decision = WeeklyRegenEngine.regenerate(
            currentReport: current,
            previousReports: [],
            daysSinceLastWorkout: 20
        )
        XCTAssertEqual(decision.pauseLevel, .extended)
        XCTAssertEqual(decision.reason, .pauseExtended)
    }

    // MARK: - Over-execution

    func testOverExecutionFlagTriggersSafetyReduce() {
        let report = RegenTestFixtures.makeReport(
            completionRate: 1.0,
            globalQuality: 95.0,
            overExecutedCount: 2,
            isOverallOverExecuted: true
        )
        let decision = WeeklyRegenEngine.regenerate(currentReport: report)
        XCTAssertEqual(decision.reason, .overExecuting)
        XCTAssertEqual(decision.adjustment, .reduce(percent: 0.10))
        XCTAssertEqual(decision.pauseLevel, .none)
    }

    // MARK: - Missed sessions

    func testMissedSessionsBelow50PercentTriggersReduce() {
        let report = RegenTestFixtures.makeReport(
            plannedActiveSessionCount: 4,
            completedSessionCount: 1,
            completionRate: 0.25,
            globalQuality: 80.0
        )
        let decision = WeeklyRegenEngine.regenerate(currentReport: report)
        XCTAssertEqual(decision.reason, .missedSessions)
        XCTAssertEqual(decision.adjustment, .reduce(percent: 0.25))
    }

    // MARK: - Low quality

    func testLowQualityWithEnoughSessionsTriggersMaintain() {
        let report = RegenTestFixtures.makeReport(
            plannedActiveSessionCount: 3,
            completedSessionCount: 3,
            completionRate: 1.0,
            globalQuality: 50.0
        )
        let decision = WeeklyRegenEngine.regenerate(currentReport: report)
        XCTAssertEqual(decision.reason, .lowQuality)
        XCTAssertEqual(decision.adjustment, .maintain)
        XCTAssertEqual(decision.multiplier, 1.0, accuracy: 0.0001)
    }

    // MARK: - Full rest week (planned)

    func testFullRestPlannedWeekDoesNotTriggerPauseFromHistory() {
        // Une semaine planifiée full rest (plannedActiveSessionCount=0) ne doit
        // PAS être comptée comme une semaine sub-seuil — c'est une décharge
        // voulue, pas un user qui décroche.
        let restWeek = RegenTestFixtures.makeReport(
            plannedActiveSessionCount: 0,
            completedSessionCount: 0,
            completionRate: 0.0,
            globalQuality: 0.0
        )
        let decision = WeeklyRegenEngine.regenerate(
            currentReport: restWeek,
            previousReports: []
        )
        XCTAssertEqual(decision.pauseLevel, .none)
        XCTAssertEqual(decision.reason, .onTrack)
        XCTAssertEqual(decision.pauseDetection.consecutiveLowWeeks, 0)
    }

    // MARK: - Cohérence chaînage : A.4 doit produire les mêmes signaux que les briques

    func testDecisionMatchesRegressionRuleForSameInputs() {
        let report = RegenTestFixtures.makeReport(
            completionRate: 1.0,
            globalQuality: 95.0
        )
        let regenDecision = WeeklyRegenEngine.regenerate(currentReport: report)
        let ruleDecision = RegressionRule.decide(
            currentWeek: report,
            pauseLevel: .none
        )
        XCTAssertEqual(regenDecision.adjustment, ruleDecision.adjustment)
        XCTAssertEqual(regenDecision.reason, ruleDecision.reason)
    }

    func testDecisionPropagatesPauseDetectorResult() {
        let report = RegenTestFixtures.makeReport()
        let regenDecision = WeeklyRegenEngine.regenerate(
            currentReport: report,
            daysSinceLastWorkout: 10
        )
        // A.4 passe `previousReports` (vide ici) à PauseDetector — pas le
        // currentReport. Comparer l'appel direct au même contrat.
        let detectorResult = PauseDetector.detect(
            recentReports: [],
            daysSinceLastWorkout: 10
        )
        XCTAssertEqual(regenDecision.pauseLevel, detectorResult.level)
        XCTAssertEqual(regenDecision.pauseDetection, detectorResult)
    }

    // MARK: - Pipeline complet (intégration avec WeeklyExecutionAnalyzer)

    func testFullPipelineEmptyWorkoutsProducesMissedDecision() {
        // 3 séances actives planifiées, 0 workouts HK → completionRate 0.0 →
        // < 0.50 → missedSessions reduce 25%.
        let sessions = [
            RegenTestFixtures.makeSession(day: 1, type: .endurance),
            RegenTestFixtures.makeSession(day: 3, type: .endurance),
            RegenTestFixtures.makeSession(day: 5, type: .endurance),
        ]
        let decision = WeeklyRegenEngine.regenerate(
            weekNumber: 2,
            weekStartDate: RegenTestFixtures.makeWeekStart(),
            sessions: sessions,
            sportCode: "running",
            workouts: [],
            hrMax: nil
        )
        XCTAssertEqual(decision.report.plannedActiveSessionCount, 3)
        XCTAssertEqual(decision.report.completedSessionCount, 0)
        XCTAssertEqual(decision.reason, .missedSessions)
        XCTAssertEqual(decision.adjustment, .reduce(percent: 0.25))
        XCTAssertEqual(decision.analyzedWeekNumber, 2)
        XCTAssertEqual(decision.targetWeekNumber, 3)
    }

    func testFullPipelinePropagatesReportAndDecisionTogether() {
        // Smoke test : avec sessions vides et pas de workout, le report doit
        // refléter "rest week" (plannedActive=0) et A.4 doit cascader en
        // onTrack default.
        let decision = WeeklyRegenEngine.regenerate(
            weekNumber: 1,
            weekStartDate: RegenTestFixtures.makeWeekStart(),
            sessions: [],
            sportCode: "running",
            workouts: [],
            hrMax: nil
        )
        XCTAssertEqual(decision.report.plannedActiveSessionCount, 0)
        XCTAssertEqual(decision.pauseLevel, .none)
        XCTAssertEqual(decision.reason, .onTrack)
    }
}
