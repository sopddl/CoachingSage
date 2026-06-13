import Foundation
import TemplateModel

/// Chantier indoor/outdoor vélo (2026-06-10) — lit/écrit le lieu choisi par séance et le
/// défaut de lieu du programme, via le repository (fetchById + update). Même pattern que
/// `ExerciseWeightService`. Aucune prescription : ne stocke que le choix de l'user.
@MainActor
final class SessionLocationService {
    private let repository: any AdaptedProgramRepository

    init(repository: any AdaptedProgramRepository) {
        self.repository = repository
    }

    /// Défaut de lieu du programme (réponse à la question au lancement) : "indoor"/"outdoor"/"both"/nil.
    func currentDefault(recordId: UUID) async throws -> String? {
        try await repository.fetchById(recordId: recordId)?.environmentDefaultRaw
    }

    func recordDefault(recordId: UUID, value: String?) async throws {
        guard let record = try await repository.fetchById(recordId: recordId) else { return }
        record.environmentDefaultRaw = value
        record.lastUpdatedAt = Date()
        try await repository.update(record)
    }

    /// Lieu choisi pour une séance (override du défaut). nil = pas d'override.
    func currentLocation(recordId: UUID, week: Int, day: Int) async throws -> SessionEnvironment? {
        try await repository.fetchById(recordId: recordId)?.sessionLocations.environment(week: week, day: day)
    }

    /// Enregistre le lieu choisi d'une séance. nil → retire l'override.
    func recordLocation(recordId: UUID, week: Int, day: Int, environment: SessionEnvironment?) async throws {
        guard let record = try await repository.fetchById(recordId: recordId) else { return }
        var state = record.sessionLocations
        state.set(environment, week: week, day: day)
        record.sessionLocations = state
        record.lastUpdatedAt = Date()
        try await repository.update(record)
    }
}
