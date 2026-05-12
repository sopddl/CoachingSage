// CoachingSageTests/Regen/WeeklyExecutionAnalyzerTests.swift
// Story 3.4 Phase A.2 — tests agrégation hebdo (completionRate, globalQuality
// pondéré par durée, overExecutedCount, missedActiveSessions).
import XCTest
import TemplateModel
@testable import CoachingSage

final class WeeklyExecutionAnalyzerTests: XCTestCase {

    // MARK: - Cas standard

    func testAnalyzeFullCompletionPerfectQuality() {
        // 3 sessions endurance Z3, toutes réalisées pile dans la zone.
        let weekStart = makeWeekStart()
        let sessions = [
            makeSession(day: 1, durationMinutes: 30, type: .endurance, targetZones: ["Z3"]),
            makeSession(day: 3, durationMinutes: 45, type: .endurance, targetZones: ["Z3"]),
            makeSession(day: 5, durationMinutes: 60, type: .endurance, targetZones: ["Z3"])
        ]
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: 150, maxHeartRateBpm: 160, daysAgo: 6),
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 45,
                                          averageHeartRateBpm: 150, maxHeartRateBpm: 160, daysAgo: 4),
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 60,
                                          averageHeartRateBpm: 150, maxHeartRateBpm: 160, daysAgo: 2)
        ]

        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            sessions: sessions,
            sportCode: "running",
            workouts: workouts,
            hrMax: 200,
            now: now
        )

        XCTAssertEqual(report.plannedSessionCount, 3)
        XCTAssertEqual(report.plannedActiveSessionCount, 3)
        XCTAssertEqual(report.completedSessionCount, 3)
        XCTAssertEqual(report.completionRate, 1.0)
        XCTAssertEqual(report.globalQuality, 100.0, accuracy: 0.5)
        XCTAssertEqual(report.overExecutedCount, 0)
        XCTAssertFalse(report.isOverallOverExecuted)
        XCTAssertTrue(report.missedActiveSessions.isEmpty)
    }

    func testAnalyzePartialCompletionLowQuality() {
        // 4 sessions planifiées, 2 réalisées (sous-performées), 2 manquées.
        // CompletionRate = 0.5, globalQuality reflète seulement les 2 réalisées.
        let weekStart = makeWeekStart()
        let sessions = [
            makeSession(day: 1, durationMinutes: 30, type: .endurance),
            makeSession(day: 3, durationMinutes: 30, type: .endurance),
            makeSession(day: 5, durationMinutes: 30, type: .endurance),
            makeSession(day: 6, durationMinutes: 30, type: .endurance)
        ]
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        // Workouts à 50% du volume planifié (15 min sur 30) — pas de HR.
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 15,
                                          averageHeartRateBpm: nil, maxHeartRateBpm: nil, daysAgo: 6),
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 15,
                                          averageHeartRateBpm: nil, maxHeartRateBpm: nil, daysAgo: 4)
        ]
        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            sessions: sessions,
            sportCode: "running",
            workouts: workouts,
            hrMax: 200,
            now: now
        )

        XCTAssertEqual(report.plannedActiveSessionCount, 4)
        XCTAssertEqual(report.completedSessionCount, 2)
        XCTAssertEqual(report.completionRate, 0.5)
        // Chaque match : volume 50%, pas de HR → overallScore = 50.
        XCTAssertEqual(report.globalQuality, 50.0, accuracy: 0.5)
        XCTAssertEqual(report.overExecutedCount, 0)
        XCTAssertEqual(report.missedActiveSessions.count, 2)
    }

    func testAnalyzeWeightingByDuration() {
        // 2 sessions complétées de durées différentes (30 vs 60 min).
        // 30 min score 100, 60 min score 40 → moyenne pondérée
        // = (100*30 + 40*60) / (30+60) = (3000 + 2400)/90 = 60
        // (vs moyenne arithmétique simple = 70).
        let weekStart = makeWeekStart()
        let sessionShort = makeSession(day: 1, durationMinutes: 30, type: .endurance, targetZones: ["Z3"])
        let sessionLong = makeSession(day: 3, durationMinutes: 60, type: .interval, targetZones: ["Daniels-T"])
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        // workout1 : 30 min, HR 150 → endurance Z3 (140-160) pile, volume 100,
        //   intensité 100 → score 100.
        // workout2 : 60 min, HR 130 → interval Daniels-T (164-176), zone manquée,
        //   intensité 0, volume 100 → score interval 100*0.4 + 0*0.6 = 40.
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: 150, maxHeartRateBpm: 160, daysAgo: 6),
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 60,
                                          averageHeartRateBpm: 130, maxHeartRateBpm: 145, daysAgo: 4)
        ]
        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            sessions: [sessionShort, sessionLong],
            sportCode: "running",
            workouts: workouts,
            hrMax: 200,
            now: now
        )

        XCTAssertEqual(report.completedSessionCount, 2)
        XCTAssertEqual(report.globalQuality, 60.0, accuracy: 1.0,
                       "Pondération par durée doit donner ~60, pas 70 (moyenne simple)")
    }

    // MARK: - Edge cases : aucune session, full rest, aucun workout

    func testAnalyzeNoPlannedSessionsReturnsEmptyReport() {
        let weekStart = makeWeekStart()
        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            sessions: [],
            sportCode: "running",
            workouts: [],
            hrMax: 200,
            now: weekStart
        )
        XCTAssertEqual(report.plannedSessionCount, 0)
        XCTAssertEqual(report.plannedActiveSessionCount, 0)
        XCTAssertEqual(report.completionRate, 0.0)
        XCTAssertEqual(report.globalQuality, 0.0)
        XCTAssertFalse(report.isOverallOverExecuted)
        XCTAssertTrue(report.matches.isEmpty)
    }

    func testAnalyzeFullRestWeekZeroActiveSessions() {
        // Semaine de déload : 7 jours .rest. Pas d'actives → completionRate doit
        // rester 0 (et non NaN ou crash).
        let weekStart = makeWeekStart()
        let sessions = (1...7).map { day in
            makeSession(day: day, durationMinutes: 0, type: .rest, targetZones: [])
        }
        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            sessions: sessions,
            sportCode: "running",
            workouts: [],
            hrMax: 200,
            now: weekStart
        )
        XCTAssertEqual(report.plannedSessionCount, 7)
        XCTAssertEqual(report.plannedActiveSessionCount, 0)
        XCTAssertEqual(report.completionRate, 0.0)
        XCTAssertTrue(report.missedActiveSessions.isEmpty,
                      "Une session rest non réalisée ne doit pas compter comme missed")
    }

    func testAnalyzeNoWorkoutsAllSessionsMissed() {
        // 3 sessions planifiées, aucun workout HK : completionRate 0, globalQuality 0,
        // missedActiveSessions = 3.
        let weekStart = makeWeekStart()
        let sessions = [
            makeSession(day: 1, durationMinutes: 30, type: .endurance),
            makeSession(day: 3, durationMinutes: 45, type: .interval),
            makeSession(day: 5, durationMinutes: 60, type: .endurance)
        ]
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            sessions: sessions,
            sportCode: "running",
            workouts: [],
            hrMax: 200,
            now: now
        )
        XCTAssertEqual(report.plannedActiveSessionCount, 3)
        XCTAssertEqual(report.completedSessionCount, 0)
        XCTAssertEqual(report.completionRate, 0.0)
        XCTAssertEqual(report.globalQuality, 0.0)
        XCTAssertEqual(report.missedActiveSessions.count, 3)
        XCTAssertFalse(report.isOverallOverExecuted)
    }

    // MARK: - missedActiveSessions exclut .rest

    func testMissedActiveSessionsExcludeRest() {
        // Semaine mixte : 2 endurance + 1 rest. Aucun workout → 2 missed actives,
        // pas 3 (rest ne compte pas).
        let weekStart = makeWeekStart()
        let sessions = [
            makeSession(day: 1, durationMinutes: 30, type: .endurance),
            makeSession(day: 3, durationMinutes: 0, type: .rest),
            makeSession(day: 5, durationMinutes: 45, type: .endurance)
        ]
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            sessions: sessions,
            sportCode: "running",
            workouts: [],
            hrMax: 200,
            now: now
        )
        XCTAssertEqual(report.missedActiveSessions.count, 2)
        XCTAssertEqual(report.missedActiveSessions.map(\.day), [1, 5])
    }

    // MARK: - Over-execution

    func testIsOverallOverExecutedTrueWhenAllOverVolume() {
        // 2 sessions 30 min planifiées, 2 workouts 60 min (=200% volume).
        // Chaque match : volumePercent 200, isOverExecuted true.
        // overExecutedCount=2, completedCount=2 → 2*2=4 >= 2 → true.
        let weekStart = makeWeekStart()
        let sessions = [
            makeSession(day: 1, durationMinutes: 30, type: .endurance),
            makeSession(day: 3, durationMinutes: 30, type: .endurance)
        ]
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 60,
                                          averageHeartRateBpm: nil, maxHeartRateBpm: nil, daysAgo: 6),
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 60,
                                          averageHeartRateBpm: nil, maxHeartRateBpm: nil, daysAgo: 4)
        ]
        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            sessions: sessions,
            sportCode: "running",
            workouts: workouts,
            hrMax: 200,
            now: now
        )
        XCTAssertEqual(report.overExecutedCount, 2)
        XCTAssertTrue(report.isOverallOverExecuted)
        // Volume capped 100 dans le composite → globalQuality = 100.
        XCTAssertEqual(report.globalQuality, 100.0, accuracy: 0.5)
    }

    func testIsOverallOverExecutedFalseWhenOnlyOneOfThree() {
        // 3 sessions, 1 over-réalisée, 2 normales → 1*2=2, completedCount=3 →
        // 2 >= 3 ? false. Pas d'over global.
        let weekStart = makeWeekStart()
        let sessions = [
            makeSession(day: 1, durationMinutes: 30, type: .endurance),
            makeSession(day: 3, durationMinutes: 30, type: .endurance),
            makeSession(day: 5, durationMinutes: 30, type: .endurance)
        ]
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 60,
                                          averageHeartRateBpm: nil, maxHeartRateBpm: nil, daysAgo: 6),
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: nil, maxHeartRateBpm: nil, daysAgo: 4),
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: nil, maxHeartRateBpm: nil, daysAgo: 2)
        ]
        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            sessions: sessions,
            sportCode: "running",
            workouts: workouts,
            hrMax: 200,
            now: now
        )
        XCTAssertEqual(report.overExecutedCount, 1)
        XCTAssertFalse(report.isOverallOverExecuted,
                       "Une seule séance over sur trois ne doit pas déclencher le flag global")
    }

    func testIsOverallOverExecutedFalseWhenNothingCompleted() {
        // Aucune réalisation → pas de flag, même si overExecutedCount serait
        // mathématiquement 0 (pas de séances complétées).
        let weekStart = makeWeekStart()
        let sessions = [makeSession(day: 1, durationMinutes: 30, type: .endurance)]
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            sessions: sessions,
            sportCode: "running",
            workouts: [],
            hrMax: 200,
            now: now
        )
        XCTAssertFalse(report.isOverallOverExecuted)
    }

    // MARK: - Matches passthrough (utile à A.3 et UI)

    func testMatchesArePreservedInReport() {
        let weekStart = makeWeekStart()
        let sessions = [
            makeSession(day: 1, durationMinutes: 30, type: .endurance),
            makeSession(day: 3, durationMinutes: 45, type: .endurance)
        ]
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: nil, maxHeartRateBpm: nil, daysAgo: 6)
        ]
        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            sessions: sessions,
            sportCode: "running",
            workouts: workouts,
            hrMax: 200,
            now: now
        )
        XCTAssertEqual(report.matches.count, 2)
        XCTAssertTrue(report.matches[0].isDone)
        XCTAssertFalse(report.matches[1].isDone)
        XCTAssertEqual(report.completedMatches.count, 1)
    }

    // MARK: - Overload analyze(matches:) — utile pour A.4 / tests réutilisant matches

    func testAnalyzeWithPrecomputedMatches() {
        // Construit des matches "à la main" et vérifie que l'analyse les agrège.
        let weekStart = makeWeekStart()
        let session1 = makeSession(day: 1, durationMinutes: 30, type: .endurance)
        let session2 = makeSession(day: 3, durationMinutes: 60, type: .endurance)
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 30,
            averageHeartRateBpm: nil, maxHeartRateBpm: nil, daysAgo: 6
        )
        // session1 matché à 100, session2 non matché
        let match1 = WorkoutMatch(
            session: session1,
            workout: workout,
            executionScore: ExecutionScore(
                volumePercent: 100, intensityPercent: nil, overallScore: 100
            )
        )
        let match2 = WorkoutMatch(session: session2, workout: nil, executionScore: nil)

        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: 1,
            weekStartDate: weekStart,
            matches: [match1, match2]
        )
        XCTAssertEqual(report.plannedActiveSessionCount, 2)
        XCTAssertEqual(report.completedSessionCount, 1)
        XCTAssertEqual(report.completionRate, 0.5)
        // 1 seule séance complétée — score 100, weight 30 → globalQuality 100.
        XCTAssertEqual(report.globalQuality, 100.0)
        XCTAssertEqual(report.missedActiveSessions.count, 1)
    }

    // MARK: - Helpers

    /// Lundi 1er juillet 2024, 00:00 local — date stable pour les tests.
    func makeWeekStart() -> Date {
        var components = DateComponents()
        components.year = 2024
        components.month = 7
        components.day = 1
        components.hour = 0
        return Calendar.current.date(from: components)!
    }

    func makeSession(
        weekNumber: Int = 1,
        day: Int = 1,
        durationMinutes: Int = 30,
        type: SessionType = .endurance,
        targetZones: [String?] = []
    ) -> PersistedSession {
        let exercises = targetZones.map { zone in
            AdaptedExercise(
                name: "Test exercise",
                originalName: "Test exercise",
                targetZone: zone
            )
        }
        return PersistedSession(
            weekNumber: weekNumber,
            weekTheme: "test theme",
            weekGoal: "test goal",
            day: day,
            name: "Test session",
            durationMinutes: durationMinutes,
            type: type,
            warmup: nil,
            exercises: exercises,
            cooldown: nil
        )
    }
}
