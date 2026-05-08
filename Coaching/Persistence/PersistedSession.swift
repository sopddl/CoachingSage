// Coaching/Persistence/PersistedSession.swift
// Story 3.8 — représentation flattenée d'une session d'`AdaptedProgram` enrichie
// d'un état mutable (`plannedDate`) modifiable par le drag&drop hebdo.
//
// On flatten weeks/sessions car le drag&drop écrit dans `sessionsJSON[i].plannedDate`
// (cf AC Story 3.8) et le tri prochaine séance opère sur un tableau plat de sessions.
// Les méta de week (theme/goal) sont conservées sur chaque session — coût mémoire
// négligeable (12 sessions × 1 string), gain ergonomique majeur côté UI.
import Foundation
import TemplateModel

public struct PersistedSession: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let weekNumber: Int
    public let weekTheme: String
    public let weekGoal: String
    public let day: Int                         // 1-7 (lundi-dimanche)
    public let name: String
    public let durationMinutes: Int
    public let type: SessionType
    public let warmup: String?
    public let exercises: [AdaptedExercise]
    public let cooldown: String?

    /// Date posée par drag&drop hebdo. `nil` quand la session est dans le pool
    /// `.ondemand`. Le premier drag&drop sur une session bascule le `AdaptedProgramRecord`
    /// en `.planned` mode.
    public var plannedDate: Date?

    public init(
        id: UUID = UUID(),
        weekNumber: Int,
        weekTheme: String,
        weekGoal: String,
        day: Int,
        name: String,
        durationMinutes: Int,
        type: SessionType,
        warmup: String?,
        exercises: [AdaptedExercise],
        cooldown: String?,
        plannedDate: Date? = nil
    ) {
        self.id = id
        self.weekNumber = weekNumber
        self.weekTheme = weekTheme
        self.weekGoal = weekGoal
        self.day = day
        self.name = name
        self.durationMinutes = durationMinutes
        self.type = type
        self.warmup = warmup
        self.exercises = exercises
        self.cooldown = cooldown
        self.plannedDate = plannedDate
    }
}

/// État de complétion d'un programme adapté.
/// Story 3.9 lit ce dictionnaire pour calculer streak, volume, et détecter les PR.
public struct ProgramCompletionState: Codable, Equatable, Sendable {
    /// sessionId (UUID `PersistedSession`) → record de complétion.
    public var sessionRecords: [UUID: SessionCompletionRecord]

    public init(sessionRecords: [UUID: SessionCompletionRecord] = [:]) {
        self.sessionRecords = sessionRecords
    }

    public static let empty = ProgramCompletionState()

    public var completedCount: Int { sessionRecords.count }
}

public struct SessionCompletionRecord: Codable, Equatable, Sendable {
    public var completedAt: Date
    public var actualDurationMinutes: Int?
    /// RPE 1-10 (Borg CR-10).
    public var perceivedEffort: Int?
    public var notes: String?

    public init(
        completedAt: Date,
        actualDurationMinutes: Int? = nil,
        perceivedEffort: Int? = nil,
        notes: String? = nil
    ) {
        self.completedAt = completedAt
        self.actualDurationMinutes = actualDurationMinutes
        self.perceivedEffort = perceivedEffort
        self.notes = notes
    }
}
