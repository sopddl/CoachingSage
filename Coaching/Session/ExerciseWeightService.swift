// Coaching/Session/ExerciseWeightService.swift
// Chantier charge muscu V2 — increment 2 (décision B). Persiste le poids NOTÉ par l'user
// par exo, via le repository existant (fetchById + update → AUCUN changement de protocole,
// zéro ripple sur les conformers, comme `ExerciseLevelService`). L'app ne prescrit jamais :
// ce service n'enregistre QUE ce que l'utilisateur saisit (et l'efface si ramené à 0).
import Foundation

@MainActor
final class ExerciseWeightService {
    private let repository: any AdaptedProgramRepository

    init(repository: any AdaptedProgramRepository) {
        self.repository = repository
    }

    /// Tous les poids notés du programme (pour pré-remplir le stepper + le rappel
    /// « dernière fois »). nil si record absent.
    func currentWeights(recordId: UUID) async throws -> ExerciseWeightState? {
        try await repository.fetchById(recordId: recordId)?.exerciseWeights
    }

    /// Enregistre (ou efface si `kg` nil/≤0) le poids noté d'un exo. `kg ≤ 0` → on retire
    /// l'entrée plutôt que de stocker « 0 kg » (règle P0 : jamais de 0 prescriptif/affiché).
    func recordWeight(recordId: UUID, exerciseKey: String, kg: Double?) async throws {
        guard let record = try await repository.fetchById(recordId: recordId) else { return }
        var state = record.exerciseWeights
        if let kg, kg > 0 {
            state.weights[exerciseKey] = kg
        } else {
            state.weights.removeValue(forKey: exerciseKey)
        }
        record.exerciseWeights = state
        record.lastUpdatedAt = Date()
        try await repository.update(record)
    }
}
