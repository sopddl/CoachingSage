// CoachingSageTests/ViewModels/EditActiveSportsViewModelTests.swift
// Story 2.3 — édition active_sports.
import XCTest
import SageCore

@MainActor
final class EditActiveSportsViewModelTests: XCTestCase {

    private func makeProfile() -> CoachingProfile {
        let profile = CoachingProfile(id: UUID())
        profile.activeSports = ["running", "yoga"]
        return profile
    }

    func testEmptySelectionBlocksSave() async {
        let repo = MockCoachingProfileRepository()
        let vm = EditActiveSportsViewModel(coachingProfile: makeProfile(), coachingProfileRepository: repo)

        vm.selectedSports = []
        XCTAssertFalse(vm.canSave)

        await vm.save()
        XCTAssertEqual(repo.savedProfiles.count, 0, "save() doit no-op si selection vide")
    }

    func testSavePersistsSortedActiveSports() async {
        let repo = MockCoachingProfileRepository()
        let vm = EditActiveSportsViewModel(coachingProfile: makeProfile(), coachingProfileRepository: repo)

        vm.toggle(.running)            // remove running
        vm.toggle(.cycling)            // add cycling
        XCTAssertTrue(vm.canSave)

        await vm.save()

        XCTAssertEqual(repo.savedProfiles.first?.activeSports, ["cycling", "yoga"])
    }
}
