// Coaching/Regen/ExerciseLevelService.swift
// Chantier charge muscu V2 — TRANCHE 5b. Câble l'algo pur `ExerciseLevelPlanner` à la
// persistance via le repository existant (fetchById + update → AUCUN changement de
// protocole, zéro ripple sur les conformers). Enregistre un ressenti utilisateur (D-D)
// et applique l'apprentissage (D-E), niveau initial dérivé si jamais loggé (G5).
import Foundation

@MainActor
final class ExerciseLevelService {
    private let repository: any AdaptedProgramRepository

    init(repository: any AdaptedProgramRepository) {
        self.repository = repository
    }

    /// Enregistre le ressenti d'un exo et applique la règle d'ajustement. Renvoie le
    /// nouveau niveau (pour une éventuelle suggestion explicable), ou nil si record absent.
    @discardableResult
    func recordFeedback(recordId: UUID,
                        exerciseKey: String,
                        feedback: ExerciseFeedback,
                        requiresMedicalClearance: Bool = false) async throws -> ExerciseLevel? {
        guard let record = try await repository.fetchById(recordId: recordId) else { return nil }
        var state = record.exerciseLevels
        let current = state.level(for: exerciseKey)
            ?? ExerciseLevel(level: InitialLevelResolver.initialLevel(forProfileLevel: record.level))
        let updated = ExerciseLevelPlanner.apply(feedback, to: current,
                                                 requiresMedicalClearance: requiresMedicalClearance)
        state.levels[exerciseKey] = updated
        record.exerciseLevels = state
        record.lastUpdatedAt = Date()
        try await repository.update(record)
        return updated
    }

    /// Niveau courant d'un exo (pour la consigne / suggestion). nil si jamais loggé.
    func currentLevel(recordId: UUID, exerciseKey: String) async throws -> ExerciseLevel? {
        try await repository.fetchById(recordId: recordId)?.exerciseLevels.level(for: exerciseKey)
    }
}
