// ViewModels/EditEquipmentViewModel.swift
// Édition de l'équipement générique multi-sport (CoachingProfile).
// L'empty state est valide (user sans matériel).
import Foundation
import SwiftUI
import SageCore

@MainActor
@Observable
final class EditEquipmentViewModel {
    var selectedEquipment: Set<String>
    var saveState: ViewState<Void> = .idle

    private let coachingProfile: CoachingProfile
    private let coachingProfileRepository: any CoachingProfileRepository

    init(
        coachingProfile: CoachingProfile,
        coachingProfileRepository: any CoachingProfileRepository
    ) {
        self.coachingProfile = coachingProfile
        self.coachingProfileRepository = coachingProfileRepository
        self.selectedEquipment = Set(coachingProfile.equipment)
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

    func toggle(_ item: EquipmentCode) {
        let code = item.rawValue
        if selectedEquipment.contains(code) {
            selectedEquipment.remove(code)
        } else {
            selectedEquipment.insert(code)
        }
    }

    func save() async {
        saveState = .loading
        coachingProfile.equipment = Array(selectedEquipment).sorted()
        coachingProfile.updatedAt = Date()

        do {
            try await coachingProfileRepository.save(coachingProfile)
            saveState = .success(())
        } catch {
            saveState = .error(error as? AppError ?? .sync(error.localizedDescription))
        }
    }
}
