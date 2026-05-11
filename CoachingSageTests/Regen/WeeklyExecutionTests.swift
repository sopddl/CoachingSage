// CoachingSageTests/Regen/WeeklyExecutionTests.swift
// Story 3.4 Phase A.1 — tests algo deterministic execution score (volume + intensité).
import XCTest
import TemplateModel
@testable import CoachingSage

final class WeeklyExecutionTests: XCTestCase {

    // MARK: - HRZoneMapper

    func testHRZoneMapperResolvesKnownDanielsZones() {
        XCTAssertEqual(HRZoneMapper.zone(for: "Daniels-E")?.lowPercent, 0.60)
        XCTAssertEqual(HRZoneMapper.zone(for: "daniels_e")?.highPercent, 0.75)
        XCTAssertEqual(HRZoneMapper.zone(for: "Daniels T")?.midpointPercent ?? 0, 0.85, accuracy: 0.01)
        XCTAssertEqual(HRZoneMapper.zone(for: "Daniels-I")?.lowPercent, 0.92)
    }

    func testHRZoneMapperResolvesZoneBased() {
        XCTAssertEqual(HRZoneMapper.zone(for: "Z2")?.lowPercent, 0.60)
        XCTAssertEqual(HRZoneMapper.zone(for: "Z4")?.highPercent, 0.90)
    }

    func testHRZoneMapperReturnsNilForUnknownOrEmpty() {
        XCTAssertNil(HRZoneMapper.zone(for: nil))
        XCTAssertNil(HRZoneMapper.zone(for: ""))
        XCTAssertNil(HRZoneMapper.zone(for: "RPE-7"))
        XCTAssertNil(HRZoneMapper.zone(for: "unknown"))
    }

    /// Zones composées (ex: "Daniels-E/T") non gérées V1 — retourne nil.
    func testHRZoneMapperRejectsMixedZone() {
        XCTAssertNil(HRZoneMapper.zone(for: "Daniels-E/T"))
        XCTAssertNil(HRZoneMapper.zone(for: "Z2/Z3"))
    }

    func testHRZoneMapperSessionTargetReturnsMostIntense() {
        let session = makeSession(targetZones: ["Z2", "Daniels-T", "Z1"])
        let zone = HRZoneMapper.sessionTargetZone(session)
        XCTAssertEqual(zone?.midpointPercent ?? 0, 0.85, accuracy: 0.01)
    }

    func testHRZoneMapperSessionTargetReturnsNilIfNoTargetZones() {
        let session = makeSession(targetZones: [nil, nil])
        XCTAssertNil(HRZoneMapper.sessionTargetZone(session))
    }

    func testHRZoneMapperSessionTargetReturnsNilForEmptyExercises() {
        let session = makeSession(targetZones: [])
        XCTAssertNil(HRZoneMapper.sessionTargetZone(session))
    }

    // MARK: - HRZone.proximity (maxDistance = 15% HRmax)

    func testHRZoneProximityReturns1WhenInsideZone() {
        let zone = HRZone(lowPercent: 0.60, highPercent: 0.75) // Daniels-E
        // HRmax = 200 → zone = 120-150 BPM
        XCTAssertEqual(zone.proximity(to: 135, hrMax: 200), 1.0)
        XCTAssertEqual(zone.proximity(to: 120, hrMax: 200), 1.0)
        XCTAssertEqual(zone.proximity(to: 150, hrMax: 200), 1.0)
    }

    func testHRZoneProximityDecaysOutsideZone() {
        let zone = HRZone(lowPercent: 0.60, highPercent: 0.75)
        // HRmax 200 → zone 120-150. HR avg 100 → distance 20 BPM.
        // maxDistance = 15% × 200 = 30 BPM. Normalized = 1 - 20/30 = 0.333.
        let proximity = zone.proximity(to: 100, hrMax: 200)
        XCTAssertEqual(proximity, 0.333, accuracy: 0.01)
    }

    func testHRZoneProximityReturns0WhenVeryFar() {
        let zone = HRZone(lowPercent: 0.60, highPercent: 0.75)
        // HR avg 240, distance 240-150 = 90. maxDistance = 30 → proximity = 0.
        XCTAssertEqual(zone.proximity(to: 240, hrMax: 200), 0.0)
    }

