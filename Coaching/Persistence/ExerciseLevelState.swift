// Coaching/Persistence/ExerciseLevelState.swift
// Chantier charge muscu V2 — TRANCHE 2. Niveau relatif CACHÉ par exercice (D-B).
// JAMAIS de kg : c'est une échelle interne 1...5 qui ne sert qu'à choisir le wording
// du delta (« un peu plus / pareil / un peu moins ») et le palier de résistance.
// Clé = `AdaptedExercise.originalName` (= stableMatchKey) : stable cross-cycle et i18n,
// partagée par toutes les occurrences du même exo dans le programme.
import Foundation

/// Bornes de l'échelle cachée. 3 = point de départ médian (cf `InitialLevelResolver`).
public enum ExerciseLevelBounds {
    public static let min = 1
    public static let max = 5
    public static func clamp(_ v: Int) -> Int { Swift.max(min, Swift.min(max, v)) }
}

public struct ExerciseLevel: Codable, Equatable, Sendable {
    /// Niveau interne 1...5 (jamais affiché).
    public var level: Int
    /// Compteur de ressentis « facile » consécutifs (D-E : 2× facile → +1 cran).
    public var consecutiveEasy: Int

    public init(level: Int, consecutiveEasy: Int = 0) {
        self.level = ExerciseLevelBounds.clamp(level)
        self.consecutiveEasy = Swift.max(0, consecutiveEasy)
    }
}

public struct ExerciseLevelState: Codable, Equatable, Sendable {
    /// Clé = stableMatchKey de l'exo → niveau relatif.
    public var levels: [String: ExerciseLevel]

    public init(levels: [String: ExerciseLevel] = [:]) { self.levels = levels }

    public static let empty = ExerciseLevelState()

    public func level(for key: String) -> ExerciseLevel? { levels[key] }
}
