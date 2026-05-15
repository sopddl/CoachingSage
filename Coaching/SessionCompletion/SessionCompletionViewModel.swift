// Coaching/SessionCompletion/SessionCompletionViewModel.swift
// Phase A boucle complétion — VM injecté dans SessionDetailView. Lit l'état
// existant au load (record déjà marqué terminé ou non) puis expose les méthodes
// save / clear qui appellent le repo. Le mapping (weekNumber, day) →
// PersistedSession.id est résolu côté repo (cf DefaultAdaptedProgramRepository).
import Foundation
import Observation

@MainActor
@Observable
final class SessionCompletionViewModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    enum SaveState: Equatable {
        case idle
        case saving
        case saved
        case failed(String)
    }

    let recordId: UUID
    let weekNumber: Int
    let day: Int
    private let repository: any AdaptedProgramRepository

    private(set) var loadState: LoadState = .idle
    private(set) var saveState: SaveState = .idle
    /// Record de complétion existant (nil si la session n'a pas été marquée terminée).
    /// Mis à jour après load() et après chaque save / clear réussi.
    private(set) var completion: SessionCompletionRecord?

    init(
        recordId: UUID,
        weekNumber: Int,
        day: Int,
        repository: any AdaptedProgramRepository
    ) {
        self.recordId = recordId
        self.weekNumber = weekNumber
        self.day = day
        self.repository = repository
    }

    func load() async {
        loadState = .loading
        do {
            completion = try await repository.loadSessionCompletion(
                recordId: recordId,
                weekNumber: weekNumber,
                day: day
            )
            loadState = .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    /// Sauvegarde ou met à jour la complétion. `actualDurationMinutes`, `rpe`
    /// et `notes` sont optionnels (Sophie 2026-05-14 : tous les champs sont
    /// facultatifs, seul le fait de marquer terminé compte pour l'onglet Progrès).
    func save(actualDurationMinutes: Int?, rpe: Int?, notes: String?) async {
        saveState = .saving
        let record = SessionCompletionRecord(
            completedAt: Date(),
            actualDurationMinutes: actualDurationMinutes,
            perceivedEffort: rpe,
            notes: notes?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )
        do {
            try await repository.recordSessionCompletion(
                recordId: recordId,
                weekNumber: weekNumber,
                day: day,
                record: record
            )
            completion = record
            saveState = .saved
        } catch {
            saveState = .failed(error.localizedDescription)
        }
    }

    /// Annule la complétion (retire l'entrée du dictionnaire). Pas de soft-delete :
    /// onglet Progrès reflète l'état réel du user.
    func clear() async {
        saveState = .saving
        do {
            try await repository.recordSessionCompletion(
                recordId: recordId,
                weekNumber: weekNumber,
                day: day,
                record: nil
            )
            completion = nil
            saveState = .saved
        } catch {
            saveState = .failed(error.localizedDescription)
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
