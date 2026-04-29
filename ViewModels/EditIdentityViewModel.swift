// ViewModels/EditIdentityViewModel.swift
// Story 2.3 — édition prénom. La langue est gérée live par LanguageManager via LanguageSelectorView ;
// le save synchronise simplement core_profiles.language avec la langue courante (Supabase analytics/multi-device).
import Foundation
import SwiftUI
import SageCore

@MainActor
@Observable
final class EditIdentityViewModel {
    var firstName: String
    var saveState: ViewState<Void> = .idle

    private let coreProfile: SageCoreProfile
    private let coreProfileRepository: any CoreProfileRepository
    private let languageManager: LanguageManager

    init(
        coreProfile: SageCoreProfile,
        coreProfileRepository: any CoreProfileRepository,
        languageManager: LanguageManager
    ) {
        self.coreProfile = coreProfile
        self.coreProfileRepository = coreProfileRepository
        self.languageManager = languageManager
        self.firstName = coreProfile.firstName ?? ""
    }

    var canSave: Bool {
        let trimmed = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...50).contains(trimmed.count) else { return false }
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

    func save() async {
        let trimmed = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...50).contains(trimmed.count) else { return }

        saveState = .loading
        coreProfile.firstName = trimmed
        // Synchronise la langue Supabase avec la langue courante (le LanguageManager a déjà commuté
        // l'UI live via LanguageSelectorView ; ici on persiste pour analytics/multi-device).
        coreProfile.language = languageManager.currentLanguage.rawValue
        coreProfile.updatedAt = Date()

        do {
            try await coreProfileRepository.save(coreProfile)
            saveState = .success(())
        } catch {
            saveState = .error(error as? AppError ?? .sync(error.localizedDescription))
        }
    }
}
