// CoachingSageTests/ViewModels/OnboardingViewModelTests.swift
// Story 2.2 — validators + finalize + import HealthKit.
import XCTest
import HealthKit
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

        // L'utilisateur a déjà saisi un sex → l'import ne doit pas l'écraser (check per-field `== nil`).
        // Les autres champs (vides) sont en revanche bien remplis par HK (corrige bug régression 2026-05-15).
        vm.biologicalSex = "female"

        await vm.importFromHealthKit()

        XCTAssertEqual(vm.biologicalSex, "female", "L'import ne doit pas écraser la saisie utilisateur")
        XCTAssertEqual(vm.weightKg, 80, "Les champs vides doivent être remplis par HK même si un autre champ a été saisi")
        XCTAssertEqual(vm.heightCm, 180, "Idem pour la taille")
        XCTAssertNotNil(vm.dateOfBirth, "Idem pour la date de naissance")
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
        XCTAssertEqual(vm.currentScreen, .thirdPartyAppsSync)  // Story 3.z — apps tierces
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .personalData)
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .howItWorks)  // Story sœur — écran pédagogique
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .sportsSelection)
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .equipment)
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .disclaimerPARQ)
    }

    // MARK: - Story 3.z — écran apps tierces (AC14)

    func testThirdPartyAppsSyncOuiDoesNotBlockGoNext() {
        // Purge le défaut résiduel d'un test précédent (UserDefaults.standard partagé).
        UserDefaults.standard.removeObject(forKey: OnboardingViewModel.thirdPartyAppsDefaultsKey)
        let vm = makeViewModel()
        vm.goNext() // → thirdPartyAppsSync
        XCTAssertEqual(vm.currentScreen, .thirdPartyAppsSync)
        vm.usesUnsyncedApps = true
        vm.toggleThirdPartyApp(.strava)
        vm.toggleThirdPartyApp(.garmin)
        vm.goNext() // → personalData (pas bloquant même sans "tutoriel suivi")
        XCTAssertEqual(vm.currentScreen, .personalData)
        // Persistance UserDefaults.
        XCTAssertNotNil(UserDefaults.standard.data(forKey: OnboardingViewModel.thirdPartyAppsDefaultsKey))
        UserDefaults.standard.removeObject(forKey: OnboardingViewModel.thirdPartyAppsDefaultsKey)
    }

    func testThirdPartyAppsSyncNonSkipsToPersonalData() {
        UserDefaults.standard.removeObject(forKey: OnboardingViewModel.thirdPartyAppsDefaultsKey)
        let vm = makeViewModel()
        vm.goNext() // → thirdPartyAppsSync
        vm.usesUnsyncedApps = false
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .personalData)
        // Persisté quand même (donne info "user a répondu Non" pour V2).
        XCTAssertNotNil(UserDefaults.standard.data(forKey: OnboardingViewModel.thirdPartyAppsDefaultsKey))
        UserDefaults.standard.removeObject(forKey: OnboardingViewModel.thirdPartyAppsDefaultsKey)
    }

    func testThirdPartyAppsSyncSkippedWithoutAnswerDoesNotPersist() {
        UserDefaults.standard.removeObject(forKey: OnboardingViewModel.thirdPartyAppsDefaultsKey)
        let vm = makeViewModel()
        vm.goNext() // → thirdPartyAppsSync
        // L'utilisateur n'a pas répondu (cas impossible via UI mais defensif).
        vm.saveThirdPartyAppsDeclaration()
        XCTAssertNil(UserDefaults.standard.data(forKey: OnboardingViewModel.thirdPartyAppsDefaultsKey))
    }

    func testToggleThirdPartyAppIsAdditive() {
        let vm = makeViewModel()
        vm.toggleThirdPartyApp(.strava)
        XCTAssertTrue(vm.declaredThirdPartyApps.contains("strava"))
        vm.toggleThirdPartyApp(.garmin)
        XCTAssertEqual(vm.declaredThirdPartyApps, ["strava", "garmin"])
        vm.toggleThirdPartyApp(.strava)
        XCTAssertEqual(vm.declaredThirdPartyApps, ["garmin"])
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

    // MARK: - Apple Watch suggestion (Story Autoprofil HealthKit)

    func testImportFromHealthKitSetsAppleWatchDetected() async {
        let healthKit = MockHealthKitService()
        healthKit.stubbedWorkoutSummary = HealthKitWorkoutSummary(
            totalCount: 12,
            weeklyAverage: 1.5,
            dominantActivityRawValue: nil,
            appleWatchDetected: true
        )
        let vm = makeViewModel(healthKit: healthKit)
        await vm.importFromHealthKit()
        XCTAssertTrue(vm.appleWatchDetected)
    }

    func testApplyAppleWatchEquipmentSuggestionViaImport() async {
        let healthKit = MockHealthKitService()
        healthKit.stubbedWorkoutSummary = HealthKitWorkoutSummary(
            totalCount: 5,
            weeklyAverage: 0.6,
            dominantActivityRawValue: nil,
            appleWatchDetected: true
        )
        let vm = makeViewModel(healthKit: healthKit)
        await vm.importFromHealthKit()

        XCTAssertTrue(vm.equipment.isEmpty, "pas pré-coché tant que screen 4 pas atteint")

        vm.applyAppleWatchEquipmentSuggestionIfNeeded()
        XCTAssertEqual(
            vm.equipment,
            [EquipmentCode.gpsWatch.rawValue, EquipmentCode.heartRateMonitor.rawValue]
        )
        XCTAssertTrue(vm.isAppleWatchSuggested(.gpsWatch))
        XCTAssertTrue(vm.isAppleWatchSuggested(.heartRateMonitor))
        XCTAssertFalse(vm.isAppleWatchSuggested(.roadBike))
    }

    func testApplyAppleWatchEquipmentSuggestionSkippedWhenUserAlreadyEdited() async {
        let healthKit = MockHealthKitService()
        healthKit.stubbedWorkoutSummary = HealthKitWorkoutSummary(
            totalCount: 5, weeklyAverage: 0.6,
            dominantActivityRawValue: nil, appleWatchDetected: true
        )
        let vm = makeViewModel(healthKit: healthKit)
        await vm.importFromHealthKit()
        vm.toggleEquipment(.roadBike)
        vm.applyAppleWatchEquipmentSuggestionIfNeeded()
        // L'utilisateur a déjà touché → pas de pré-cochage automatique.
        XCTAssertFalse(vm.equipment.contains(EquipmentCode.gpsWatch.rawValue))
        XCTAssertFalse(vm.isAppleWatchSuggested(.gpsWatch))
    }

    func testApplyAppleWatchEquipmentSuggestionSkippedWhenNoWatchDetected() async {
        let healthKit = MockHealthKitService()
        healthKit.stubbedWorkoutSummary = .empty
        let vm = makeViewModel(healthKit: healthKit)
        await vm.importFromHealthKit()
        vm.applyAppleWatchEquipmentSuggestionIfNeeded()
        XCTAssertTrue(vm.equipment.isEmpty)
        XCTAssertFalse(vm.appleWatchDetected)
    }

    func testToggleEquipmentMarksUserEdited() {
        let vm = makeViewModel()
        XCTAssertFalse(vm.hasUserEditedEquipment)
        vm.toggleEquipment(.indoorBike)
        XCTAssertTrue(vm.hasUserEditedEquipment)
        XCTAssertTrue(vm.equipment.contains(EquipmentCode.indoorBike.rawValue))
        vm.toggleEquipment(.indoorBike)
        XCTAssertFalse(vm.equipment.contains(EquipmentCode.indoorBike.rawValue))
    }
}
