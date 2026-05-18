// Coaching/Persistence/PersistedSession.swift
// Représentation flattenée d'une session d'`AdaptedProgram`. Tableau plat de
// sessions ordonnées par `(weekNumber, day)`. Les méta de week (theme/goal) sont
// conservées sur chaque session — coût mémoire négligeable, gain ergo côté UI.
import Foundation
import TemplateModel

public struct PersistedSession: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let weekNumber: Int
    public let weekTheme: String
    public let weekGoal: String
    /// Index d'ordre dans la semaine (1..N). N'a plus de sémantique de jour calendaire
    /// depuis la refonte vue semaine — l'utilisateur fait les séances dans l'ordre qu'il
    /// veut au cours de la semaine. Conservé pour le tri déterministe.
    public let day: Int
    public let name: String
    public let durationMinutes: Int
    public let type: SessionType
    public let warmup: String?
    public let exercises: [AdaptedExercise]
    public let cooldown: String?

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
        cooldown: String?
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
