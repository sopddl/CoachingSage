// Coaching/Persistence/ExerciseWeightState.swift
// Chantier charge muscu V2 — increment 2 (décision B, 2026-06-09). Poids NOTÉ par
// l'utilisateur, par exercice. CONTRAIRE à `ExerciseLevelState` (niveau caché, jamais kg) :
// ici on stocke un kg RÉEL saisi par l'user — mais l'app ne le PRESCRIT JAMAIS (EU MDR :
// l'user note, on s'en souvient → « la dernière fois : X kg »). Aucun nombre fabriqué.
// Clé = `AdaptedExercise.originalName` (= stableMatchKey) : stable cross-cycle et i18n,
// partagée par toutes les occurrences du même exo. PRÉSERVÉ au renouvellement de cycle.
import Foundation

public struct ExerciseWeightState: Codable, Equatable, Sendable {
    /// Clé = stableMatchKey de l'exo → poids noté en kg (saisi par l'user, jamais 0).
    public var weights: [String: Double]

    public init(weights: [String: Double] = [:]) { self.weights = weights }

    public static let empty = ExerciseWeightState()

    public func weight(for key: String) -> Double? { weights[key] }
}
