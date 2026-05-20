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
    let durationMode: String?            // story sœur — nullable pour rétro-compat lecture (default routineCyclic)
    let targetDate: Date?                // story sœur — nullable (deadlineFixed/Estimated only)
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
        case durationMode = "duration_mode"
        case targetDate = "target_date"
        case createdAt = "created_at"
        case lastUpdatedAt = "last_updated_at"
    }

    func toModel() -> CoachingSportProfile {
        let mode = durationMode.flatMap { ProgramDurationMode(rawValue: $0) } ?? .routineCyclic
        return CoachingSportProfile(
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
            durationMode: mode,
            targetDate: targetDate,
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
    let durationMode: String              // story sœur — toujours présent au write
    let targetDate: Date?                 // story sœur — null si routineCyclic
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
        case durationMode = "duration_mode"
        case targetDate = "target_date"
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
        self.durationMode = profile.durationMode.rawValue
        self.targetDate = profile.targetDate
        self.createdAt = profile.createdAt
        self.lastUpdatedAt = profile.lastUpdatedAt
    }

    /// Hotfix 2026-05-20 — `targetDate` DOIT être présent dans le JSON (null si
    /// nil) pour que l'UPSERT Supabase efface une ancienne date résiduelle.
    /// `JSONEncoder` par défaut OMET les Optional nil, donc l'UPSERT laissait
    /// `target_date` intact → CHECK constraint `target_date_consistency` violée
    /// en routineCyclic. Override explicite avec `encodeNil` pour `target_date`.
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(userId, forKey: .userId)
        try c.encode(sport, forKey: .sport)
        try c.encode(level, forKey: .level)
        try c.encode(goalsJson, forKey: .goalsJson)
        try c.encode(equipmentJson, forKey: .equipmentJson)
        try c.encode(constraintsJson, forKey: .constraintsJson)
        try c.encode(frequencyPerWeek, forKey: .frequencyPerWeek)
        try c.encode(frequencyLabel, forKey: .frequencyLabel)
        try c.encodeIfPresent(sessionDurationMinutes, forKey: .sessionDurationMinutes)
        try c.encodeIfPresent(freeTextNotes, forKey: .freeTextNotes)
        try c.encode(conversationHistoryJson, forKey: .conversationHistoryJson)
        try c.encode(medicalClearanceAcknowledged, forKey: .medicalClearanceAcknowledged)
        try c.encode(questionnaireVersion, forKey: .questionnaireVersion)
        try c.encode(durationMode, forKey: .durationMode)
        if let targetDate = targetDate {
            try c.encode(targetDate, forKey: .targetDate)
        } else {
            try c.encodeNil(forKey: .targetDate)
        }
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(lastUpdatedAt, forKey: .lastUpdatedAt)
    }
}
