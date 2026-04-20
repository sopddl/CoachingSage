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

    public init(
        name: String,
        sets: Int? = nil,
        reps: String? = nil,
        duration: String? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil
    ) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.duration = duration
        self.restSeconds = restSeconds
        self.notes = notes
    }
}
