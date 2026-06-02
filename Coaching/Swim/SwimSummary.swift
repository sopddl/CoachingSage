// Coaching/Swim/SwimSummary.swift
// Story 3.16 Phase 2.A — modèles d'agrégat natation dérivés des
// `HealthKitSwimWorkoutDetail` bruts (lus en Phase 1). Logique pure, sans
// dépendance HealthKit ni SwiftData : entièrement testable unitairement.
//
// Conventions natation appliquées ici :
// - "pace soutenue" / pace moyenne = calculée UNIQUEMENT sur les longueurs
//   réellement nagées (crawl/dos/brasse/papillon/mixte), en EXCLUANT kickboard
//   et unknown (séries de jambes = pace non comparable).
// - HR = niveau séance uniquement (le HR par lap est quasi vide sous l'eau,
//   confirmé sur données réelles 2026-06-02).
// - "série" (SwimSet) = longueurs consécutives sans repos significatif au mur,
//   séparées par un repos >= seuil (cf SwimSummaryBuilder.restBreakThresholdSeconds).
import Foundation

/// Une série détectée dans une séance : longueurs consécutives nagées sans
/// repos significatif, fermée par un repos au mur >= seuil (ou fin de séance).
struct SwimSet: Equatable, Sendable, Identifiable {
    /// Index 1-based de la série dans la séance.
    let id: Int
    let lapCount: Int
    let distanceMeters: Double?
    let dominantStroke: SwimStrokeStyle?
    /// Pace moyenne sur les longueurs nagées de la série (hors kick/unknown). nil si aucune.
    let avgPaceSecondsPer100m: Double?
    let avgSwolf: Int?
    /// Repos au mur (s) avant la série suivante. nil pour la dernière série.
    let restAfterSeconds: TimeInterval?
}

/// Résumé d'une séance natation (dérivé d'un `HealthKitSwimWorkoutDetail`).
struct SwimSessionSummary: Equatable, Sendable, Identifiable {
    let id: UUID
    let date: Date
    let durationSeconds: TimeInterval
    let totalDistanceMeters: Double?
    let lapCount: Int
    /// Pace moyenne sur longueurs nagées (hors kick/unknown). nil si aucune.
    let avgPaceSecondsPer100m: Double?
    /// Meilleure (plus rapide) pace de longueur nagée (longueurs partielles
    /// écartées via un plancher de distance). nil si aucune.
    /// ⚠️ INDICATIVE — même réserve que `SwimSummary.bestPaceSecondsPer100m` :
    /// ne PAS utiliser comme CSS de calibration du ProgramAdapter.
    let bestLapPaceSecondsPer100m: Double?
    let dominantStroke: SwimStrokeStyle?
    /// Nombre de longueurs par style.
    let strokeDistribution: [SwimStrokeStyle: Int]
    let avgSwolf: Int?
    /// HR moyenne au niveau séance (pas par lap). nil si non disponible.
    let averageHeartRateBpm: Int?
    let activeEnergyKcal: Double?
    let sets: [SwimSet]
    let poolLengthMeters: Double?
}

/// Agrégat multi-séances sur une fenêtre glissante (`windowWeeks`).
struct SwimSummary: Equatable, Sendable {
    let sessionCount: Int
    let windowWeeks: Int
    let totalDistanceMeters: Double
    let weeklyAverageDistanceMeters: Double
    let weeklyAverageSessions: Double
    /// Pace moyenne pondérée par distance sur la fenêtre (longueurs nagées). nil si aucune.
    let avgPaceSecondsPer100m: Double?
    /// Meilleure pace soutenue observée sur la fenêtre.
    /// ⚠️ INDICATIVE : ne PAS l'utiliser comme CSS pour calibrer le ProgramAdapter
    /// (laps non-compétition, push-off, pauses mur faussent l'estimation —
    /// le test CSS du template reste la source de vérité).
    let bestPaceSecondsPer100m: Double?
    let strokeDistribution: [SwimStrokeStyle: Int]
    let longestSessionDistanceMeters: Double?
    /// Séances résumées, ordre antéchronologique (plus récente en premier).
    let sessions: [SwimSessionSummary]

    static let empty = SwimSummary(
        sessionCount: 0,
        windowWeeks: 0,
        totalDistanceMeters: 0,
        weeklyAverageDistanceMeters: 0,
        weeklyAverageSessions: 0,
        avgPaceSecondsPer100m: nil,
        bestPaceSecondsPer100m: nil,
        strokeDistribution: [:],
        longestSessionDistanceMeters: nil,
        sessions: []
    )
}

/// Tendance d'évolution sur la fenêtre : moitié récente vs moitié ancienne des
/// séances. Delta = récent − ancien. Pour pace ET SWOLF, un delta NÉGATIF = mieux
/// (plus rapide / plus efficace). `nil` si pas assez de séances pour comparer.
struct SwimTrend: Equatable, Sendable {
    let paceDeltaSecondsPer100m: Double?
    let swolfDelta: Double?
    /// Nombre total de séances utilisées dans la comparaison.
    let comparedSessions: Int
}

extension SwimStrokeStyle {
    /// Clé i18n du nom de style (FR/EN dans Localizable.xcstrings). `nil` pour
    /// `.unknown` (rien à afficher).
    var localizationKey: String? {
        switch self {
        case .freestyle: return "swim.stroke.freestyle"
        case .backstroke: return "swim.stroke.backstroke"
        case .breaststroke: return "swim.stroke.breaststroke"
        case .butterfly: return "swim.stroke.butterfly"
        case .mixed: return "swim.stroke.mixed"
        case .kickboard: return "swim.stroke.kickboard"
        case .unknown: return nil
        }
    }

    /// `true` pour un style de nage à pace comparable (exclut kick/unknown).
    var isSwumStroke: Bool {
        switch self {
        case .freestyle, .backstroke, .breaststroke, .butterfly, .mixed:
            return true
        case .kickboard, .unknown:
            return false
        }
    }
}
