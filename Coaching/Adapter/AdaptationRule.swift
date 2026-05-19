// Coaching/Adapter/AdaptationRule.swift
// Story 3.3a — protocole pour les règles deterministic appliquées en cascade par
// `ProgramAdapter`. Une règle reçoit l'état du programme post-règles précédentes
// et retourne un nouvel état + le log des décisions prises.
import Foundation
import TemplateModel

public protocol AdaptationRule: Sendable {
    var ruleType: AppliedRule.RuleType { get }

    /// Applique la règle sur les semaines passées. La règle ne mute jamais l'input —
    /// elle retourne une nouvelle version. La cascade se charge de chaîner ces sorties.
    /// Le `template` original est passé pour lookup des hooks v2 par
    /// (week, day, exercise.name) — les hooks ne sont pas dupliqués dans
    /// `AdaptedExercise` pour ne pas alourdir le runtime model.
    func apply(
        weeks: [AdaptedWeek],
        template: ProgramTemplate,
        sport: Sport,
        level: Level,
        sportProfile: AdapterSportProfile,
        coachingProfile: AdapterCoachingProfile
    ) -> RuleResult
}

public extension ProgramTemplate {
    /// Lookup d'un `TemplateExercise` par (week, day, name). Renvoie nil si non trouvé.
    func findExercise(weekNumber: Int, day: Int, name: String) -> TemplateExercise? {
        guard let week = weeks.first(where: { $0.weekNumber == weekNumber }) else { return nil }
        guard let session = week.sessions.first(where: { $0.day == day }) else { return nil }
        return session.exercises.first(where: { $0.name == name })
    }
}

public struct RuleResult: Equatable, Sendable {
    public let weeks: [AdaptedWeek]
    public let appliedRules: [AppliedRule]

    /// Vrai si la règle a détecté au moins un cas où elle ne sait pas patcher
    /// proprement (ex: contrainte sans alternative dans `TemplateExercise.alternatives`).
    public let triggeredAIAssist: Bool

    /// Si `triggeredAIAssist == true`, raison concise pour l'UI/log.
    public let aiAssistReason: String?

    public init(
        weeks: [AdaptedWeek],
        appliedRules: [AppliedRule],
        triggeredAIAssist: Bool = false,
        aiAssistReason: String? = nil
    ) {
        self.weeks = weeks
        self.appliedRules = appliedRules
        self.triggeredAIAssist = triggeredAIAssist
        self.aiAssistReason = aiAssistReason
    }
}

/// Façade découplée de SwiftData/`CoachingSportProfile` pour permettre à
/// l'adapter de tourner en pur Swift testable (pas besoin de ModelContainer
/// dans les tests).
public struct AdapterSportProfile: Equatable, Sendable {
    public let constraints: [String]
    public let equipment: [String]
    public let frequencyPerWeek: Int
    public let sessionDurationMinutes: Int?

    /// Story sœur — primary goal code (`goals.primary`). Utilisé par le
    /// `ProgramDurationResolver` pour la LUT estimated weeks (sport × goal × level).
    public let goal: String

    /// Story 3.13 — secondary goals (`goals.secondary`). Vide par défaut.
    /// Consommé par `SecondaryGoalOverlay` après l'adapter pour moduler les séances.
    public let secondaryGoals: [String]

    /// Story 3.13 — code sport (`sportCode`) propagé pour les rules + overlay strategy.
    /// Optionnel pour rétrocompat des call sites historiques.
    public let sportCode: String

    /// Story sœur — mode de durée du programme. Source de vérité pour la durée
    /// finale en sortie de `ProgramAdapter` (truncate/extend des weeks template).
    public let durationMode: ProgramDurationMode

    /// Story sœur — date cible explicite (`deadlineFixed` only). Nil pour les
    /// autres modes ; le resolver calcule la date pour `deadlineEstimated`.
    public let targetDate: Date?

    public init(
        constraints: [String],
        equipment: [String],
        frequencyPerWeek: Int,
        sessionDurationMinutes: Int? = nil,
        goal: String = "",
        secondaryGoals: [String] = [],
        sportCode: String = "",
        durationMode: ProgramDurationMode = .routineCyclic,
        targetDate: Date? = nil
    ) {
        self.constraints = constraints
        self.equipment = equipment
        self.frequencyPerWeek = frequencyPerWeek
        self.sessionDurationMinutes = sessionDurationMinutes
        self.goal = goal
        self.secondaryGoals = secondaryGoals
        self.sportCode = sportCode
        self.durationMode = durationMode
        self.targetDate = targetDate
    }
}

/// Façade découplée de SwiftData/`CoachingProfile` — ne porte que les champs
/// utiles à l'adaptation (essentiellement le flag PARQ medical clearance).
public struct AdapterCoachingProfile: Equatable, Sendable {
    public let requiresMedicalClearance: Bool

    public init(requiresMedicalClearance: Bool) {
        self.requiresMedicalClearance = requiresMedicalClearance
    }
}
