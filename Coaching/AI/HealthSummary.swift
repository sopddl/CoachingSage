// Coaching/AI/HealthSummary.swift
// Story 3.3b — résumé HealthKit compact (~20 lignes JSON) destiné à Léon (mode adapt-rare).
// Volontairement FACTUEL : pas d'interprétation, pas de "isAbnormal", pas de score santé.
// Le prompt système Léon instruit explicitement le modèle : "ces données sont pour
// CALIBRER le programme sportif, JAMAIS pour diagnostiquer".
//
// Réutilisable par Story 3.4 (regen hebdo Léon+) et Story 3.6 (chat Léon).
import Foundation
import TemplateModel

/// Résumé compact de l'état physique récent du user, prêt à sérialiser en JSON
/// pour Léon. Tous les champs sont optionnels : un user qui refuse HealthKit ou
/// un device sans données aura une struct quasi-vide — Léon doit tolérer ça.
public struct HealthSummary: Codable, Equatable, Sendable {
    /// Bucket grossier de VO2max (4 niveaux). nil si absent. Volontairement non
    /// précis (Léon n'a pas besoin de la valeur exacte pour calibrer un programme).
    public let vo2maxBucket: VO2MaxBucket?

    /// Resting heart rate moyen sur 30 jours (BPM). nil si refus/absence.
    public let restingHeartRateBpm: Int?

    /// HR maximale observée pendant les workouts récents (BPM). nil si pas de Watch
    /// ou pas de workouts. Permet à Léon de calibrer les zones cardio sur le RÉEL
    /// vs la formule théorique 220-age (souvent fausse).
    public let maxObservedHeartRateBpm: Int?

    /// Moyenne workouts/semaine sur 4 semaines. nil si refus, 0.0 si autorisé mais zéro workout.
    public let weeklyWorkoutsAverage4w: Double?

    /// Liste max 4 derniers workouts, ordre antichronologique.
    public let recentWorkouts: [WorkoutSnapshot]

    /// `true` si au moins un workout récent est sourcé par un Apple Watch.
    /// Permet à Léon de juger la fiabilité des HR.
    public let hasAppleWatch: Bool

    public init(
        vo2maxBucket: VO2MaxBucket? = nil,
        restingHeartRateBpm: Int? = nil,
        maxObservedHeartRateBpm: Int? = nil,
        weeklyWorkoutsAverage4w: Double? = nil,
        recentWorkouts: [WorkoutSnapshot] = [],
        hasAppleWatch: Bool = false
    ) {
        self.vo2maxBucket = vo2maxBucket
        self.restingHeartRateBpm = restingHeartRateBpm
        self.maxObservedHeartRateBpm = maxObservedHeartRateBpm
        self.weeklyWorkoutsAverage4w = weeklyWorkoutsAverage4w
        self.recentWorkouts = recentWorkouts
        self.hasAppleWatch = hasAppleWatch
    }

    /// Snapshot d'un workout. Anonymisé : `daysAgo` relatif, pas de date absolue.
    public struct WorkoutSnapshot: Codable, Equatable, Sendable {
        /// `Sport.rawValue` si HK activity type matche, sinon nil (Léon ignorera).
        public let sportCode: String?
        public let durationMinutes: Int
        public let averageHeartRateBpm: Int?
        public let maxHeartRateBpm: Int?
        public let daysAgo: Int

        public init(
            sportCode: String?,
            durationMinutes: Int,
            averageHeartRateBpm: Int?,
            maxHeartRateBpm: Int?,
            daysAgo: Int
        ) {
            self.sportCode = sportCode
            self.durationMinutes = durationMinutes
            self.averageHeartRateBpm = averageHeartRateBpm
            self.maxHeartRateBpm = maxHeartRateBpm
            self.daysAgo = daysAgo
        }
    }

    /// Bucketization VO2max grossière. Seuils alignés sur les normes ACSM
    /// (Cooper Institute) pour adultes 30-49 ans, simplifiés en 4 buckets pour
    /// éviter une fausse précision côté Léon. Sources :
    /// https://www.cooperinstitute.org/vo2-max-norms
    public enum VO2MaxBucket: String, Codable, Sendable {
        case beginner       // < 30 ml/kg/min
        case intermediate   // 30 - 44.9
        case advanced       // 45 - 54.9
        case elite          // >= 55

        public init?(value: Double) {
            switch value {
            case ..<30: self = .beginner
            case 30..<45: self = .intermediate
            case 45..<55: self = .advanced
            case 55...: self = .elite
            default: return nil  // valeur négative ou NaN
            }
        }
    }
}
