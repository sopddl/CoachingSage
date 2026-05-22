// CoachingSageTests/ViewModels/EditPersonalDataViewModelTests.swift
// Story 2.3 — édition données perso + import HealthKit (overwrite TOUJOURS, contrairement à Story 2.2).
import XCTest
import HealthKit
import SageCore

@MainActor
final class EditPersonalDataViewModelTests: XCTestCase {

    private func makeProfile() -> CoachingProfile {
        let profile = CoachingProfile(id: UUID())
        profile.biologicalSex = "female"
        profile.dateOfBirth = Date(timeIntervalSince1970: 0)
        profile.weightKg = 60
        profile.heightCm = 165
        return profile
    }

    func testImportFromHealthKitOverwritesExistingValues() async {
        let coachingRepo = MockCoachingProfileRepository()
        let hk = MockHealthKitService()
        hk.stubbedProfile = HealthKitProfileData(
            biologicalSex: .male,
            dateOfBirth: Date(timeIntervalSince1970: 100_000),
            bodyMassKg: 75,
            heightCm: 180
        )
        let vm = EditPersonalDataViewModel(
            coachingProfile: makeProfile(),
            coachingProfileRepository: coachingRepo,
            healthKitService: hk
        )

        // Différent de Story 2.2 : ici l'import écrase TOUJOURS, même si l'utilisateur a déjà des valeurs.
        await vm.importFromHealthKit()

        XCTAssertEqual(vm.biologicalSex, "male")
        XCTAssertEqual(vm.weightKg, 75)
        XCTAssertEqual(vm.heightCm, 180)
    }

    func testCanSaveRejectsOutOfRange() {
        let vm = EditPersonalDataViewModel(
            coachingProfile: makeProfile(),
            coachingProfileRepository: MockCoachingProfileRepository(),
            healthKitService: MockHealthKitService()
        )
        XCTAssertTrue(vm.canSave)
        vm.weightKg = 20
        XCTAssertFalse(vm.canSave)
        vm.weightKg = 70
        vm.heightCm = 50
        XCTAssertFalse(vm.canSave)
    }

    func testSavePersistsToCoachingRepository() async {
        let repo = MockCoachingProfileRepository()
        let vm = EditPersonalDataViewModel(
            coachingProfile: makeProfile(),
            coachingProfileRepository: repo,
            healthKitService: MockHealthKitService()
        )
        vm.weightKg = 65

        await vm.save()

        if case .success = vm.saveState {} else { XCTFail("attendu .success, obtenu \(vm.saveState)") }
        XCTAssertEqual(repo.savedProfiles.first?.weightKg, 65)
    }

    func testHealthKitProbablyDeniedWhenAlreadyAskedAndAllNil() async {
        let hk = MockHealthKitService()
        hk.hasRequestedAuthorization = true
        hk.stubbedProfile = HealthKitProfileData(biologicalSex: nil, dateOfBirth: nil, bodyMassKg: nil, heightCm: nil)
        let vm = EditPersonalDataViewModel(
            coachingProfile: makeProfile(),
            coachingProfileRepository: MockCoachingProfileRepository(),
            healthKitService: hk
        )
        await vm.importFromHealthKit()
        XCTAssertTrue(vm.healthKitProbablyDenied, "Doit basculer vers le label 'Réglages > Santé'")
    }
}
