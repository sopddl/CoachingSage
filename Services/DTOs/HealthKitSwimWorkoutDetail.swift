// Services/DTOs/HealthKitSwimWorkoutDetail.swift
// Story 3.16 (Phase 1, read-only) — DTOs pour l'inspection lap-by-lap des
// workouts natation lus depuis HealthKit. Pas de wiring algo en Phase 1 :
// ces structs alimentent uniquement `SwimHealthKitInspectorView` (écran DEBUG).
//
// 2026-06-02 — extension « tout capter » (demande Sophie) : on remonte
// l'intégralité de ce que HealthKit expose pour une séance natation (énergie,
// METs, SWOLF, strokes par lap, repos au mur, device/source, + dump brut de
// metadata / allStatistics / events) pour que le test iPhone soit décisionnel
// avant d'arbitrer la Phase 2.
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

/// Une paire clé→valeur déjà stringifiée pour l'affichage brut. `Identifiable`
/// pour itérer proprement dans le `ForEach` de l'inspector.
struct HealthKitRawEntry: Equatable, Sendable, Identifiable {
    let key: String
    let value: String
    var id: String { key }
}

/// Détail d'un lap natation. Distance par lap dérivée du `poolLengthMeters`
/// du workout parent (un lap = une longueur en pool tracking Apple). `nil`
/// si pool length absente (open water, app tierce). HR récupérée via
/// `HKStatisticsQuery` ciblée sur la fenêtre temporelle du lap.
struct HealthKitSwimLap: Equatable, Sendable {
    /// 1-based, ordre temporel.
    let index: Int
    let startDate: Date
    let durationSeconds: TimeInterval
    let distanceMeters: Double?
    let strokeStyle: SwimStrokeStyle?
    let paceSecondsPer100m: Double?
    let averageHeartRateBpm: Int?
    /// Strokes comptés sur la fenêtre temporelle du lap (somme `swimmingStrokeCount`).
    let strokeCount: Int?
    /// HR min/max sur la fenêtre du lap (complète `averageHeartRateBpm`).
    let minHeartRateBpm: Int?
    let maxHeartRateBpm: Int?
    /// SWOLF = durée du lap (s, arrondie) + nombre de strokes. `nil` si l'un
    /// des deux manque. Métrique d'efficacité de nage standard.
    let swolfScore: Int?
    /// Secondes de repos entre la fin de ce lap et le début du suivant (repos
    /// au mur). `nil` pour le dernier lap ou si pas d'écart mesurable.
    let restAfterSeconds: TimeInterval?

    /// Calcule la pace s/100m à partir de durée + distance. Retourne `nil` si
    /// distance absente ou == 0 (garde-fou division). Exposée pour les tests.
    static func computePaceSecondsPer100m(
        durationSeconds: TimeInterval,
        distanceMeters: Double?
    ) -> Double? {
        guard let distance = distanceMeters, distance > 0 else { return nil }
        return durationSeconds / distance * 100.0
    }

    /// SWOLF = durée arrondie (s) + strokes. `nil` si l'un des deux manque ou
    /// si strokes <= 0. Exposée pour les tests.
    static func computeSwolf(durationSeconds: TimeInterval, strokeCount: Int?) -> Int? {
        guard let strokes = strokeCount, strokes > 0 else { return nil }
        return Int(durationSeconds.rounded()) + strokes
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
    /// HR min sur toute la séance (complète moy/max).
    let minHeartRateBpm: Int?
    /// Énergie active brûlée (kcal) — proxy d'effort.
    let activeEnergyKcal: Double?
    /// Énergie totale (active + repos) brûlée (kcal).
    let totalEnergyKcal: Double?
    /// METs moyens (`HKMetadataKeyAverageMETs`) — intensité normalisée.
    let averageMETs: Double?
    let poolLengthMeters: Double?
    let swimLocationType: SwimLocationType?
    let sourceProductType: String?
    let appleWatchDetected: Bool
    /// Description du device source (HKDevice : nom + modèle + soft version).
    let deviceDescription: String?
    /// Description de la source applicative (nom app + version + OS).
    let sourceDescription: String?
    /// `HKMetadataKeyIndoorWorkout` si présent.
    let isIndoorWorkout: Bool?
    /// Fuseau horaire (`HKMetadataKeyTimeZone`).
    let timeZoneIdentifier: String?
    /// Comptage des events par type (pause, segment, marker, lap…) pour la
    /// structure de séance. Ex: ["lap": 32, "pause": 8].
    let eventCounts: [String: Int]
    let laps: [HealthKitSwimLap]
    /// Dump intégral de `workout.metadata` (clé HK → valeur stringifiée).
    let rawMetadata: [HealthKitRawEntry]
    /// Dump de `workout.allStatistics` (type quantité → somme/moy + unité).
    let rawStatistics: [HealthKitRawEntry]
}