    // MARK: - ExecutionScore.weights (pondération par type session)

    func testWeightsByTypeIntervalIntensityPriority() {
        let weights = ExecutionScore.weights(for: .interval)
        XCTAssertEqual(weights.volume, 0.40)
        XCTAssertEqual(weights.intensity, 0.60)
    }

    func testWeightsByTypeEnduranceVolumePriority() {
        let weights = ExecutionScore.weights(for: .endurance)
        XCTAssertEqual(weights.volume, 0.70)
        XCTAssertEqual(weights.intensity, 0.30)
    }

    func testWeightsByTypeStrengthVolumePriority() {
        let weights = ExecutionScore.weights(for: .strength)
        XCTAssertEqual(weights.volume, 0.75)
        XCTAssertEqual(weights.intensity, 0.25)
    }

    func testWeightsByTypeMixedNeutral() {
        let weights = ExecutionScore.weights(for: .mixed)
        XCTAssertEqual(weights.volume, 0.50)
        XCTAssertEqual(weights.intensity, 0.50)
    }

    func testWeightsAlwaysSumToOne() {
        for type in SessionType.allCases {
            let w = ExecutionScore.weights(for: type)
            XCTAssertEqual(w.volume + w.intensity, 1.0, accuracy: 0.001,
                           "Weights for \(type) doit sommer à 1.0")
        }
    }

    // MARK: - ExecutionScore

