// Coaching/AutoProfile/AutoProfileInference.swift
// Story Autoprofil HealthKit (Epic 3 Phase 2 #4)
// Service pur d'inférence niveau / fréquence / suggestions équipement à partir des signaux HealthKit.
// Aucune dépendance HK directe — prend les structs de résultat en entrée pour rester deterministic et testable.
import Foundation

// MARK: - Estimates

/// Bucket de niveau aligné sur les options Q1 du RunningQuestionnaire.
/// Mappe directement vers le champ `level` de `CoachingSportProfile`.
enum LevelEstimate: String, Equatable, Sendable {
    case beginner
    case recreational
    case regular
    case competitive
}

/// Bucket de fréquence aligné sur les options Q3 du RunningQuestionnaire.
/// `rawValue` correspond au `frequencyLabel` stocké en DB.
enum FrequencyEstimate: String, Equatable, Sendable {
    case two = "2"
    case three = "3"
    case fourOrMore = "4_or_more"

    /// Conversion vers l'entier `frequencyPerWeek` stocké en DB.
    var perWeek: Int {
        switch self {
        case .two: return 2
        case .three: return 3
        case .fourOrMore: return 4
        }
    }
}

/// Résultat agrégé exposé à la View `AutoProfileReviewView`.
/// `nil` ⇔ pas assez de données HealthKit pour proposer un autoprofil → fallback questionnaire.
struct AutoProfileSuggestion: Equatable, Sendable {
    let level: LevelEstimate
    let frequency: FrequencyEstimate
    let equipmentSuggestions: [EquipmentCode]
    /// Source du signal niveau, pour transparence UI (« d'après ta VO2max » vs « d'après ta fréquence »).
    let levelSource: LevelSource

    enum LevelSource: String, Equatable, Sendable {
        case vo2Max
        case workoutFrequency
    }
}

// MARK: - Service

protocol AutoProfileInferenceProtocol: Sendable {
    func suggest(
        vo2Max: Double?,
        workoutSummary: HealthKitWorkoutSummary,
        sportCode: String
    ) -> AutoProfileSuggestion?
}

struct AutoProfileInference: AutoProfileInferenceProtocol {
    init() {}

    func suggest(
        vo2Max: Double?,
        workoutSummary: HealthKitWorkoutSummary,
        sportCode: String
    ) -> AutoProfileSuggestion? {
        // Pas de signal exploitable → fallback questionnaire classique.
        if vo2Max == nil, workoutSummary.totalCount == 0 {
            return nil
        }

        let level: LevelEstimate
        let levelSource: AutoProfileSuggestion.LevelSource
        if let vo2Max {
            level = inferLevel(vo2Max: vo2Max, sportCode: sportCode)
            levelSource = .vo2Max
        } else {
            level = inferLevelFromFrequency(weeklyAverage: workoutSummary.weeklyAverage)
            levelSource = .workoutFrequency
        }

        let frequency = inferFrequencyBucket(weeklyAverage: workoutSummary.weeklyAverage)
        let equipment = equipmentSuggestions(appleWatchDetected: workoutSummary.appleWatchDetected)

        return AutoProfileSuggestion(
            level: level,
            frequency: frequency,
            equipmentSuggestions: equipment,
            levelSource: levelSource
        )
    }

    // MARK: - Level

    /// Inférence niveau à partir de VO2max.
    /// Tables H/F neutralisées V1 par approximation ; à raffiner si Sophie veut des seuils par genre/âge.
    /// Buckets running (mL/kg/min) :
    /// - <35  → beginner
    /// - 35-43 → recreational
    /// - 43-52 → regular
    /// - ≥52  → competitive
    /// Sports non-running : on applique pour l'instant la même grille (running pilote V1).
    func inferLevel(vo2Max: Double, sportCode: String) -> LevelEstimate {
        switch vo2Max {
        case ..<35: return .beginner
        case ..<43: return .recreational
        case ..<52: return .regular
        default: return .competitive
        }
    }

    /// Fallback niveau quand VO2max absent : basé sur la fréquence hebdo récente.
    /// - 0/sem → beginner
    /// - <2/sem → recreational
    /// - 2-3.5/sem → regular
    /// - ≥3.5/sem → competitive
    func inferLevelFromFrequency(weeklyAverage: Double) -> LevelEstimate {
        switch weeklyAverage {
        case ..<0.25: return .beginner
        case ..<2: return .recreational
        case ..<3.5: return .regular
        default: return .competitive
        }
    }

    // MARK: - Frequency

    /// Inférence bucket fréquence Q3 — aligné sur les 3 options du RunningQuestionnaire.
    /// - <1.5/sem → 2
    /// - 1.5-3/sem → 3
    /// - ≥3/sem → 4_or_more
    func inferFrequencyBucket(weeklyAverage: Double) -> FrequencyEstimate {
        switch weeklyAverage {
        case ..<1.5: return .two
        case ..<3: return .three
        default: return .fourOrMore
        }
    }

    // MARK: - Equipment

    /// Suggestions équipement à partir de la détection Apple Watch.
    /// Apple Watch ⇒ user a typiquement gps_watch + heart_rate_monitor.
    /// Decoché possible côté UI (pas une décision finale).
    func equipmentSuggestions(appleWatchDetected: Bool) -> [EquipmentCode] {
        appleWatchDetected ? [.gpsWatch, .heartRateMonitor] : []
    }
}
