// ViewModels/EditHealthQuestionsViewModel.swift
// Story 2.3 — édition PARQ-light. Recalcul requiresMedicalClearance avant save.
// Sérialisation Task save (review P0-3) : annule la précédente si retap rapide.
import Foundation
import SwiftUI
import SageCore

@MainActor
@Observable
final class EditHealthQuestionsViewModel {
    var parqResponses: [String: Bool]
    var saveState: ViewState<Void> = .idle

    private let coachingProfile: CoachingProfile
    private let coachingProfileRepository: any CoachingProfileRepository
    private var saveTask: Task<Void, Never>?

    init(
        coachingProfile: CoachingProfile,
        coachingProfileRepository: any CoachingProfileRepository
    ) {
        self.coachingProfile = coachingProfile
        self.coachingProfileRepository = coachingProfileRepository
        self.parqResponses = coachingProfile.parqResponses
    }

    /// Recalcul live (UI + finalize). True si au moins une réponse à `true`.
    var requiresMedicalClearance: Bool {
        parqResponses.values.contains(true)
    }

    var canSave: Bool {
        if case .loading = saveState { return false }
        return true
    }

    var isSaving: Bool {
        if case .loading = saveState { return true }
        return false
    }

    var saveErrorMessage: String? {
        if case .error(let err) = saveState { return err.localizedDescription }
        return nil
    }

    func toggleResponse(for question: PARQQuestion, value: Bool) {
        parqResponses[question.rawValue] = value
    }

    /// Sérialise les saves : annule la Task précédente avant d'en lancer une nouvelle.
    /// Évite que 2 saves rapides écrasent l'un l'autre avec un calcul stale (Léon Epic 3 critique).
    func save() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            await self?.performSave()
        }
    }

    private func performSave() async {
        // Snapshot pris au début de la Task — fige les valeurs même si l'user retap pendant le save.
        // Évite que la mutation `coachingProfile.parqResponses = parqResponses` reflète une saisie
        // ultérieure pendant qu'un save en vol est encore actif (review post-implem P0-3).
        let snapshotResponses = parqResponses
        let snapshotClearance = snapshotResponses.values.contains(true)

        // Check d'annulation AVANT toute mutation : si la Task a été annulée par save() entre
        // la création et l'exécution, on ne touche ni au @Model ni au saveState.
        guard !Task.isCancelled else { return }

        saveState = .loading
        coachingProfile.parqResponses = snapshotResponses
        coachingProfile.requiresMedicalClearance = snapshotClearance
        coachingProfile.updatedAt = Date()

        do {
            try await coachingProfileRepository.save(coachingProfile)
            guard !Task.isCancelled else { return }
            saveState = .success(())
        } catch {
            guard !Task.isCancelled else { return }
            saveState = .error(error as? AppError ?? .sync(error.localizedDescription))
        }
    }
}
