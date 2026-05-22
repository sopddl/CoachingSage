// CoachingSageTests/Coaching/AI/HealthSummaryBuilderTests.swift
// Story 3.3b — tests unitaires builder résumé HK pour Léon. Mock service avec
// retour configurable, on vérifie : bucketization VO2max, snapshot workout,
// agrégation max HR, gestion gracieuse des données absentes.
//
// IMPORTANT : ces tests ne valident PAS l'absence d'interprétation médicale —
// le builder est purement factuel (pas de champ "anormal", pas de score santé).
// L'assertion anti-interprétation par Léon LUI-MÊME se fait dans les tests
// critiques `LeonAdaptRareTests` (Edge Function + prompt système).
import XCTest
import HealthKit

@MainActor
final class HealthSummaryBuilderTests: XCTestCase {

    // MARK: - Bucketization VO2max

    func testVO2MaxBucketBeginner() {
        XCTAssertEqual(HealthSummary.VO2MaxBucket(value: 25), .beginner)
        XCTAssertEqual(HealthSummary.VO2MaxBucket(value: 29.9), .beginner)
    }

    func testVO2MaxBucketIntermediate() {
        XCTAssertEqual(HealthSummary.VO2MaxBucket(value: 30), .intermediate)
        XCTAssertEqual(HealthSummary.VO2MaxBucket(value: 44.9), .intermediate)
    }

    func testVO2MaxBucketAdvanced() {
        XCTAssertEqual(HealthSummary.VO2MaxBucket(value: 45), .advanced)
        XCTAssertEqual(HealthSummary.VO2MaxBucket(value: 54.9), .advanced)
    }

    func testVO2MaxBucketElite() {
        XCTAssertEqual(HealthSummary.VO2MaxBucket(value: 55), .elite)
        XCTAssertEqual(HealthSummary.VO2MaxBucket(value: 70), .elite)
    }

    // MARK: - Sport mapping

    func testMapsRunningCyclingSwimming() {
        XCTAssertEqual(DefaultHealthSummaryBuilder.mapToSportCode(HKWorkoutActivityType.running.rawValue), "running")
        XCTAssertEqual(DefaultHealthSummaryBuilder.mapToSportCode(HKWorkoutActivityType.cycling.rawValue), "cycling")
        XCTAssertEqual(DefaultHealthSummaryBuilder.mapToSportCode(HKWorkoutActivityType.swimming.rawValue), "swimming")
    }

    func testMapsStrengthVariantsToStrengthTraining() {
        XCTAssertEqual(
            DefaultHealthSummaryBuilder.mapToSportCode(HKWorkoutActivityType.functionalStrengthTraining.rawValue),
            "strength_training"
        )
        XCTAssertEqual(
            DefaultHealthSummaryBuilder.mapToSportCode(HKWorkoutActivityType.traditionalStrengthTraining.rawValue),
            "strength_training"
        )
        XCTAssertEqual(
            DefaultHealthSummaryBuilder.mapToSportCode(HKWorkoutActivityType.crossTraining.rawValue),
            "strength_training"
        )
    }

    func testMapsHIITAndHikingAndFootballVariants() {
        XCTAssertEqual(
            DefaultHealthSummaryBuilder.mapToSportCode(HKWorkoutActivityType.highIntensityIntervalTraining.rawValue),
            "hiit"
        )
        XCTAssertEqual(DefaultHealthSummaryBuilder.mapToSportCode(HKWorkoutActivityType.hiking.rawValue), "hiking")
        XCTAssertEqual(DefaultHealthSummaryBuilder.mapToSportCode(HKWorkoutActivityType.soccer.rawValue), "football")
        XCTAssertEqual(
            DefaultHealthSummaryBuilder.mapToSportCode(HKWorkoutActivityType.americanFootball.rawValue),
            "football"
        )
    }

    func testMapsUnknownActivityToNil() {
        // .barre n'est pas dans le catalogue V1 → nil, Léon ignorera l'item.
        XCTAssertNil(DefaultHealthSummaryBuilder.mapToSportCode(HKWorkoutActivityType.barre.rawValue))
    }

    // MARK: - Build empty

    func testBuildSummaryWithEmptyHealthKitReturnsBlankFields() async {
        let mock = MockHealthKitService()  // tous les fetch retournent nil/empty/[]
        let builder = DefaultHealthSummaryBuilder(healthKit: mock)

        let summary = await builder.buildSummary()

        XCTAssertNil(summary.vo2maxBucket)
        XCTAssertNil(summary.restingHeartRateBpm)
        XCTAssertNil(summary.maxObservedHeartRateBpm)
        XCTAssertNil(summary.weeklyWorkoutsAverage4w)
        XCTAssertEqual(summary.recentWorkouts.count, 0)
        XCTAssertFalse(summary.hasAppleWatch)
    }

    // MARK: - Build complet

