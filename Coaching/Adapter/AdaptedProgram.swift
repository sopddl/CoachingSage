// Coaching/Adapter/AdaptedProgram.swift
// Story 3.3a — résultat de l'adaptation algo deterministic d'un ProgramTemplate
// pour un profil utilisateur. 100% local, sync, 0 token, 0 réseau.
import Foundation
import TemplateModel

/// Mode de durée du programme. Décide combien de semaines durent le programme et
/// si une date cible existe. Orthogonal à `ProgramMode` (= scheduling des sessions
/// pour drag&drop hebdo).
///
/// - `deadlineFixed` : durée = (`targetDate` − `appliedAt`) arrondie à la semaine.
///   Ex: course 10K dans 8 semaines → programme 8 semaines.
/// - `deadlineEstimated` : durée estimée par algo selon objectif + niveau. Ex: marathon
///   beginner → 16 semaines, semi advanced → 10 semaines.
/// - `routineCyclic` : durée fixe 12 semaines (= 3 mois), pas de date cible. Au bout
///   du cycle, `RoutineRegenService` propose un nouveau cycle adapté aux progrès.
public enum ProgramDurationMode: String, Codable, Equatable, Sendable {
    case deadlineFixed
    case deadlineEstimated
    case routineCyclic
}

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

    /// Mode de durée. `routineCyclic` = pas de date cible, programme renouvelable.
    public let durationMode: ProgramDurationMode

    /// Date cible pour les modes `deadlineFixed` et `deadlineEstimated`. Nil pour
    /// `routineCyclic`. Pour `deadlineEstimated`, c'est la date calculée par l'algo
    /// (= `appliedAt` + N semaines selon LUT objectif × niveau).
    public let targetDate: Date?

    public init(
        templateId: String,
        sport: Sport,
        level: Level,
        appliedAt: Date,
        weeks: [AdaptedWeek],
        appliedRules: [AppliedRule],
        requiresAIAssist: Bool,
        aiAssistReason: String? = nil,
        durationMode: ProgramDurationMode = .routineCyclic,
        targetDate: Date? = nil
    ) {
        self.templateId = templateId
        self.sport = sport
        self.level = level
        self.appliedAt = appliedAt
        self.weeks = weeks
        self.appliedRules = appliedRules
        self.requiresAIAssist = requiresAIAssist
        self.aiAssistReason = aiAssistReason
        self.durationMode = durationMode
        self.targetDate = targetDate
    }
}

public struct AdaptedWeek: Codable, Equatable, Sendable {
    public let weekNumber: Int
    public let theme: LocalizedText
    public let goal: LocalizedText
    public let sessions: [AdaptedSession]

    public init(weekNumber: Int, theme: LocalizedText, goal: LocalizedText, sessions: [AdaptedSession]) {
        self.weekNumber = weekNumber
        self.theme = theme
        self.goal = goal
        self.sessions = sessions
    }
}

public struct AdaptedSession: Codable, Equatable, Sendable {
    public let day: Int
    public let name: LocalizedText
    public let durationMinutes: Int
    public let type: SessionType
    public let warmup: LocalizedText?
    public let exercises: [AdaptedExercise]
    public let cooldown: LocalizedText?

