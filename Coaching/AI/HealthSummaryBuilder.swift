// Coaching/AI/HealthSummaryBuilder.swift
// Story 3.3b — compose un `HealthSummary` à partir d'un `HealthKitServiceProtocol`.
// Tolère totalement le refus utilisateur ou l'absence de données : tous les champs
// du résultat sont optionnels, vides ou par défaut.
//
// Le builder est SANS state et purement fonctionnel — facile à tester avec un mock.
// Réutilisable par Stories 3.3b (adapt-rare), 3.4 (regen hebdo) et 3.6 (chat Léon).
import Foundation
import HealthKit
import TemplateModel

protocol HealthSummaryBuilding: Sendable {
    func buildSummary() async -> HealthSummary
}

struct DefaultHealthSummaryBuilder: HealthSummaryBuilding {
    private let healthKit: HealthKitServiceProtocol

    init(healthKit: HealthKitServiceProtocol) {
        self.healthKit = healthKit
    }

    func buildSummary() async -> HealthSummary {
        // Lance les 4 lectures HK en parallèle pour minimiser la latence (la fetch
        // détaillée des workouts itère elle-même sur N workouts × 1 HR query chacun,
        // donc la perf compte).
        async let vo2maxSample = healthKit.fetchVO2MaxRecent()
        async let workoutSummary = healthKit.fetchWorkoutSummary(weeksBack: 4)
        async let restingHR = healthKit.fetchRestingHeartRateAverage()
        async let recentDetails = healthKit.fetchRecentWorkoutDetails()

        let (sample, summary, hrAvg, details) = await (vo2maxSample, workoutSummary, restingHR, recentDetails)

        let bucket = sample.flatMap { HealthSummary.VO2MaxBucket(value: $0.value) }
        let weekly: Double? = summary.totalCount > 0 ? summary.weeklyAverage : nil
        let snapshots = details.map { Self.toSnapshot($0) }
        let maxObserved = details.compactMap(\.maxHeartRateBpm).max()

        return HealthSummary(
            vo2maxBucket: bucket,
            restingHeartRateBpm: hrAvg.map { Int($0.rounded()) },
            maxObservedHeartRateBpm: maxObserved,
            weeklyWorkoutsAverage4w: weekly,
            recentWorkouts: snapshots,
            hasAppleWatch: summary.appleWatchDetected || details.contains(where: \.fromAppleWatch)
        )
    }

    static func toSnapshot(_ detail: HealthKitWorkoutDetail) -> HealthSummary.WorkoutSnapshot {
        HealthSummary.WorkoutSnapshot(
            sportCode: Self.mapToSportCode(detail.activityTypeRawValue),
            durationMinutes: detail.durationMinutes,
            averageHeartRateBpm: detail.averageHeartRateBpm,
            maxHeartRateBpm: detail.maxHeartRateBpm,
            daysAgo: detail.daysAgo
        )
    }

    /// Mappe un `HKWorkoutActivityType.rawValue` vers un `Sport.rawValue` si match
    /// existe dans le catalogue V1 (10 sports). Sinon nil — Léon ignorera l'item.
    static func mapToSportCode(_ raw: UInt) -> String? {
        guard let activity = HKWorkoutActivityType(rawValue: raw) else { return nil }
        switch activity {
        case .running: return Sport.running.rawValue
        case .cycling: return Sport.cycling.rawValue
        case .swimming: return Sport.swimming.rawValue
        case .yoga: return Sport.yoga.rawValue
        case .highIntensityIntervalTraining: return Sport.hiit.rawValue
        case .hiking: return Sport.hiking.rawValue
        case .tennis: return Sport.tennis.rawValue
        case .soccer, .americanFootball: return Sport.football.rawValue
        case .functionalStrengthTraining, .traditionalStrengthTraining, .crossTraining:
            return Sport.strengthTraining.rawValue
        default: return nil
        }
    }
}
