import Foundation

public struct ProgramTemplate: Codable, Equatable, Sendable {
    public let id: String
    public let schemaVersion: Int
    public let sport: Sport
    public let level: Level
    public let name: String
    public let durationWeeks: Int
    public let sessionsPerWeek: Int
    public let defaultObjective: String
    public let assumedProfile: String
    public let summary: String
    public let weeks: [TemplateWeek]
    public let safetyNotes: String
    public let progressionLogic: String
    public let validatedAt: Date?
    public let validatedBy: String?

    public init(
        id: String,
        schemaVersion: Int,
        sport: Sport,
        level: Level,
        name: String,
        durationWeeks: Int,
        sessionsPerWeek: Int,
        defaultObjective: String,
        assumedProfile: String,
        summary: String,
        weeks: [TemplateWeek],
        safetyNotes: String,
        progressionLogic: String,
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
    public let theme: String
    public let goal: String
    public let sessions: [TemplateSession]

    public init(weekNumber: Int, theme: String, goal: String, sessions: [TemplateSession]) {
        self.weekNumber = weekNumber
        self.theme = theme
        self.goal = goal
        self.sessions = sessions
    }
}

public struct TemplateSession: Codable, Equatable, Sendable {
    public let day: Int
    public let name: String
    public let durationMinutes: Int
    public let type: SessionType
    public let warmup: String?
    public let exercises: [TemplateExercise]
    public let cooldown: String?

    public init(
        day: Int,
        name: String,
        durationMinutes: Int,
        type: SessionType,
        warmup: String?,
        exercises: [TemplateExercise],
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

public struct TemplateExercise: Codable, Equatable, Sendable {
    public let name: String
    public let sets: Int?
    public let reps: String?
    public let duration: String?
    public let restSeconds: Int?
    public let notes: String?

    /// Hooks v2 — drive l'algo deterministic Story 3.3a (ProgramAdapter).
    public let targetZone: String?
    public let requiredEquipment: [String]
    public let incompatibleConstraints: [String]
    public let alternatives: [String]
    public let volumeAxis: VolumeAxis?

    public init(
        name: String,
        sets: Int? = nil,
        reps: String? = nil,
        duration: String? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil,
        targetZone: String? = nil,
        requiredEquipment: [String] = [],
        incompatibleConstraints: [String] = [],
        alternatives: [String] = [],
        volumeAxis: VolumeAxis? = nil
    ) {
        self.name = name
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
        case name, sets, reps, duration, restSeconds, notes
        case targetZone, requiredEquipment, incompatibleConstraints, alternatives, volumeAxis
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try c.decode(String.self, forKey: .name)
        self.sets = try c.decodeIfPresent(Int.self, forKey: .sets)
        self.reps = try c.decodeIfPresent(String.self, forKey: .reps)
        self.duration = try c.decodeIfPresent(String.self, forKey: .duration)
        self.restSeconds = try c.decodeIfPresent(Int.self, forKey: .restSeconds)
        self.notes = try c.decodeIfPresent(String.self, forKey: .notes)
        self.targetZone = try c.decodeIfPresent(String.self, forKey: .targetZone)
        self.requiredEquipment = try c.decodeIfPresent([String].self, forKey: .requiredEquipment) ?? []
        self.incompatibleConstraints = try c.decodeIfPresent([String].self, forKey: .incompatibleConstraints) ?? []
        self.alternatives = try c.decodeIfPresent([String].self, forKey: .alternatives) ?? []
        self.volumeAxis = try c.decodeIfPresent(VolumeAxis.self, forKey: .volumeAxis)
    }
}
