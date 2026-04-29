// CoachingSageTests/ViewModels/EditIdentityViewModelTests.swift
// Story 2.3 — édition prénom + langue.
import XCTest
@testable import CoachingSage
import SageCore

@MainActor
final class EditIdentityViewModelTests: XCTestCase {

    private func makeProfile() -> SageCoreProfile {
        let profile = SageCoreProfile(id: UUID())
        profile.firstName = "Sophie"
        profile.language = "fr"
        return profile
    }

    func testCanSaveRequiresNonEmptyFirstName() {
        let repo = MockCoreProfileRepository()
        let lm = LanguageManager()
        let vm = EditIdentityViewModel(coreProfile: makeProfile(), coreProfileRepository: repo, languageManager: lm)

        XCTAssertTrue(vm.canSave)
        vm.firstName = "   "
        XCTAssertFalse(vm.canSave, "whitespace-only doit désactiver canSave")
        vm.firstName = String(repeating: "a", count: 51)
        XCTAssertFalse(vm.canSave, "> 50 chars rejeté")
    }

    func testSavePersistsAndSyncsCurrentLanguage() async {
        let repo = MockCoreProfileRepository()
        let lm = LanguageManager()
        // La langue est commutée live par LanguageSelectorView via LanguageManager (UserDefaults).
        // Le save doit persister cette langue dans core_profiles pour Supabase analytics/multi-device.
        lm.switchLanguage(to: .english)

        let profile = makeProfile()
        let vm = EditIdentityViewModel(coreProfile: profile, coreProfileRepository: repo, languageManager: lm)

        vm.firstName = "Léon"

        await vm.save()

        if case .success = vm.saveState {
            // OK
        } else {
            XCTFail("saveState attendu .success, obtenu \(vm.saveState)")
        }
        XCTAssertEqual(repo.savedProfiles.first?.firstName, "Léon")
        XCTAssertEqual(repo.savedProfiles.first?.language, "en", "Doit refléter la langue courante du LanguageManager")
    }

    func testSavePropagatesError() async {
        let repo = MockCoreProfileRepository()
        repo.shouldThrow = true
        let lm = LanguageManager()
        let vm = EditIdentityViewModel(coreProfile: makeProfile(), coreProfileRepository: repo, languageManager: lm)

        await vm.save()

        if case .error = vm.saveState {
            // OK
        } else {
            XCTFail("saveState attendu .error, obtenu \(vm.saveState)")
        }
        XCTAssertNotNil(vm.saveErrorMessage)
    }
}
