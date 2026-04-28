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

    var activeSports: [String]              // sérialisé Postgres TEXT[]
    var parqResponses: [String: Bool]       // 5 keys figées via PARQQuestion enum
    var requiresMedicalClearance: Bool      // calc Swift : true si toute réponse PARQ == true

    var disclaimerVersionAccepted: String?  // "1.0"
    var disclaimerAcceptedAt: Date?
    var onboardingCompletedAt: Date?        // source of truth "onboarding done"

    var createdAt: Date
    var updatedAt: Date
    var isSoftDeleted: Bool
    var deletedAt: Date?

    init(id: UUID) {
        self.id = id
        self.biologicalSex = nil
        self.dateOfBirth = nil
        self.weightKg = nil
        self.heightCm = nil
        self.activeSports = []
        self.parqResponses = PARQQuestion.defaultResponses
        self.requiresMedicalClearance = false
        self.disclaimerVersionAccepted = nil
        self.disclaimerAcceptedAt = nil
        self.onboardingCompletedAt = nil
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