    public init(
        day: Int,
        name: LocalizedText,
        durationMinutes: Int,
        type: SessionType,
        warmup: LocalizedText?,
        exercises: [AdaptedExercise],
        cooldown: LocalizedText?
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

/// Latéralité d'un exercice (chantier dosage D4). `String` raw pour un blob JSON stable.
public enum ExerciseSide: String, Codable, Equatable, Sendable {
    case left
    case right
    case bilateral
}

public struct AdaptedExercise: Codable, Equatable, Sendable {
    /// Nom de l'exercice tel qu'il est affiché à l'utilisateur — peut être l'original
    /// ou un substitut si une règle a remplacé l'exercice. Localisable (fr/en/es).
    public let name: LocalizedText

    /// Clé de matching STABLE du `TemplateExercise` d'origine (= `template.stableMatchKey`,
    /// défaut nom FR technique). Reste une `String` découplée du `name` affichable : c'est
    /// elle qui pilote findExercise / pattern resolver / illustrations / fiches / patch IA,
    /// même quand `name.fr` est vulgarisé/traduit (i18n B2).
    public let originalName: String

    public let sets: Int?
    public let reps: String?
    public let duration: String?
    public let restSeconds: Int?

    /// Dosage structuré i18n (chantier 2026-06-14, pilote yoga). Copié tel quel du template.
    /// Quand présent, PRIME sur `reps`/`duration` à l'affichage + label minuteur (`DoseFormatter`,
    /// FR/EN/ES). `nil` = legacy. Cf `TemplateExercise.dose`.
    public let dose: Dose?

    public let notes: LocalizedText?
    public let targetZone: String?
    public let volumeAxis: VolumeAxis?

    /// Charge notée par l'user (« 12 kg », optionnel). Chantier dosage D1 : AUCUN poids
    /// PRESCRIT — sert uniquement de mémoire. Tracking auto (« comme la dernière fois ») = V2.
    public let load: String?

    /// Latéralité structurée (chantier dosage D4). nil = non renseigné ; `.bilateral` par
    /// défaut pour les exos à deux côtés ; `.left`/`.right` pour un côté donné. La détection
    /// d'unilatéralité V1 reste dérivée du texte (reps « par côté ») tant que les templates
    /// ne peuplent pas ce champ — il existe pour ne pas casser le modèle au moment où ils le feront.
    public let side: ExerciseSide?

    /// Vrai si l'exercice a été remplacé par un substitut (constraint ou equipment).
    public let wasSubstituted: Bool

    /// Texte court "constraint:knee-injury" ou "equipment:no-track-access" ou nil.
    public let substitutionReason: String?

    /// Exercice à faire HORS DE L'EAU (natation : renforcement à sec, élastique, gainage…).
    /// Chantier compréhensibilité 2026-06-24 : la vue regroupe ces exos en fin de séance sous
    /// un bandeau « à faire hors de l'eau (avant/après) » au lieu de les intercaler dans le bassin.
    /// `Bool?` (et non `Bool`) = compat décodage des `AdaptedProgram` persistés AVANT ce champ
    /// (clé absente → nil → traité comme « pas hors-eau »). nil/false = exo dans l'eau.
    public let dryLand: Bool?

    public init(
        name: LocalizedText,
        originalName: String,
        sets: Int? = nil,
        reps: String? = nil,
        duration: String? = nil,
        restSeconds: Int? = nil,
        dose: Dose? = nil,
        notes: LocalizedText? = nil,
        targetZone: String? = nil,
        volumeAxis: VolumeAxis? = nil,
        load: String? = nil,
        side: ExerciseSide? = nil,
        wasSubstituted: Bool = false,
        substitutionReason: String? = nil,
        dryLand: Bool? = nil
    ) {
        self.name = name
        self.originalName = originalName
        self.sets = sets
        self.reps = reps
        self.duration = duration
        self.restSeconds = restSeconds
        self.dose = dose
        self.notes = notes
        self.targetZone = targetZone
        self.volumeAxis = volumeAxis
        self.load = load
        self.side = side
        self.wasSubstituted = wasSubstituted
        self.substitutionReason = substitutionReason
        self.dryLand = dryLand
    }

    /// Nom à afficher à l'user, résolu pour `locale` : retire le suffixe technique
    /// `(pattern xxx)` issu des templates JSON (utilisé par `ExercisePatternResolver`
    /// étape 1 regex, jamais destiné à l'affichage). 14 templates strength embarquent
    /// ce suffixe. Story 3.35e : retire aussi les « / » (jamais de slash à l'écran) → « · ».
    /// NB : le suffixe `(pattern …)` n'existe que dans le corpus FR — la regex est
    /// no-op sur EN/ES, donc `displayName(locale)` reste correct dans toutes les langues.
    public func displayName(_ locale: Locale) -> String {
        Self.cleanForDisplay(name.resolved(locale))
    }

    /// Nettoyage d'affichage d'un nom déjà résolu : retire le suffixe `(pattern xxx)`
    /// (FR-only) et remplace « / » par « · ». Réutilisé par le label du minuteur FOCUS
    /// (`PhaseLabel.raw`) qui résout la locale au render.
    public static func cleanForDisplay(_ resolved: String) -> String {
        let cleaned = resolved.replacingOccurrences(
            of: #"\s*\(pattern[\s:]+[^)]+\)\s*"#,
            with: " ",
            options: .regularExpression
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned
            .replacingOccurrences(of: "/", with: " · ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Lift d'un `TemplateExercise` vers `AdaptedExercise` sans modification.
    /// Point d'entrée de la cascade : avant que les règles agissent, tout exercice
    /// est en version "passthrough". `originalName` = clé de matching stable (`stableMatchKey`).
    public static func passthrough(_ template: TemplateExercise, sport: Sport? = nil) -> AdaptedExercise {
        AdaptedExercise(
            name: template.name,
            originalName: template.stableMatchKey,
            sets: template.sets,
            reps: template.reps,
            duration: template.duration,
            restSeconds: template.restSeconds,
            dose: template.dose,
            notes: template.notes,
            targetZone: template.targetZone,
            volumeAxis: template.volumeAxis,
            wasSubstituted: false,
            substitutionReason: nil,
            dryLand: Self.isDryLand(template, sport: sport)
        )
    }

    /// Heuristique hors-eau (natation uniquement) : un exo dont l'équipement requis est
    /// renseigné MAIS ne contient pas « pool » se fait à sec (mat/élastique/haltère…).
    /// nil (pas true/false) quand non hors-eau → garde le JSON propre + compat décodage.
    static func isDryLand(_ template: TemplateExercise, sport: Sport?) -> Bool? {
        guard sport == .swimming else { return nil }
        let eq = template.requiredEquipment
        guard !eq.isEmpty, !eq.contains("pool") else { return nil }
        return true
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