    func testExecutionScoreVolumeOnlyWhenNoHRData() {
        // Session 30 min .endurance, workout 30 min, pas de HR → volume 100, overall = 100.
        let session = makeSession(durationMinutes: 30)
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 30, averageHeartRateBpm: nil,
            maxHeartRateBpm: nil, daysAgo: 1
        )
        let score = ExecutionScore.compute(session: session, workout: workout, hrMax: 200)
        XCTAssertEqual(score.volumePercent, 100.0)
        XCTAssertNil(score.intensityPercent)
        XCTAssertEqual(score.overallScore, 100.0)
        XCTAssertFalse(score.isOverExecuted)
    }

    func testExecutionScoreUnderExecution() {
        // Session 60 min, workout 30 min → volume 50%, pas de HR → overall = 50.
        let session = makeSession(durationMinutes: 60)
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 30, averageHeartRateBpm: nil,
            maxHeartRateBpm: nil, daysAgo: 1
        )
        let score = ExecutionScore.compute(session: session, workout: workout, hrMax: 200)
        XCTAssertEqual(score.volumePercent, 50.0)
        XCTAssertEqual(score.overallScore, 50.0)
        XCTAssertFalse(score.isOverExecuted)
    }

    func testExecutionScoreOverExecutionCappedAt100() {
        // Session 30 min, workout 60 min → volume 150% (raw), overall capped à 100.
        let session = makeSession(durationMinutes: 30)
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 60, averageHeartRateBpm: nil,
            maxHeartRateBpm: nil, daysAgo: 1
        )
        let score = ExecutionScore.compute(session: session, workout: workout, hrMax: 200)
        XCTAssertEqual(score.volumePercent, 150.0) // capped raw
        XCTAssertEqual(score.overallScore, 100.0)  // pas de bonus
        XCTAssertTrue(score.isOverExecuted, "Volume > 110% doit lever isOverExecuted")
    }

    func testExecutionScoreOverExecutionWithHR() {
        // Vérifie que isOverExecuted reste vrai même avec HR dans zone parfaite.
        let session = makeSession(durationMinutes: 30, type: .endurance, targetZones: ["Z3"])
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 60, averageHeartRateBpm: 150,
            maxHeartRateBpm: 160, daysAgo: 1
        )
        let score = ExecutionScore.compute(session: session, workout: workout, hrMax: 200)
        XCTAssertEqual(score.volumePercent, 150.0)
        XCTAssertTrue(score.isOverExecuted)
        // Endurance: volume capped 100 × 0.7 + intensity 100 × 0.3 = 100
        XCTAssertEqual(score.overallScore, 100.0, accuracy: 0.5)
    }

    func testExecutionScoreCombinesVolumeAndIntensityEndurance() {
        // Session 30 min .endurance Z3 (70-80% HRmax). HRmax 200 → zone 140-160 BPM.
        // Workout 30 min @ HR avg 150 → volume 100%, intensity 100%.
        // Endurance weights (0.7, 0.3) → overall = 100*0.7 + 100*0.3 = 100.
        let session = makeSession(durationMinutes: 30, type: .endurance, targetZones: ["Z3"])
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 30, averageHeartRateBpm: 150,
            maxHeartRateBpm: 160, daysAgo: 1
        )
        let score = ExecutionScore.compute(session: session, workout: workout, hrMax: 200)
        XCTAssertEqual(score.volumePercent, 100.0)
        XCTAssertEqual(score.intensityPercent ?? 0, 100.0, accuracy: 0.5)
        XCTAssertEqual(score.overallScore, 100.0, accuracy: 0.5)
    }

    func testExecutionScoreIntervalIntensityWeighsMore() {
        // Session .interval Daniels-T (82-88%). HRmax 200 → zone 164-176.
        // Workout HR avg 130 → distance 164-130=34, maxDist 30 → proximity 0.
        // Interval weights (0.4, 0.6) : volume 100*0.4 + intensity 0*0.6 = 40.
        let session = makeSession(durationMinutes: 30, type: .interval, targetZones: ["Daniels-T"])
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 30, averageHeartRateBpm: 130,
            maxHeartRateBpm: 145, daysAgo: 1
        )
        let score = ExecutionScore.compute(session: session, workout: workout, hrMax: 200)
        XCTAssertEqual(score.intensityPercent ?? 99, 0.0, accuracy: 1.0)
        XCTAssertEqual(score.overallScore, 40.0, accuracy: 1.0)
    }

    func testExecutionScoreEnduranceSameDataLessPenalty() {
        // Même setup que ci-dessus mais type .endurance (weights 0.7/0.3) :
        // overall = 100*0.7 + 0*0.3 = 70. Pénalité plus douce qu'en .interval.
        let session = makeSession(durationMinutes: 30, type: .endurance, targetZones: ["Daniels-T"])
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 30, averageHeartRateBpm: 130,
            maxHeartRateBpm: 145, daysAgo: 1
        )
        let score = ExecutionScore.compute(session: session, workout: workout, hrMax: 200)
        XCTAssertEqual(score.overallScore, 70.0, accuracy: 1.0)
    }

    // MARK: - WorkoutMatcher

    func testMatcherFindsCandidateForSameSportSameDate() {
        let weekStart = makeWeekStart()
        let session1 = makeSession(weekNumber: 1, day: 1, durationMinutes: 30)
        let session2 = makeSession(weekNumber: 1, day: 3, durationMinutes: 45)
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!

        // workout1 il y a 6 jours (= day 1), workout2 il y a 4 jours (= day 3)
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 28,
                                          averageHeartRateBpm: 140, maxHeartRateBpm: 165, daysAgo: 6),
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 45,
                                          averageHeartRateBpm: 150, maxHeartRateBpm: 170, daysAgo: 4)
        ]
        let matches = WorkoutMatcher.match(
            sessions: [session1, session2], sportCode: "running",
            workouts: workouts, weekStartDate: weekStart, hrMax: 200, now: now
        )
        XCTAssertEqual(matches.count, 2)
        XCTAssertTrue(matches[0].isDone)
        XCTAssertTrue(matches[1].isDone)
        XCTAssertEqual(matches[0].workout?.durationMinutes, 28)
        XCTAssertEqual(matches[1].workout?.durationMinutes, 45)
    }

    func testMatcherSkipsWrongSport() {
        let weekStart = makeWeekStart()
        let session = makeSession(weekNumber: 1, day: 1, durationMinutes: 30)
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "cycling", durationMinutes: 30,
                                          averageHeartRateBpm: 140, maxHeartRateBpm: 160, daysAgo: 6)
        ]
        let matches = WorkoutMatcher.match(
            sessions: [session], sportCode: "running",
            workouts: workouts, weekStartDate: weekStart, hrMax: 200, now: now
        )
        XCTAssertEqual(matches.count, 1)
        XCTAssertFalse(matches[0].isDone)
    }

    func testMatcherSkipsTooFarInTime() {
        let weekStart = makeWeekStart()
        let session = makeSession(weekNumber: 1, day: 1, durationMinutes: 30)
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        // Workout il y a 1 jour = 5 jours après day 1, > tolerance ±2j
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: 140, maxHeartRateBpm: 160, daysAgo: 1)
        ]
        let matches = WorkoutMatcher.match(
            sessions: [session], sportCode: "running",
            workouts: workouts, weekStartDate: weekStart, hrMax: 200, now: now
        )
        XCTAssertFalse(matches[0].isDone)
    }

    func testMatcherToleranceExactlyAt2Days() {
        // Limite supérieure de la tolerance : distance = 2 → match accepté.
        // Distance = 3 → match refusé.
        let weekStart = makeWeekStart()
        let session = makeSession(weekNumber: 1, day: 1, durationMinutes: 30)
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        // session day 1 = weekStart (jour 0 depuis weekStart). Distance 2j = workout J+2 = 4 jours avant now.
        let workoutAt2Days = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: 140, maxHeartRateBpm: 160, daysAgo: 4)
        ]
        let matchAt2 = WorkoutMatcher.match(
            sessions: [session], sportCode: "running",
            workouts: workoutAt2Days, weekStartDate: weekStart, hrMax: 200, now: now
        )
        XCTAssertTrue(matchAt2[0].isDone, "Distance exactement 2 doit matcher")

        // Distance 3 (workout J+3 = 3 jours avant now)
        let workoutAt3Days = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: 140, maxHeartRateBpm: 160, daysAgo: 3)
        ]
        let matchAt3 = WorkoutMatcher.match(
            sessions: [session], sportCode: "running",
            workouts: workoutAt3Days, weekStartDate: weekStart, hrMax: 200, now: now
        )
        XCTAssertFalse(matchAt3[0].isDone, "Distance 3 doit dépasser tolerance ±2")
    }

    func testMatcherDoesNotDoubleMatchAWorkout() {
        let weekStart = makeWeekStart()
        let session1 = makeSession(weekNumber: 1, day: 1, durationMinutes: 30)
        let session2 = makeSession(weekNumber: 1, day: 1, durationMinutes: 30)
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: 140, maxHeartRateBpm: 160, daysAgo: 6)
        ]
        let matches = WorkoutMatcher.match(
            sessions: [session1, session2], sportCode: "running",
            workouts: workouts, weekStartDate: weekStart, hrMax: 200, now: now
        )
        let matchedCount = matches.filter(\.isDone).count
        XCTAssertEqual(matchedCount, 1)
    }

    /// Cas où le greedy par ordre échouait : session1 à distance 1, session2 à
    /// distance 0 pour le même workout. Le matcher doit donner le workout à
    /// session2 (distance 0), pas à session1.
    func testMatcherGloballyOptimalNotGreedyByOrder() {
        let weekStart = makeWeekStart()
        // session1 day 1 (date = weekStart + 0j)
        // session2 day 2 (date = weekStart + 1j)
        let session1 = makeSession(weekNumber: 1, day: 1, durationMinutes: 30)
        let session2 = makeSession(weekNumber: 1, day: 2, durationMinutes: 30)
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        // 1 workout exactement le jour de session2 (daysAgo=5 = weekStart+1).
        // session1 = distance 1, session2 = distance 0 → session2 doit gagner.
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: 140, maxHeartRateBpm: 160, daysAgo: 5)
        ]
        let matches = WorkoutMatcher.match(
            sessions: [session1, session2], sportCode: "running",
            workouts: workouts, weekStartDate: weekStart, hrMax: 200, now: now
        )
        XCTAssertFalse(matches[0].isDone, "session1 ne doit PAS prendre le workout (distance 1)")
        XCTAssertTrue(matches[1].isDone, "session2 doit prendre le workout (distance 0)")
    }

    func testMatcherEmptyWorkoutsAllSessionsUnmatched() {
        let weekStart = makeWeekStart()
        let sessions = [
            makeSession(weekNumber: 1, day: 1, durationMinutes: 30),
            makeSession(weekNumber: 1, day: 3, durationMinutes: 45),
            makeSession(weekNumber: 1, day: 5, durationMinutes: 60)
        ]
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        let matches = WorkoutMatcher.match(
            sessions: sessions, sportCode: "running",
            workouts: [], weekStartDate: weekStart, hrMax: 200, now: now
        )
        XCTAssertEqual(matches.count, 3)
        XCTAssertTrue(matches.allSatisfy { !$0.isDone })
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
