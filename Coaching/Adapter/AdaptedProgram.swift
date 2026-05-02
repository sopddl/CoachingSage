// Coaching/Adapter/AdaptedProgram.swift
// Story 3.3a — résultat de l'adaptation algo deterministic d'un ProgramTemplate
// pour un profil utilisateur. 100% local, sync, 0 token, 0 réseau.
import Foundation
import TemplateModel

public struct AdaptedProgram: Codable, Equatable, Sendable {
    public let templateId: String
    public let sport: Sport
    public let level: Level
    public let appliedAt: Date
    public let weeks: [AdaptedWeek]
    public let appliedRules: [AppliedRule]

    /// Vrai si l'algo n'a pas su trouver une solution propre pour au moins un exercice
    /// (pas d'alternative compatible avec les contraintes/équipement). L'UI propose alors
    /// un fallback IA Story 3.3b.
    public let requiresAIAssist: Bool

    /// Texte court et lisible expliquant POURQUOI on propose le fallback IA. Nil si
    /// `requiresAIAssist == false`.
    public let aiAssistReason: String?

    public init(
        templateId: String,
        sport: Sport,
        level: Level,
        appliedAt: Date,
        weeks: [AdaptedWeek],
        appliedRules: [AppliedRule],
        requiresAIAssist: Bool,
        aiAssistReason: String? = nil
    ) {
        self.templateId = templateId
        self.sport = sport
        self.level = level
        self.appliedAt = appliedAt
        self.weeks = weeks
        self.appliedRules = appliedRules
        self.requiresAIAssist = requiresAIAssist
        self.aiAssistReason = aiAssistReason
    }
}

public struct AdaptedWeek: Codable, Equatable, Sendable {
    public let weekNumber: Int
    public let theme: String
    public let goal: String
    public let sessions: [AdaptedSession]

    public init(weekNumber: Int, theme: String, goal: String, sessions: [AdaptedSession]) {
        self.weekNumber = weekNumber
        self.theme = theme
        self.goal = goal
        self.sessions = sessions
    }
}

public struct AdaptedSession: Codable, Equatable, Sendable {
    public let day: Int
    public let name: String
    public let durationMinutes: Int
    public let type: SessionType
    public let warmup: String?
    public let exercises: [AdaptedExercise]
    public let cooldown: String?

    public init(
        day: Int,
        name: String,
        durationMinutes: Int,
        type: SessionType,
        warmup: String?,
        exercises: [AdaptedExercise],
        cooldown: String?
    ) {
        self.day = day
        self.name = name
        self.durationMinutes = durationMinutes
        self.type = type
        self.warmup = warmup
        self.exercises = exercises
        self.cooldown = cooldown
    }
}

public struct AdaptedExercise: Codable, Equatable, Sendable {
    /// Nom de l'exercice tel qu'il est affiché à l'utilisateur — peut être l'original
    /// ou un substitut si une règle a remplacé l'exercice.
    public let name: String

    /// Nom du `TemplateExercise` d'origine. Permet l'audit et la re-application
    /// d'un patch IA Story 3.3b par-dessus.
    public let originalName: String

    public let sets: Int?
    public let reps: String?
    public let duration: String?
    public let restSeconds: Int?
    public let notes: String?
    public let targetZone: String?
    public let volumeAxis: VolumeAxis?

    /// Vrai si l'exercice a été remplacé par un substitut (constraint ou equipment).
    public let wasSubstituted: Bool

    /// Texte court "constraint:knee-injury" ou "equipment:no-track-access" ou nil.
    public let substitutionReason: String?

    public init(
        name: String,
        originalName: String,
        sets: Int? = nil,
        reps: String? = nil,
        duration: String? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil,
        targetZone: String? = nil,
        volumeAxis: VolumeAxis? = nil,
        wasSubstituted: Bool = false,
        substitutionReason: String? = nil
    ) {
        self.name = name
        self.originalName = originalName
        self.sets = sets
        self.reps = reps
        self.duration = duration
        self.restSeconds = restSeconds
        self.notes = notes
        self.targetZone = targetZone
        self.volumeAxis = volumeAxis
        self.wasSubstituted = wasSubstituted
        self.substitutionReason = substitutionReason
    }

    /// Lift d'un `TemplateExercise` vers `AdaptedExercise` sans modification.
    /// Point d'entrée de la cascade : avant que les règles agissent, tout exercice
    /// est en version "passthrough".
    public static func passthrough(_ template: TemplateExercise) -> AdaptedExercise {
        AdaptedExercise(
            name: template.name,
            originalName: template.name,
            sets: template.sets,
            reps: template.reps,
            duration: template.duration,
            restSeconds: template.restSeconds,
            notes: template.notes,
            targetZone: template.targetZone,
            volumeAxis: template.volumeAxis,
            wasSubstituted: false,
            substitutionReason: nil
        )
    }
}

public struct AppliedRule: Codable, Equatable, Sendable {
    public let ruleType: RuleType
    public let weekNumber: Int
    public let day: Int
    public let originalExerciseName: String
    public let outcome: Outcome

    /// Phrase courte et lisible qui décrit la décision : "Plyo remplacée par marche
    /// nordique (knee-injury)", "Volume réduit de 4 à 3 sessions/sem", etc.
    public let detail: String

    public init(
        ruleType: RuleType,
        weekNumber: Int,
        day: Int,
        originalExerciseName: String,
        outcome: Outcome,
        detail: String
    ) {
        self.ruleType = ruleType
        self.weekNumber = weekNumber
        self.day = day
        self.originalExerciseName = originalExerciseName
        self.outcome = outcome
        self.detail = detail
    }

    public enum RuleType: String, Codable, Sendable {
        case constraintSubstitution
        case equipmentSubstitution
        case volumeModulation
        case levelPacing
        case medicalClearance
    }

    public enum Outcome: String, Codable, Sendable {
        case substituted
        case removed
        case downgraded
        case requiresAI
        case noChange
    }
}
