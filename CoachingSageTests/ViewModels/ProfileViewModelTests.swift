// CoachingSageTests/ViewModels/ProfileViewModelTests.swift
// Story 2.3 — fetch + analytics toggle debouncé + revert sur erreur.
import XCTest
@testable import CoachingSage
import SageCore

@MainActor
final class ProfileViewModelTests: XCTestCase {

    private func makeCore() -> SageCoreProfile {
        let core = SageCoreProfile(id: UUID())
        core.firstName = "Sophie"
        core.analyticsConsent = false
        return core
    }

    private func makeCoaching() -> CoachingProfile {
        CoachingProfile(id: UUID())
    }

    func testRefreshLoadsBothProfiles() async {
        let coreRepo = MockCoreProfileRepository()
        let core = makeCore()
        coreRepo.stubbedProfile = core
        let coachingRepo = MockCoachingProfileRepository()
        coachingRepo.stubbedProfile = makeCoaching()

        let vm = ProfileViewModel(
            coreProfileRepository: coreRepo,
            coachingProfileRepository: coachingRepo,
            authService: MockAuthService()
        )

        await vm.refresh()

        if case .success = vm.state {} else { XCTFail("attendu .success, obtenu \(vm.state)") }
        XCTAssertEqual(vm.analyticsConsent, false)
    }

    func testAnalyticsConsentDebouncedSingleSave() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = makeCore()
        let coachingRepo = MockCoachingProfileRepository()
        coachingRepo.stubbedProfile = makeCoaching()

        let vm = ProfileViewModel(
            coreProfileRepository: coreRepo,
            coachingProfileRepository: coachingRepo,
            authService: MockAuthService()
        )
        await vm.refresh()

        // Burst : 5 toggles rapides en moins de 500ms.
        for value in [true, false, true, false, true] {
            vm.scheduleAnalyticsSave(value: value)
            try? await Task.sleep(for: .milliseconds(20))
        }

        // Attendre que le debounce se déclenche.
        try? await Task.sleep(for: .milliseconds(700))

        XCTAssertEqual(coreRepo.savedProfiles.count, 1, "Burst de 5 toggles → 1 seul save (debounce 500ms)")
        XCTAssertEqual(coreRepo.savedProfiles.first?.analyticsConsent, true, "Dernière valeur conservée")
    }

    func testAnalyticsRevertsOnSaveError() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = makeCore()
        let coachingRepo = MockCoachingProfileRepository()
        coachingRepo.stubbedProfile = makeCoaching()

        let vm = ProfileViewModel(
            coreProfileRepository: coreRepo,
            coachingProfileRepository: coachingRepo,
            authService: MockAuthService()
        )
        await vm.refresh()

        // Switch repo to throw, simuler un toggle qui échoue.
        coreRepo.shouldThrow = true
        vm.analyticsConsent = true
        vm.scheduleAnalyticsSave(value: true)

        // Attendre debounce + save échoué.
        try? await Task.sleep(for: .milliseconds(700))

        XCTAssertEqual(vm.analyticsConsent, false, "Doit revert à OFF si l'utilisateur n'a pas re-toggled")
        XCTAssertTrue(vm.privacyErrorVisible)
    }
}
