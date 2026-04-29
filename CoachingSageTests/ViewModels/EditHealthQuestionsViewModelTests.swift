// CoachingSageTests/ViewModels/EditHealthQuestionsViewModelTests.swift
// Story 2.3 — édition PARQ + recalcul requires_medical_clearance.
import XCTest
@testable import CoachingSage
import SageCore

@MainActor
final class EditHealthQuestionsViewModelTests: XCTestCase {

    private func makeProfile() -> CoachingProfile {
        let profile = CoachingProfile(id: UUID())
        profile.parqResponses = PARQQuestion.defaultResponses
        profile.requiresMedicalClearance = false
        return profile
    }

    func testRequiresMedicalClearanceIsTrueIfAnyYes() {
        let vm = EditHealthQuestionsViewModel(
            coachingProfile: makeProfile(),
            coachingProfileRepository: MockCoachingProfileRepository()
        )
        XCTAssertFalse(vm.requiresMedicalClearance)
        vm.toggleResponse(for: .q1ChestPain, value: true)
        XCTAssertTrue(vm.requiresMedicalClearance)
        vm.toggleResponse(for: .q1ChestPain, value: false)
        XCTAssertFalse(vm.requiresMedicalClearance, "regression: tout à non doit recalc à false")
    }

    func testSaveUpdatesRequiresMedicalClearanceFlag() async {
        let repo = MockCoachingProfileRepository()
        let profile = makeProfile()
        let vm = EditHealthQuestionsViewModel(
            coachingProfile: profile,
            coachingProfileRepository: repo
        )

        vm.toggleResponse(for: .q4HeartMedication, value: true)
        vm.save()

        await waitForSaveSuccess(vm: vm)

        XCTAssertEqual(repo.savedProfiles.first?.requiresMedicalClearance, true)
        XCTAssertEqual(repo.savedProfiles.first?.parqResponses[PARQQuestion.q4HeartMedication.rawValue], true)
    }

    func testSaveDowngradesClearanceWhenAllSetToFalse() async {
        let repo = MockCoachingProfileRepository()
        let profile = makeProfile()
        profile.requiresMedicalClearance = true
        profile.parqResponses[PARQQuestion.q1ChestPain.rawValue] = true
        let vm = EditHealthQuestionsViewModel(
            coachingProfile: profile,
            coachingProfileRepository: repo
        )

        // L'utilisateur passe tous à non.
        for question in PARQQuestion.allCases {
            vm.toggleResponse(for: question, value: false)
        }
        vm.save()

        await waitForSaveSuccess(vm: vm)

        XCTAssertEqual(repo.savedProfiles.first?.requiresMedicalClearance, false,
                       "Recalcul obligatoire : si toutes réponses non, requires_medical_clearance doit repasser à false")
    }

    private func waitForSaveSuccess(vm: EditHealthQuestionsViewModel, timeout: TimeInterval = 1.0) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if case .success = vm.saveState { return }
            try? await Task.sleep(for: .milliseconds(20))
        }
        XCTFail("save() n'a pas atteint .success en \(timeout)s — saveState=\(vm.saveState)")
    }
}
