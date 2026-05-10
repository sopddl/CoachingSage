// Models/CoachingSportProfile.swift
// Story 3.1 — profil sportif détaillé (1 par user × sport), créé à la fin du SportQuestionnaire local.
// Pattern strict CoachingProfile (Story 2.2) : @Model SwiftData + upsert Supabase via repository.
// 1 row par (userId, sportCode) — UNIQUE constraint côté Postgres (migration 003), dedup côté SwiftData via repo.
import Foundation
import SwiftData

@Model
final class CoachingSportProfile {
    @Attribute(.unique) var id: UUID
    var userId: UUID                            // ref auth.users.id
    var sportCode: String                       // SportCode.rawValue (running, cycling, swimming, ...)
    var level: String                           // "beginner" | "recreational" | "regular" | "competitive"

    /// goals_json — struct GoalsPayload encodée en Data (lesson lessons_swiftdata #1 pour structs custom).
    private var goalsJsonData: Data
    var goals: GoalsPayload {
        get { (try? JSONDecoder().decode(GoalsPayload.self, from: goalsJsonData)) ?? GoalsPayload(primary: "") }
        set { goalsJsonData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    /// equipment_json — [String] direct (pattern CoachingProfile.activeSports Story 2.2).
    var equipment: [String]

    /// constraints_json — [String] direct.
    /// ⚠️ ["none"] explicit ≠ [] (review P1-10) : ["none"] = user a confirmé "pas de contrainte" ;
    /// [] = question skippée par le moteur (ex: Q4 si Q1=beginner). Sémantique préservée pour Léon Story 3.3.
    var constraints: [String]

    /// records_json — struct dédiée V2 (records perso par sport), nullable.
    private var recordsJsonData: Data?

    var frequencyPerWeek: Int                   // 2/3/4 (mappé depuis Q3 ; "dont_know" → 3 sensible default)
    var frequencyLabel: String                  // "2" | "3" | "4_or_more" | "dont_know" — préserve l'intention (review P1-3)
    var sessionDurationMinutes: Int?            // nullable, calculé Story 3.2/3.3
    var freeTextNotes: String?                  // nullable, max 200 chars (CHECK SQL)

    /// Story sœur — mode de durée du programme. RawValue de `ProgramDurationMode`.
    /// Default `.routineCyclic` (12 semaines cyclique) car compatible avec tous les
    /// sports/objectifs sans hypothèse de date cible.
    var durationModeRaw: String = ProgramDurationMode.routineCyclic.rawValue
    var durationMode: ProgramDurationMode {
        get { ProgramDurationMode(rawValue: durationModeRaw) ?? .routineCyclic }
        set { durationModeRaw = newValue.rawValue }
    }

    /// Story sœur — date cible explicite (`deadlineFixed`) ou estimée par algo (`deadlineEstimated`).
    /// Nil pour `routineCyclic`. Source de vérité pour `ProgramAdapter` qui calcule N semaines.
    var targetDate: Date?

    /// conversation_history_json — [ConversationEntry] encodée en Data (lesson lessons_swiftdata #1 pour struct list).
    private var conversationHistoryData: Data
    var conversationHistory: [ConversationEntry] {
        get { (try? JSONDecoder().decode([ConversationEntry].self, from: conversationHistoryData)) ?? [] }
        set { conversationHistoryData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    /// Snapshot coachingProfile.requiresMedicalClearance au moment du save (review P0-6).
    /// Garantit la cohérence temporelle pour Léon Story 3.3 même si l'user change ses réponses PARQ après.
    var medicalClearanceAcknowledged: Bool

    /// Marker pour migrations futures du flow questionnaire (review P2-7).
    /// V1 = "running_v1". Permet à Story 3.3 de savoir quel format de conversation_history attendre.
    var questionnaireVersion: String

    var createdAt: Date
    var lastUpdatedAt: Date

    init(
        id: UUID = UUID(),
        userId: UUID,
        sportCode: String,
        level: String,
        goals: GoalsPayload,
        equipment: [String],
        constraints: [String],
        frequencyPerWeek: Int,
        frequencyLabel: String,
        sessionDurationMinutes: Int? = nil,
        freeTextNotes: String? = nil,
        conversationHistory: [ConversationEntry],
        medicalClearanceAcknowledged: Bool,
        questionnaireVersion: String,
        durationMode: ProgramDurationMode = .routineCyclic,
        targetDate: Date? = nil,
        createdAt: Date = Date(),
        lastUpdatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.sportCode = sportCode
        self.level = level
        self.goalsJsonData = (try? JSONEncoder().encode(goals)) ?? Data()
        self.equipment = equipment
        self.constraints = constraints
        self.recordsJsonData = nil
        self.frequencyPerWeek = frequencyPerWeek
        self.frequencyLabel = frequencyLabel
        self.sessionDurationMinutes = sessionDurationMinutes
        self.freeTextNotes = freeTextNotes
        self.conversationHistoryData = (try? JSONEncoder().encode(conversationHistory)) ?? Data()
        self.medicalClearanceAcknowledged = medicalClearanceAcknowledged
        self.questionnaireVersion = questionnaireVersion
        self.durationModeRaw = durationMode.rawValue
        self.targetDate = targetDate
        self.createdAt = createdAt
        self.lastUpdatedAt = lastUpdatedAt
    }
}
