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

    func testHRZoneMapperSessionTargetReturnsMostIntense() {
        // Session avec 3 exos : Z2 (easy), Daniels-T (tempo), Z1 (recovery)
        // → pic d'intensité Daniels-T (midpoint 85%).
        let session = makeSession(targetZones: ["Z2", "Daniels-T", "Z1"])
        let zone = HRZoneMapper.sessionTargetZone(session)
        XCTAssertEqual(zone?.midpointPercent ?? 0, 0.85, accuracy: 0.01)
    }

    func testHRZoneMapperSessionTargetReturnsNilIfNoTargetZones() {
        let session = makeSession(targetZones: [nil, nil])
        XCTAssertNil(HRZoneMapper.sessionTargetZone(session))
    }

    // MARK: - HRZone.proximity

    func testHRZoneProximityReturns1WhenInsideZone() {
        let zone = HRZone(lowPercent: 0.60, highPercent: 0.75) // Daniels-E
        // HRmax = 200 → zone = 120-150 BPM
        XCTAssertEqual(zone.proximity(to: 135, hrMax: 200), 1.0)
        XCTAssertEqual(zone.proximity(to: 120, hrMax: 200), 1.0)
        XCTAssertEqual(zone.proximity(to: 150, hrMax: 200), 1.0)
    }

    func testHRZoneProximityDecaysOutsideZone() {
        let zone = HRZone(lowPercent: 0.60, highPercent: 0.75)
        // HRmax = 200 → zone 120-150. HR avg = 100 → distance 20 BPM = 10% HRmax.
        // Max distance = 30% HRmax = 60 BPM. Normalized = 1 - 20/60 = 0.667.
        let proximity = zone.proximity(to: 100, hrMax: 200)
        XCTAssertEqual(proximity, 0.667, accuracy: 0.01)
    }

    func testHRZoneProximityReturns0WhenVeryFar() {
        let zone = HRZone(lowPercent: 0.60, highPercent: 0.75)
        // HR avg = 240, way above. Distance 240-150=90 BPM = 45% HRmax > maxDistance.
        XCTAssertEqual(zone.proximity(to: 240, hrMax: 200), 0.0)
    }

    // MARK: - ExecutionScore

    func testExecutionScoreVolumeOnlyWhenNoHRData() {
        // Session 30 min, workout 30 min, pas de HR → volume 100%, intensity nil, overall = 100.
        let session = makeSession(durationMinutes: 30)
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 30, averageHeartRateBpm: nil,
            maxHeartRateBpm: nil, daysAgo: 1
        )
        let score = ExecutionScore.compute(session: session, workout: workout, hrMax: 200)
        XCTAssertEqual(score.volumePercent, 100.0)
        XCTAssertNil(score.intensityPercent)
        XCTAssertEqual(score.overallScore, 100.0)
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
    }

    func testExecutionScoreOverExecutionCappedAt100() {
        // Session 30 min, workout 60 min → volume 200% clampé à 150% côté
        // raw mais le overall ne bonusse pas au-delà de 100% volume.
        let session = makeSession(durationMinutes: 30)
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 60, averageHeartRateBpm: nil,
            maxHeartRateBpm: nil, daysAgo: 1
        )
        let score = ExecutionScore.compute(session: session, workout: workout, hrMax: 200)
        XCTAssertEqual(score.volumePercent, 150.0) // capped raw
        XCTAssertEqual(score.overallScore, 100.0)  // pas de bonus over-training
    }

    func testExecutionScoreCombinesVolumeAndIntensity() {
        // Session 30 min, Z3 (70-80% HRmax). HRmax 200 → zone 140-160 BPM.
        // Workout 30 min @ HR avg 150 → volume 100%, intensity 100% → overall 100.
        let session = makeSession(durationMinutes: 30, targetZones: ["Z3"])
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 30, averageHeartRateBpm: 150,
            maxHeartRateBpm: 160, daysAgo: 1
        )
        let score = ExecutionScore.compute(session: session, workout: workout, hrMax: 200)
        XCTAssertEqual(score.volumePercent, 100.0)
        XCTAssertEqual(score.intensityPercent ?? 0, 100.0, accuracy: 0.5)
        XCTAssertEqual(score.overallScore, 100.0, accuracy: 0.5)
    }

    func testExecutionScorePenalizesOffZone() {
        // Session Daniels-T (82-88%). HRmax 200 → zone 164-176.
        // Workout HR avg 130 → bien sous la zone, intensity réduite.
        let session = makeSession(durationMinutes: 30, targetZones: ["Daniels-T"])
        let workout = HealthSummary.WorkoutSnapshot(
            sportCode: "running", durationMinutes: 30, averageHeartRateBpm: 130,
            maxHeartRateBpm: 145, daysAgo: 1
        )
        let score = ExecutionScore.compute(session: session, workout: workout, hrMax: 200)
        // Volume 100% pondéré 0.6 = 60. Intensity proximity = 1-(164-130)/60 = 0.433 → 43.3 pondéré 0.4 = 17.3.
        // Overall ~ 60 + 17.3 = 77.3.
        XCTAssertLessThan(score.overallScore, 90.0)
        XCTAssertGreaterThan(score.overallScore, 60.0)
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
            sessions: [session1, session2],
            sportCode: "running",
            workouts: workouts,
            weekStartDate: weekStart,
            hrMax: 200,
            now: now
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
            sessions: [session],
            sportCode: "running",
            workouts: workouts,
            weekStartDate: weekStart,
            hrMax: 200,
            now: now
        )
        XCTAssertEqual(matches.count, 1)
        XCTAssertFalse(matches[0].isDone, "Workout cycling ne doit pas matcher session running")
    }

    func testMatcherSkipsTooFarInTime() {
        let weekStart = makeWeekStart()
        let session = makeSession(weekNumber: 1, day: 1, durationMinutes: 30) // jour 1 = weekStart
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
        // Workout il y a 1 jour = 5 jours après day 1, > tolerance ±2j
        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: 140, maxHeartRateBpm: 160, daysAgo: 1)
        ]

        let matches = WorkoutMatcher.match(
            sessions: [session],
            sportCode: "running",
            workouts: workouts,
            weekStartDate: weekStart,
            hrMax: 200,
            now: now
        )
        XCTAssertFalse(matches[0].isDone)
    }

    func testMatcherDoesNotDoubleMatchAWorkout() {
        // 2 sessions running mêmes jours, 1 seul workout → 1 seul matché.
        let weekStart = makeWeekStart()
        let session1 = makeSession(weekNumber: 1, day: 1, durationMinutes: 30)
        let session2 = makeSession(weekNumber: 1, day: 1, durationMinutes: 30)
        let now = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!

        let workouts = [
            HealthSummary.WorkoutSnapshot(sportCode: "running", durationMinutes: 30,
                                          averageHeartRateBpm: 140, maxHeartRateBpm: 160, daysAgo: 6)
        ]
        let matches = WorkoutMatcher.match(
            sessions: [session1, session2],
            sportCode: "running",
            workouts: workouts,
            weekStartDate: weekStart,
            hrMax: 200,
            now: now
        )
        let matchedCount = matches.filter(\.isDone).count
        XCTAssertEqual(matchedCount, 1, "Un workout ne doit matcher qu'une session")
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
            sessions: sessions,
            sportCode: "running",
            workouts: [],
            weekStartDate: weekStart,
            hrMax: 200,
            now: now
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
            type: .endurance,
            warmup: nil,
            exercises: exercises,
            cooldown: nil
        )
    }
}
