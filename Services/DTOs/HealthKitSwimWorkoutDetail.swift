// Services/DTOs/HealthKitSwimWorkoutDetail.swift
// Story 3.16 (Phase 1, read-only) — DTOs pour l'inspection lap-by-lap des
// workouts natation lus depuis HealthKit. Pas de wiring algo en Phase 1 :
// ces structs alimentent uniquement `SwimHealthKitInspectorView` (écran DEBUG).
import Foundation

/// Style de nage par lap. Miroir EXACT des rawValues `HKSwimmingStrokeStyle`
/// iOS 16+ : 0 unknown / 1 mixed / 2 freestyle / 3 backstroke / 4 breaststroke /
/// 5 butterfly / 6 kickboard. Tout rawValue non reconnu → `.unknown`.
enum SwimStrokeStyle: Int, Equatable, Sendable {
    case unknown = 0
    case mixed = 1
    case freestyle = 2
    case backstroke = 3
    case breaststroke = 4
    case butterfly = 5
    case kickboard = 6

    init(rawValueSafe: Int) {
        self = SwimStrokeStyle(rawValue: rawValueSafe) ?? .unknown
    }
}

/// Type de plan d'eau extrait de `HKMetadataKeySwimmingLocationType` (pool /
/// openWater / unknown). Miroir simplifié de `HKWorkoutSwimmingLocationType`.
enum SwimLocationType: Int, Equatable, Sendable {
    case unknown = 0
    case pool = 1
    case openWater = 2

    init(rawValueSafe: Int) {
        self = SwimLocationType(rawValue: rawValueSafe) ?? .unknown
    }
}

/// Détail d'un lap natation. Distance par lap dérivée du `poolLengthMeters`
/// du workout parent (un lap = une longueur en pool tracking Apple). `nil`
/// si pool length absente (open water, app tierce). HR moyenne récupérée via
/// une `HKStatisticsQuery` ciblée sur la fenêtre temporelle du lap.
struct HealthKitSwimLap: Equatable, Sendable {
    /// 1-based, ordre temporel.
    let index: Int
    let startDate: Date
    let durationSeconds: TimeInterval
    let distanceMeters: Double?
    let strokeStyle: SwimStrokeStyle?
    let paceSecondsPer100m: Double?
    let averageHeartRateBpm: Int?

    /// Calcule la pace s/100m à partir de durée + distance. Retourne `nil` si
    /// distance absente ou == 0 (garde-fou division). Exposée pour les tests.
    static func computePaceSecondsPer100m(
        durationSeconds: TimeInterval,
        distanceMeters: Double?
    ) -> Double? {
        guard let distance = distanceMeters, distance > 0 else { return nil }
        return durationSeconds / distance * 100.0
    }
}

/// Détail d'un workout natation lu depuis HealthKit. `laps` peut être vide
/// (open water, app tierce, ou tracking sans lap event) — la Phase 1 ne
/// bloque jamais sur l'absence de laps : on inspecte ce qu'on a.
struct HealthKitSwimWorkoutDetail: Equatable, Sendable, Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let durationSeconds: TimeInterval
    let totalDistanceMeters: Double?
    let totalStrokes: Int?
    let averageHeartRateBpm: Int?
    let maxHeartRateBpm: Int?
    let poolLengthMeters: Double?
    let swimLocationType: SwimLocationType?
    let sourceProductType: String?
    let appleWatchDetected: Bool
    let laps: [HealthKitSwimLap]
}
