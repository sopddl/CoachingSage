import Foundation

public struct ProgramTemplate: Codable, Equatable, Sendable {
    public let id: String
    public let schemaVersion: Int
    public let sport: Sport
    public let level: Level
    public let name: LocalizedText
    public let durationWeeks: Int
    public let sessionsPerWeek: Int
    public let defaultObjective: LocalizedText
    public let assumedProfile: LocalizedText
    public let summary: LocalizedText
    public let weeks: [TemplateWeek]
    public let safetyNotes: LocalizedText
    public let progressionLogic: LocalizedText
    public let validatedAt: Date?
    public let validatedBy: String?

    public init(
        id: String,
        schemaVersion: Int,
        sport: Sport,
        level: Level,
        name: LocalizedText,
        durationWeeks: Int,
        sessionsPerWeek: Int,
        defaultObjective: LocalizedText,
        assumedProfile: LocalizedText,
        summary: LocalizedText,
        weeks: [TemplateWeek],
        safetyNotes: LocalizedText,
        progressionLogic: LocalizedText,
        validatedAt: Date? = nil,
        validatedBy: String? = nil
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.sport = sport
        self.level = level
        self.name = name
        self.durationWeeks = durationWeeks
        self.sessionsPerWeek = sessionsPerWeek
        self.defaultObjective = defaultObjective
        self.assumedProfile = assumedProfile
        self.summary = summary
        self.weeks = weeks
        self.safetyNotes = safetyNotes
        self.progressionLogic = progressionLogic
        self.validatedAt = validatedAt
        self.validatedBy = validatedBy
    }
}

public struct TemplateWeek: Codable, Equatable, Sendable {
    public let weekNumber: Int
    public let theme: LocalizedText
    public let goal: LocalizedText
    public let sessions: [TemplateSession]

    public init(weekNumber: Int, theme: LocalizedText, goal: LocalizedText, sessions: [TemplateSession]) {
        self.weekNumber = weekNumber
        self.theme = theme
        self.goal = goal
        self.sessions = sessions
    }
}

public struct TemplateSession: Codable, Equatable, Sendable {
    public let day: Int
    public let name: LocalizedText
    public let durationMinutes: Int
    public let type: SessionType
    public let warmup: LocalizedText?
    public let exercises: [TemplateExercise]
    public let cooldown: LocalizedText?

    public init(
        day: Int,
        name: LocalizedText,
        durationMinutes: Int,
        type: SessionType,
        warmup: LocalizedText?,
        exercises: [TemplateExercise],
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

public struct TemplateExercise: Codable, Equatable, Sendable {
    /// Contenu localisable AFFICHABLE (fr/en/es). Depuis l'i18n B2, `name.fr` peut être
    /// vulgarisé/traduit → n'est PLUS la clé de matching (cf `stableMatchKey`).
    public let name: LocalizedText

    /// Clé de matching STABLE explicite (JSON `match_key`), découplée du `name` affichable.
    /// Permet de vulgariser/traduire `name` sans casser findExercise / pattern resolver /
    /// illustrations / fiches « comment l'exécuter » / patch IA, tous keyés sur le nom FR
    /// technique. Optionnel : omis du JSON si `nil` (templates pré-i18n → fallback
    /// `name.canonical` via `stableMatchKey`).
    public let matchKey: String?

    /// Clé de matching effective : `matchKey` explicite si présent, sinon `name.canonical`
    /// (rétro-compatible pré-i18n). À utiliser pour TOUT matching interne.
    public var stableMatchKey: String { matchKey ?? name.canonical }

    public let sets: Int?
    public let reps: String?
    public let duration: String?
    public let restSeconds: Int?
    public let notes: LocalizedText?

    /// Hooks v2 — drive l'algo deterministic Story 3.3a (ProgramAdapter).
    /// `targetZone` reste un CODE brut (rendu verbatim, glossaire) → pas localisé.
    public let targetZone: String?
    public let requiredEquipment: [String]
    public let incompatibleConstraints: [String]
    public let alternatives: [LocalizedText]
    public let volumeAxis: VolumeAxis?

    public init(
        name: LocalizedText,
        matchKey: String? = nil,
        sets: Int? = nil,
        reps: String? = nil,
        duration: String? = nil,
        restSeconds: Int? = nil,
        notes: LocalizedText? = nil,
        targetZone: String? = nil,
        requiredEquipment: [String] = [],
        incompatibleConstraints: [String] = [],
        alternatives: [LocalizedText] = [],
        volumeAxis: VolumeAxis? = nil
    ) {
        self.name = name
        self.matchKey = matchKey
        self.sets = sets
        self.reps = reps
        self.duration = duration
        self.restSeconds = restSeconds
        self.notes = notes
        self.targetZone = targetZone
        self.requiredEquipment = requiredEquipment
        self.incompatibleConstraints = incompatibleConstraints
        self.alternatives = alternatives
        self.volumeAxis = volumeAxis
    }

    private enum CodingKeys: String, CodingKey {
        case name, matchKey, sets, reps, duration, restSeconds, notes
        case targetZone, requiredEquipment, incompatibleConstraints, alternatives, volumeAxis
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try c.decode(LocalizedText.self, forKey: .name)
        self.matchKey = try c.decodeIfPresent(String.self, forKey: .matchKey)
        self.sets = try c.decodeIfPresent(Int.self, forKey: .sets)
        self.reps = try c.decodeIfPresent(String.self, forKey: .reps)
        self.duration = try c.decodeIfPresent(String.self, forKey: .duration)
        self.restSeconds = try c.decodeIfPresent(Int.self, forKey: .restSeconds)
        self.notes = try c.decodeIfPresent(LocalizedText.self, forKey: .notes)
        self.targetZone = try c.decodeIfPresent(String.self, forKey: .targetZone)
        self.requiredEquipment = try c.decodeIfPresent([String].self, forKey: .requiredEquipment) ?? []
        self.incompatibleConstraints = try c.decodeIfPresent([String].self, forKey: .incompatibleConstraints) ?? []
        self.alternatives = try c.decodeIfPresent([LocalizedText].self, forKey: .alternatives) ?? []
        self.volumeAxis = try c.decodeIfPresent(VolumeAxis.self, forKey: .volumeAxis)
    }
}
