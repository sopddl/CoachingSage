// Services/DTOs/CoachingSportProfileDTO.swift
// Story 3.1 — mapping JSON Supabase ↔ CoachingSportProfile SwiftData.
// snake_case côté Postgres, camelCase côté Swift.
// DTOs typés Codable, AUCUN [String: Any] (review P0-2, lesson lessons_supabase #3 — DTO match exact).
import Foundation

struct CoachingSportProfileDTO: Decodable {
    let id: UUID
    let userId: UUID
    let sport: String
    let level: String
    let goalsJson: GoalsPayload
    let equipmentJson: [String]
    let constraintsJson: [String]
    let recordsJson: GoalsPayload?       // placeholder V1 — V2 introduira RecordsPayload dédié
    let frequencyPerWeek: Int
    let frequencyLabel: String
    let sessionDurationMinutes: Int?
    let freeTextNotes: String?
    let conversationHistoryJson: [ConversationEntry]
    let medicalClearanceAcknowledged: Bool
    let questionnaireVersion: String
    let createdAt: Date
    let lastUpdatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case sport
        case level
        case goalsJson = "goals_json"
        case equipmentJson = "equipment_json"
        case constraintsJson = "constraints_json"
        case recordsJson = "records_json"
        case frequencyPerWeek = "frequency_per_week"
        case frequencyLabel = "frequency_label"
        case sessionDurationMinutes = "session_duration_minutes"
        case freeTextNotes = "free_text_notes"
        case conversationHistoryJson = "conversation_history_json"
        case medicalClearanceAcknowledged = "medical_clearance_acknowledged"
        case questionnaireVersion = "questionnaire_version"
        case createdAt = "created_at"
        case lastUpdatedAt = "last_updated_at"
    }

    func toModel() -> CoachingSportProfile {
        CoachingSportProfile(
            id: id,
            userId: userId,
            sportCode: sport,
            level: level,
            goals: goalsJson,
            equipment: equipmentJson,
            constraints: constraintsJson,
            frequencyPerWeek: frequencyPerWeek,
            frequencyLabel: frequencyLabel,
            sessionDurationMinutes: sessionDurationMinutes,
            freeTextNotes: freeTextNotes,
            conversationHistory: conversationHistoryJson,
            medicalClearanceAcknowledged: medicalClearanceAcknowledged,
            questionnaireVersion: questionnaireVersion,
            createdAt: createdAt,
            lastUpdatedAt: lastUpdatedAt
        )
    }
}

/// DTO pour l'UPSERT Supabase (review P0-7 : `onConflict: "user_id,sport"`).
struct CoachingSportProfileUpsertDTO: Codable {
    let id: UUID
    let userId: UUID
    let sport: String
    let level: String
    let goalsJson: GoalsPayload
    let equipmentJson: [String]
    let constraintsJson: [String]
    let frequencyPerWeek: Int
    let frequencyLabel: String
    let sessionDurationMinutes: Int?
    let freeTextNotes: String?
    let conversationHistoryJson: [ConversationEntry]
    let medicalClearanceAcknowledged: Bool
    let questionnaireVersion: String
    let createdAt: Date
    let lastUpdatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case sport
        case level
        case goalsJson = "goals_json"
        case equipmentJson = "equipment_json"
        case constraintsJson = "constraints_json"
        case frequencyPerWeek = "frequency_per_week"
        case frequencyLabel = "frequency_label"
        case sessionDurationMinutes = "session_duration_minutes"
        case freeTextNotes = "free_text_notes"
        case conversationHistoryJson = "conversation_history_json"
        case medicalClearanceAcknowledged = "medical_clearance_acknowledged"
        case questionnaireVersion = "questionnaire_version"
        case createdAt = "created_at"
        case lastUpdatedAt = "last_updated_at"
    }

    init(from profile: CoachingSportProfile) {
        self.id = profile.id
        self.userId = profile.userId
        self.sport = profile.sportCode
        self.level = profile.level
        self.goalsJson = profile.goals
        self.equipmentJson = profile.equipment
        self.constraintsJson = profile.constraints
        self.frequencyPerWeek = profile.frequencyPerWeek
        self.frequencyLabel = profile.frequencyLabel
        self.sessionDurationMinutes = profile.sessionDurationMinutes
        self.freeTextNotes = profile.freeTextNotes
        self.conversationHistoryJson = profile.conversationHistory
        self.medicalClearanceAcknowledged = profile.medicalClearanceAcknowledged
        self.questionnaireVersion = profile.questionnaireVersion
        self.createdAt = profile.createdAt
        self.lastUpdatedAt = profile.lastUpdatedAt
    }
}
