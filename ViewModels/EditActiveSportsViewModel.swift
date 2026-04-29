// ViewModels/EditActiveSportsViewModel.swift
// Story 2.3 — édition active_sports. Pas de hard-delete CoachingSportProfile (Epic 3 cleanup).
import Foundation
import SwiftUI
import SageCore

@MainActor
@Observable
final class EditActiveSportsViewModel {
    var selectedSports: Set<String>
    var saveState: ViewState<Void> = .idle

    private let coachingProfile: CoachingProfile
    private let coachingProfileRepository: any CoachingProfileRepository

    init(
        coachingProfile: CoachingProfile,
        coachingProfileRepository: any CoachingProfileRepository
    ) {
        self.coachingProfile = coachingProfile
        self.coachingProfileRepository = coachingProfileRepository
        self.selectedSports = Set(coachingProfile.activeSports)
    }

    var canSave: Bool {
        guard !selectedSports.isEmpty else { return false }
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

    func toggle(_ sport: SportCode) {
        let code = sport.rawValue
        if selectedSports.contains(code) {
            selectedSports.remove(code)
        } else {
            selectedSports.insert(code)
        }
    }

    func save() async {
        // Double-check côté VM (review : défense en profondeur même si UI désactive bouton).
        guard !selectedSports.isEmpty else { return }
        saveState = .loading

        coachingProfile.activeSports = Array(selectedSports).sorted()
        coachingProfile.updatedAt = Date()

        do {
            try await coachingProfileRepository.save(coachingProfile)
            saveState = .success(())
        } catch {
            saveState = .error(error as? AppError ?? .sync(error.localizedDescription))
        }
    }
}
