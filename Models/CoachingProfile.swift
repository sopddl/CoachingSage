// Models/CoachingProfile.swift
// Story 2.2 — profil sportif spécifique CoachingSage.
// 1-1 strict avec SageCoreProfile via UUID partagé (id == auth.users.id).
// Pas de @Relationship : SageCoreProfile vit dans SageCore SPM (partagé Sage), CoachingProfile en local CS.
import Foundation
import SwiftData

@Model
final class CoachingProfile {
    @Attribute(.unique) var id: UUID

    var biologicalSex: String?              // "female" | "male" | "other" | "prefer_not_to_say" | nil
    var dateOfBirth: Date?
    var weightKg: Double?
    var heightCm: Double?

    // Sophie 2026-05-11 : `= []` / `= [:]` / `= false` indispensables pour la
    // lightweight migration SwiftData quand un store legacy n'a pas l'attribut
    // (ex: iPhone réel installé avec un ancien Schema). Sans default, l'erreur
    // "Validation error missing attribute values on mandatory destination attribute"
    // bloque le ModelContainer.init.
    var activeSports: [String] = []         // sérialisé Postgres TEXT[]
    var equipment: [String] = []            // sérialisé Postgres TEXT[] — codes EquipmentCode
    var parqResponses: [String: Bool] = [:] // 5 keys figées via PARQQuestion enum
    var requiresMedicalClearance: Bool = false  // calc Swift : true si toute réponse PARQ == true

    var disclaimerVersionAccepted: String?  // "1.0"
    var disclaimerAcceptedAt: Date?
    var onboardingCompletedAt: Date?        // source of truth "onboarding done"

    // Story 3.15 : flag idempotent du bootstrap dormants (selectTopN ×3 au 1er
    // launch post-onboarding). Mis à `true` par `DormantBootstrapService.bootstrapIfNeeded()`
    // avant toute persistance — pas de retry, pas de regénération auto.
    var bootstrappedDormants: Bool = false

    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isSoftDeleted: Bool = false
    var deletedAt: Date?

    init(id: UUID) {
        self.id = id
        self.biologicalSex = nil
        self.dateOfBirth = nil
        self.weightKg = nil
        self.heightCm = nil
        self.activeSports = []
        self.equipment = []
        self.parqResponses = PARQQuestion.defaultResponses
        self.requiresMedicalClearance = false
        self.disclaimerVersionAccepted = nil
        self.disclaimerAcceptedAt = nil
        self.onboardingCompletedAt = nil
        self.bootstrappedDormants = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isSoftDeleted = false
        self.deletedAt = nil
    }
}

/// 5 keys PARQ-light figées — alignées avec migration 002 `parq_responses` JSONB.
/// Ajouter une question = bumper `disclaimerVersionAccepted` et re-prompter (Epic 7+).
enum PARQQuestion: String, CaseIterable {
    case q1ChestPain = "q1_chest_pain"
    case q2Dizziness = "q2_dizziness"
    case q3JointAggravated = "q3_joint_aggravated"
    case q4HeartMedication = "q4_heart_medication"
    case q5OtherReason = "q5_other_reason"

    static var defaultResponses: [String: Bool] {
        Dictionary(uniqueKeysWithValues: allCases.map { ($0.rawValue, false) })
    }
}

/// Équipement générique multi-sport déclaré à l'onboarding.
/// L'équipement spécifique sport (treadmill, home-trainer, etc.) reste dans CoachingSportProfile.
/// L'adapter consomme l'union onboarding ∪ sport.
enum EquipmentCode: String, CaseIterable {
    case gpsWatch = "gps_watch"
    case heartRateMonitor = "heart_rate_monitor"
    case roadBike = "road_bike"
    case indoorBike = "indoor_bike"
    case homeWeights = "home_weights"

    var sfSymbol: String {
        switch self {
        case .gpsWatch: return "applewatch"
        case .heartRateMonitor: return "heart.fill"
        case .roadBike: return "bicycle"
        case .indoorBike: return "figure.indoor.cycle"
        case .homeWeights: return "dumbbell.fill"
        }
    }

    var localizationKey: String {
        "onboarding.equipment.option.\(rawValue)"
    }
}

/// 10 sports V1 — codes sérialisés Postgres TEXT[].
/// Ajouts Epic 3+ (Léon métadonnées zones FC, etc.).
enum SportCode: String, CaseIterable {
    case running
    case cycling
    case swimming
    case triathlon
    case strengthTraining
    case yoga
    case hiit
    case hiking
    case tennis
    case football

    var sfSymbol: String {
        switch self {
        case .running: return "figure.run"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .triathlon: return "figure.mixed.cardio"
        case .strengthTraining: return "dumbbell.fill"
        case .yoga: return "figure.yoga"
        case .hiit: return "bolt.heart.fill"
        case .hiking: return "figure.hiking"
        case .tennis: return "figure.tennis"
        case .football: return "soccerball"
        }
    }

    var localizationKey: String {
        "onboarding.sport.\(rawValue)"
    }
}
