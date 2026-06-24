// CoachingSageTests/ViewModels/OnboardingViewModelTests.swift
// Onboarding app « fil de Léon » — validators + navigation 3 écrans + accord HealthKit + finalize.
import XCTest
import HealthKit
import SwiftData
import SageCore

@MainActor
final class OnboardingViewModelTests: XCTestCase {

    /// `SageCoreProfile`/`CoachingProfile` sont des `@Model` : instancier/muter une row hors d'un
    /// `ModelContainer` actif déclenche `fatalError: failed to find a currently active container`.
    /// On en crée un en mémoire et on le RETIENT (sinon dealloc → crash, cf DefaultCoachingProfileRepositoryTests).
    private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: SageCoreProfile.self, CoachingProfile.self, configurations: config)
        _ = container.mainContext
    }

    override func tearDown() {
        container = nil
    }

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

    func testHasValidFirstName() {
        let vm = makeViewModel()
        XCTAssertFalse(vm.hasValidFirstName)
        vm.firstName = "Sophie"
        XCTAssertTrue(vm.hasValidFirstName)
        vm.firstName = "   "
        XCTAssertFalse(vm.hasValidFirstName)
        vm.firstName = String(repeating: "a", count: 51)
        XCTAssertFalse(vm.hasValidFirstName, "51 caractères > borne 50")
    }

    func testCanStartRequiresNameAndAtLeastOneSport() {
        let vm = makeViewModel()
        XCTAssertFalse(vm.canStart)
        vm.firstName = "Sophie"
        XCTAssertFalse(vm.canStart, "sport manquant")
        vm.activeSports.insert("running")
        XCTAssertTrue(vm.canStart)
        vm.firstName = ""
        XCTAssertFalse(vm.canStart, "prénom manquant")
    }

    // MARK: - Navigation (3 écrans)

    func testGoNextAdvancesAcrossThreeScreens() {
        let vm = makeViewModel()
        XCTAssertEqual(vm.currentScreen, .welcome)
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .parq)
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .closing)
        vm.goNext()
        XCTAssertEqual(vm.currentScreen, .closing, "pas d'écran après la clôture")
    }

    func testCanGoPreviousOnlyOnParq() {
        let vm = makeViewModel()
        XCTAssertFalse(vm.canGoPrevious, "fil = premier écran")
        vm.goNext() // parq
        XCTAssertTrue(vm.canGoPrevious)
        vm.goPrevious()
        XCTAssertEqual(vm.currentScreen, .welcome)
        vm.goNext(); vm.goNext() // closing
        XCTAssertFalse(vm.canGoPrevious, "retour interdit sur la clôture (finalize en cours)")
        vm.goPrevious()
        XCTAssertEqual(vm.currentScreen, .closing, "goPrevious no-op sur la clôture")
    }

    // MARK: - Accord HealthKit

    func testAuthorizeHealthDataCallsWorkoutAndFitness() async {
        let healthKit = MockHealthKitService()
        let vm = makeViewModel(healthKit: healthKit)
        XCTAssertTrue(vm.showHealthAuthorizeButton)

        await vm.authorizeHealthData()

        XCTAssertEqual(healthKit.requestWorkoutAndFitnessAuthorizationCallCount, 1)
        XCTAssertEqual(healthKit.requestAuthorizationCallCount, 0, "ne demande PAS le profil corporel")
        XCTAssertTrue(vm.healthAuthorized)
        XCTAssertFalse(vm.showHealthAuthorizeButton, "bouton masqué après autorisation")
    }

    func testAuthorizeHealthDataSwallowsError() async {
        let healthKit = MockHealthKitService()
        healthKit.requestAuthorizationShouldThrow = HealthKitError.notAvailable
        let vm = makeViewModel(healthKit: healthKit)

        await vm.authorizeHealthData()

        // Best-effort : un refus/erreur ne bloque pas — on marque quand même comme « demandé ».
        XCTAssertTrue(vm.healthAuthorized)
    }

    // MARK: - Finalize

    func testFinalizePersistsCoreAndCoachingProfile() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())
        let coachingRepo = MockCoachingProfileRepository()
        let vm = makeViewModel(coreRepo: coreRepo, coachingRepo: coachingRepo)

        vm.firstName = "Sophie"
        vm.activeSports = ["running", "yoga"]
        vm.analyticsConsent = true

        await vm.finalize()

        if case .success = vm.saveState {} else {
            XCTFail("Expected .success, got \(vm.saveState)")
        }
        XCTAssertEqual(coreRepo.savedProfiles.first?.firstName, "Sophie")
        XCTAssertEqual(coreRepo.savedProfiles.first?.analyticsConsent, true)

        let saved = coachingRepo.savedProfiles.first
        XCTAssertEqual(coachingRepo.savedProfiles.count, 1)
        XCTAssertNotNil(saved?.onboardingCompletedAt)
        XCTAssertEqual(saved?.disclaimerVersionAccepted, "1.0")
        XCTAssertEqual(saved?.activeSports, ["running", "yoga"], "tri ASC déterministe")
    }

    func testFinalizeDoesNotCollectBodyData() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())
        let coachingRepo = MockCoachingProfileRepository()
        let vm = makeViewModel(coreRepo: coreRepo, coachingRepo: coachingRepo)

        vm.firstName = "Sophie"
        vm.activeSports = ["running"]

        await vm.finalize()

        // Zéro saisie corporelle : l'app ne lit ni n'écrit le corps.
        let saved = coachingRepo.savedProfiles.first
        XCTAssertNil(saved?.biologicalSex)
        XCTAssertNil(saved?.dateOfBirth)
        XCTAssertNil(saved?.weightKg)
        XCTAssertNil(saved?.heightCm)
    }

    func testFinalizeSetsRequiresMedicalClearanceIfAnyParqYes() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())
        let coachingRepo = MockCoachingProfileRepository()
        let vm = makeViewModel(coreRepo: coreRepo, coachingRepo: coachingRepo)

        vm.firstName = "Sophie"
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
        vm.activeSports = ["yoga"]

        await vm.finalize()

        XCTAssertEqual(coachingRepo.savedProfiles.first?.requiresMedicalClearance, false)
    }

    func testFinalizeIsIdempotent() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())
        let coachingRepo = MockCoachingProfileRepository()
        let vm = makeViewModel(coreRepo: coreRepo, coachingRepo: coachingRepo)

        vm.firstName = "Sophie"
        vm.activeSports = ["running"]

        await vm.finalize()
        await vm.finalize() // re-déclenchée par le .task de la clôture → no-op

        XCTAssertEqual(coachingRepo.savedProfiles.count, 1, "pas de double-save")
    }

    func testFinalizeRequestsSwimAuthIfSwimmingSelected() async {
        let coreRepo = MockCoreProfileRepository()
        coreRepo.stubbedProfile = SageCoreProfile(id: UUID())
        let healthKit = MockHealthKitService()
        let vm = makeViewModel(coreRepo: coreRepo, healthKit: healthKit)

        vm.firstName = "Sophie"
        vm.activeSports = ["swimming"]

        await vm.finalize()

        XCTAssertEqual(healthKit.requestSwimAuthorizationCallCount, 1)
    }
}