    func testBuildSummaryWithRichHealthKitData() async {
        let mock = MockHealthKitService()
        mock.stubbedVO2MaxSample = HealthKitVO2MaxSample(value: 48.0, date: Date(), sourceName: "Watch")
        mock.stubbedWorkoutSummary = HealthKitWorkoutSummary(
            totalCount: 12,
            weeklyAverage: 3.0,
            dominantActivityRawValue: HKWorkoutActivityType.running.rawValue,
            appleWatchDetected: true
        )
        mock.stubbedRestingHeartRateAverage = 58.4
        mock.stubbedRecentWorkoutDetails = [
            HealthKitWorkoutDetail(
                activityTypeRawValue: HKWorkoutActivityType.running.rawValue,
                durationMinutes: 32,
                averageHeartRateBpm: 152,
                maxHeartRateBpm: 178,
                daysAgo: 1,
                fromAppleWatch: true
            ),
            HealthKitWorkoutDetail(
                activityTypeRawValue: HKWorkoutActivityType.cycling.rawValue,
                durationMinutes: 60,
                averageHeartRateBpm: 138,
                maxHeartRateBpm: 165,
                daysAgo: 3,
                fromAppleWatch: true
            ),
            HealthKitWorkoutDetail(
                activityTypeRawValue: HKWorkoutActivityType.functionalStrengthTraining.rawValue,
                durationMinutes: 45,
                averageHeartRateBpm: 130,
                maxHeartRateBpm: 190,
                daysAgo: 5,
                fromAppleWatch: true
            )
        ]

        let summary = await DefaultHealthSummaryBuilder(healthKit: mock).buildSummary()

        XCTAssertEqual(summary.vo2maxBucket, .advanced)             // 48 → advanced
        XCTAssertEqual(summary.restingHeartRateBpm, 58)             // arrondi
        XCTAssertEqual(summary.maxObservedHeartRateBpm, 190)        // max sur les 3 workouts
        XCTAssertEqual(summary.weeklyWorkoutsAverage4w, 3.0)
        XCTAssertEqual(summary.recentWorkouts.count, 3)
        XCTAssertEqual(summary.recentWorkouts[0].sportCode, "running")
        XCTAssertEqual(summary.recentWorkouts[1].sportCode, "cycling")
        XCTAssertEqual(summary.recentWorkouts[2].sportCode, "strength_training")
        XCTAssertTrue(summary.hasAppleWatch)
    }

    // MARK: - Edge cases

    func testWeeklyAverageIsNilWhenSummaryHasZeroWorkouts() async {
        let mock = MockHealthKitService()
        mock.stubbedWorkoutSummary = HealthKitWorkoutSummary(
            totalCount: 0,
            weeklyAverage: 0.0,
            dominantActivityRawValue: nil,
            appleWatchDetected: false
        )

        let summary = await DefaultHealthSummaryBuilder(healthKit: mock).buildSummary()

        XCTAssertNil(summary.weeklyWorkoutsAverage4w)
    }

    func testMaxObservedHeartRateIsNilWhenNoWorkoutsHaveHR() async {
        let mock = MockHealthKitService()
        mock.stubbedRecentWorkoutDetails = [
            HealthKitWorkoutDetail(
                activityTypeRawValue: HKWorkoutActivityType.running.rawValue,
                durationMinutes: 30,
                averageHeartRateBpm: nil,
                maxHeartRateBpm: nil,
                daysAgo: 2,
                fromAppleWatch: false
            )
        ]

        let summary = await DefaultHealthSummaryBuilder(healthKit: mock).buildSummary()

        XCTAssertNil(summary.maxObservedHeartRateBpm)
        XCTAssertEqual(summary.recentWorkouts.count, 1)
    }

    // MARK: - JSON shape stability (gardes contre dérive non-intentionnelle)

    func testJSONShapeStableForRichSummary() throws {
        let summary = HealthSummary(
            vo2maxBucket: .advanced,
            restingHeartRateBpm: 58,
            maxObservedHeartRateBpm: 190,
            weeklyWorkoutsAverage4w: 3.0,
            recentWorkouts: [
                HealthSummary.WorkoutSnapshot(
                    sportCode: "running",
                    durationMinutes: 32,
                    averageHeartRateBpm: 152,
                    maxHeartRateBpm: 178,
                    daysAgo: 1
                )
            ],
            hasAppleWatch: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(summary)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        // Pas d'interprétation médicale dans le JSON : on vérifie l'absence des
        // termes "abnormal" / "warning" / "diagnosis" / "alert" / "risk" — si l'un
        // apparait c'est un signe que quelqu'un a ajouté un champ interprétatif.
        for forbidden in ["abnormal", "warning", "diagnosis", "alert", "risk", "concern"] {
            XCTAssertFalse(json.lowercased().contains(forbidden), "Champ interprétatif inattendu : \(forbidden)")
        }

        // Round-trip : decode → encode doit redonner la même chose.
        let decoded = try JSONDecoder().decode(HealthSummary.self, from: data)
        XCTAssertEqual(decoded, summary)
    }
}

// Mock partagé : `MockHealthKitService` dans CoachingSageTests/Mocks/MockHealthKitService.swift
// Étendu Story 3.3b avec stubbedRestingHeartRateAverage + stubbedRecentWorkoutDetails.
