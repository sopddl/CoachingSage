// CoachingSageTests/ViewModels/OnboardingViewModelTests.swift
// Story 2.2 — validators + finalize + import HealthKit.
import XCTest
import HealthKit
@testable import CoachingSage
import SageCore

@MainActor
final class OnboardingViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeViewModel(
        coreRepo: MockCoreProfileRepository = MockCoreProfileRepository(),
        coachingRepo: MockCoachingProfileRepository = MockCoachingProfileRepository(),
        healthKit: MockHealthKitService = MockHealthKitService()
    ) -> OnboardingViewModel {
        OnboardingViewModel(
            coreProfileRepository: coreRepo,
            coachingProfileRepository: coachingRepo,
            healthKitService: healthKit
        )
    }

    // MARK: - Validators

    func testCanContinueScreen1RequiresFirstName() {
        let vm = makeViewModel()
        XCTAssertFalse(vm.canContinueScreen1)
        vm.firstName = "Sophie"
        XCTAssertTrue(vm.canContinueScreen1)
        vm.firstName = "   "
        XCTAssertFalse(vm.canContinueScreen1)
    }

    func testCanContinueScreen2RequiresAllFields() {
        let vm = makeViewModel()
        XCTAssertFalse(vm.canContinueScreen2)
        vm.biologicalSex = "female"
        vm.dateOfBirth = Date(timeIntervalSince1970: 0)
        vm.weightKg = 60
        XCTAssertFalse(vm.canContinueScreen2, "height nil → invalide")
        vm.heightCm = 170
        XCTAssertTrue(vm.canContinueScreen2)
    }

    func testCanContinueScreen2RejectsOutOfRange() {
        let vm = makeViewModel()
        vm.biologicalSex = "male"
        vm.dateOfBirth = Date(timeIntervalSince1970: 0)
        vm.weightKg = 20
        vm.heightCm = 170
        XCTAssertFalse(vm.canContinueScreen2, "weight 20 hors range")
        vm.weightKg = 70
        vm.heightCm = 50
        XCTAssertFalse(vm.canContinueScreen2, "height 50 hors range")
    }

    func testCanContinueScreen3RequiresAtLeastOneSport() {
        let vm = makeViewModel()
        XCTAssertFalse(vm.canContinueScreen3)
        vm.activeSports.insert("running")
        XCTAssertTrue(vm.canContinueScreen3)
    }

    // MARK: - Finalize

    func testFinalizeSetsOnboardingCompletedAt() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())
        let coachingRepo = MockCoachingProfileRepository()
        let vm = makeViewModel(coreRepo: coreRepo, coachingRepo: coachingRepo)

        vm.firstName = "Sophie"
        vm.biologicalSex = "female"
        vm.dateOfBirth = Date(timeIntervalSince1970: 0)
        vm.weightKg = 60
        vm.heightCm = 170
        vm.activeSports = ["running"]

        await vm.finalize()

        if case .success = vm.saveState {} else {
            XCTFail("Expected .success, got \(vm.saveState)")
        }
        XCTAssertEqual(coachingRepo.savedProfiles.count, 1)
        XCTAssertNotNil(coachingRepo.savedProfiles.first?.onboardingCompletedAt)
        XCTAssertEqual(coachingRepo.savedProfiles.first?.disclaimerVersionAccepted, "1.0")
        XCTAssertEqual(coreRepo.savedProfiles.first?.firstName, "Sophie")
    }

    func testFinalizeSetsRequiresMedicalClearanceIfAnyParqYes() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())
        let coachingRepo = MockCoachingProfileRepository()
        let vm = makeViewModel(coreRepo: coreRepo, coachingRepo: coachingRepo)

        vm.firstName = "Sophie"
        vm.biologicalSex = "female"
        vm.dateOfBirth = Date()
        vm.weightKg = 60
        vm.heightCm = 170
        vm.activeSports = ["running"]
        vm.parqResponses[PARQQuestion.q1ChestPain.rawValue] = true

        await vm.finalize()

        XCTAssertEqual(coachingRepo.savedProfiles.first?.requiresMedicalClearance, true)
    }

    func testFinalizeAllParqNoMeansNoMedicalClearance() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())
        let coachingRepo = MockCoachingProfileRepository()
        let vm = makeViewModel(coreRepo: coreRepo, coachingRepo: coachingRepo)

        vm.firstName = "Sophie"
        vm.biologicalSex = "female"
        vm.dateOfBirth = Date()
        vm.weightKg = 60
        vm.heightCm = 170
        vm.activeSports = ["yoga"]

        await vm.finalize()

        XCTAssertEqual(coachingRepo.savedProfiles.first?.requiresMedicalClearance, false)
    }

    // MARK: - Import HealthKit

    func testImportFromHealthKitPrefillsFieldsWhenUserHasntEdited() async {
        let healthKit = MockHealthKitService()
        healthKit.stubbedProfile = HealthKitProfileData(
            biologicalSex: .female,
            dateOfBirth: Date(timeIntervalSince1970: 0),
            bodyMassKg: 62.5,
            heightCm: 168
        )
        let vm = makeViewModel(healthKit: healthKit)

        await vm.importFromHealthKit()

        XCTAssertEqual(vm.biologicalSex, "female")
        XCTAssertEqual(vm.weightKg, 62.5)
        XCTAssertEqual(vm.heightCm, 168)
        XCTAssertNotNil(vm.dateOfBirth)
    }

    func testImportFromHealthKitDoesNotOverrideEditedFields() async {
        let healthKit = MockHealthKitService()
        healthKit.stubbedProfile = HealthKitProfileData(
            biologicalSex: .male,
            dateOfBirth: Date(timeIntervalSince1970: 0),
            bodyMassKg: 80,
            heightCm: 180
        )
        let vm = makeViewModel(healthKit: healthKit)

        // L'utilisateur a déjà saisi un sex → le flag hasUserEditedScreen2 doit bloquer l'override.
        vm.biologicalSex = "female"

        await vm.importFromHealthKit()

        XCTAssertEqual(vm.biologicalSex, "female", "L'import ne doit pas écraser la saisie utilisateur")
        XCTAssertNil(vm.weightKg, "Aucun champ ne doit être touché si l'utilisateur a édité")
    }

    func testImportFromHealthKitMapsBiologicalSex() {
        XCTAssertEqual(OnboardingViewModel.mapBiologicalSex(.female), "female")
        XCTAssertEqual(OnboardingViewModel.mapBiologicalSex(.male), "male")
        XCTAssertEqual(OnboardingViewModel.mapBiologicalSex(.other), "other")
        XCTAssertNil(OnboardingViewModel.mapBiologicalSex(.notSet))
    }

    // MARK: - Navigation

    func testGoNextAdvancesScreen() {
        let vm = makeViewModel()
        XCTAssertEqual(vm.currentScreen, .firstNameLanguage)
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .personalData)
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .sportsSelection)
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .equipment)
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .disclaimerPARQ)
    }

    func testCanContinueScreen4IsAlwaysTrue() {
        let vm = makeViewModel()
        XCTAssertTrue(vm.canContinueScreen4, "Equipment optionnel — toujours valide")
        vm.equipment.insert(EquipmentCode.gpsWatch.rawValue)
        XCTAssertTrue(vm.canContinueScreen4)
    }

    func testFinalizePersistsEquipmentSorted() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())
        let coachingRepo = MockCoachingProfileRepository()
        let vm = makeViewModel(coreRepo: coreRepo, coachingRepo: coachingRepo)

        vm.firstName = "Sophie"
        vm.biologicalSex = "female"
        vm.dateOfBirth = Date()
        vm.weightKg = 60
        vm.heightCm = 170
        vm.activeSports = ["running"]
        vm.equipment = [
            EquipmentCode.indoorBike.rawValue,
            EquipmentCode.gpsWatch.rawValue
        ]

        await vm.finalize()

        // Tri ASC déterministe pour stabilité Postgres TEXT[].
        XCTAssertEqual(coachingRepo.savedProfiles.first?.equipment, [
            EquipmentCode.gpsWatch.rawValue,
            EquipmentCode.indoorBike.rawValue
        ])
    }
}
