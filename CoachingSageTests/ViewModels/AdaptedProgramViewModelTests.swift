// CoachingSageTests/ViewModels/AdaptedProgramViewModelTests.swift
// Story 3.3b — tests orchestration hand-off Léon depuis AdaptedProgramView.
// Vérifie : trigger auto si requiresAIAssist, no-op si déjà patché, error mapping
// + showQuotaSheet, persistance via repo, application patch in-place.
import XCTest
import TemplateModel
import SageCore

@MainActor
final class AdaptedProgramViewModelTests: XCTestCase {

    // MARK: - triggerLeonIfNeeded

    func testTriggerSkipsWhenProgramDoesNotRequireAIAssist() async {
        let vm = makeVM(requiresAIAssist: false)
        await vm.triggerLeonIfNeeded()
        XCTAssertEqual(vm.requestState, .idle)
        XCTAssertEqual(vm.aiService.callCount, 0)
    }

    func testTriggerSkipsWhenLeonNotesAlreadyPresent() async {
        let vm = makeVM(
            requiresAIAssist: true,
            initialLeonNotes: LeonAppliedNotes(personalizationNote: "Hi", safetyNotes: [], adjustmentNotes: [])
        )
        await vm.triggerLeonIfNeeded()
        XCTAssertEqual(vm.requestState, .idle)
        XCTAssertEqual(vm.aiService.callCount, 0)
    }

    func testTriggerCallsServiceWhenRequiresAIAssistAndNoNotes() async {
        let vm = makeVM(requiresAIAssist: true, aiAssistReason: "Cas atypique")
        vm.aiService.stubbedResponse = AdaptRareResponse(
            patch: AdaptationPatch(personalizationNote: "Bien joué Sarah"),
            quota: .init(used: 1, limit: 10, resetsAt: Date(), tier: "free"),
            meta: nil
        )

        await vm.triggerLeonIfNeeded()

        XCTAssertEqual(vm.aiService.callCount, 1)
        XCTAssertEqual(vm.aiService.receivedReason, .atypicalConstraints)
        XCTAssertEqual(vm.requestState, .success)
        XCTAssertEqual(vm.leonNotes?.personalizationNote, "Bien joué Sarah")
    }

    // Léon+ — le tier reçu dans la réponse doit synchroniser StoreKitService,
    // pas seulement après un achat (sinon une expiration/remboursement côté
    // serveur ne se refléterait qu'au prochain boot de l'app).
    func testSuccessfulResponseSyncsTierToStoreKit() async {
        let vm = makeVM(requiresAIAssist: true, aiAssistReason: "Cas atypique")
        vm.aiService.stubbedResponse = AdaptRareResponse(
            patch: AdaptationPatch(),
            quota: .init(used: 3, limit: -1, resetsAt: Date(), tier: "plus"),
            meta: nil
        )

        await vm.triggerLeonIfNeeded()

        XCTAssertEqual(vm.requestState, .success)
        XCTAssertEqual(vm.storeKitService.appliedTiers, ["plus"])
    }

    func testTriggerOnlyOnceEvenIfCalledMultipleTimes() async {
        let vm = makeVM(requiresAIAssist: true)
        await vm.triggerLeonIfNeeded()
        await vm.triggerLeonIfNeeded()
        await vm.triggerLeonIfNeeded()
        XCTAssertEqual(vm.aiService.callCount, 1)
    }

    // MARK: - requestLeonExplicit

    func testRequestExplicitTriggersWithUserExplicitReason() async {
        let vm = makeVM(requiresAIAssist: false)
        await vm.requestLeonExplicit()
        XCTAssertEqual(vm.aiService.callCount, 1)
        XCTAssertEqual(vm.aiService.receivedReason, .userExplicit)
    }

    func testRequestExplicitWorksEvenIfAlreadyTriggeredOnce() async {
        let vm = makeVM(requiresAIAssist: true)
        await vm.triggerLeonIfNeeded()        // 1ère fois auto
        await vm.requestLeonExplicit()        // 2ème fois explicite
        XCTAssertEqual(vm.aiService.callCount, 2)
    }

    // MARK: - Error states

    func testQuotaExceededErrorSetsShowQuotaSheet() async {
        let vm = makeVM(requiresAIAssist: true)
        vm.aiService.stubbedError = .quotaExceeded(resetsAt: Date(timeIntervalSinceNow: 3600))

        await vm.triggerLeonIfNeeded()

        XCTAssertTrue(vm.showQuotaSheet)
        if case .error(let err) = vm.requestState {
            if case .quotaExceeded = err {} else { XCTFail("expected .quotaExceeded, got \(err)") }
        } else {
            XCTFail("expected .error state, got \(vm.requestState)")
        }
    }

    func testAnthropicUnavailableErrorDoesNotShowQuotaSheet() async {
        let vm = makeVM(requiresAIAssist: true)
        vm.aiService.stubbedError = .anthropicUnavailable

        await vm.triggerLeonIfNeeded()

        XCTAssertFalse(vm.showQuotaSheet)
        XCTAssertEqual(vm.requestState, .error(.anthropicUnavailable))
    }

    // Note : on ne teste pas le wrapping .network ici. Le buildPayload est tolérant
    // (try? sur les fetch de profils → profil minimal accepté), et les autres
    // erreurs réseau (URLSession) ne sont pas mockables sans wrapper. Couverture
    // .network par AdaptationPatchTests.mapErrorResponse + intégration Story 3.3b.

    // MARK: - Patch application + persistance

    func testSuccessfulPatchAppliesSubstitutionsToProgram() async {
        let vm = makeVM(requiresAIAssist: true, recordId: UUID())
        vm.aiService.stubbedResponse = AdaptRareResponse(
            patch: AdaptationPatch(exerciseSubstitutions: [
                .init(weekNumber: 1, day: 1, originalExerciseName: "Footing 25 min",
                      replacementExerciseName: "Marche 20 min", reason: "knee")
            ]),
            quota: .init(used: 1, limit: 10, resetsAt: Date(), tier: "free"),
            meta: nil
        )

        await vm.triggerLeonIfNeeded()

        let mutated = vm.program.weeks[0].sessions[0].exercises[0]
        XCTAssertEqual(mutated.name, "Marche 20 min")
        XCTAssertTrue(mutated.wasSubstituted)
    }

    func testSuccessfulPatchPersistsToRepoIfRecordIdProvided() async {
        let recordId = UUID()
        let vm = makeVM(requiresAIAssist: true, recordId: recordId)
        vm.aiService.stubbedResponse = AdaptRareResponse(
            patch: AdaptationPatch(personalizationNote: "Hi"),
            quota: .init(used: 1, limit: 10, resetsAt: Date(), tier: "free"),
            meta: nil
        )

        await vm.triggerLeonIfNeeded()

        XCTAssertEqual(vm.adaptedRepo.appliedLeonPatches.count, 1)
        XCTAssertEqual(vm.adaptedRepo.appliedLeonPatches.first?.recordId, recordId)
    }

    func testEmptyPatchNotPersistedEvenIfRecordIdProvided() async {
        let vm = makeVM(requiresAIAssist: true, recordId: UUID())
        vm.aiService.stubbedResponse = AdaptRareResponse(
            patch: AdaptationPatch(),
            quota: .init(used: 1, limit: 10, resetsAt: Date(), tier: "free"),
            meta: nil
        )

        await vm.triggerLeonIfNeeded()

        XCTAssertEqual(vm.adaptedRepo.appliedLeonPatches.count, 0)
    }

    func testNoPersistAttemptIfRecordIdNil() async {
        let vm = makeVM(requiresAIAssist: true, recordId: nil)
        vm.aiService.stubbedResponse = AdaptRareResponse(
            patch: AdaptationPatch(personalizationNote: "Hi"),
            quota: .init(used: 1, limit: 10, resetsAt: Date(), tier: "free"),
            meta: nil
        )

        await vm.triggerLeonIfNeeded()

        XCTAssertEqual(vm.adaptedRepo.appliedLeonPatches.count, 0)
    }

    // MARK: - Helpers

    private func makeVM(
        requiresAIAssist: Bool,
        aiAssistReason: String? = nil,
        initialLeonNotes: LeonAppliedNotes? = nil,
        recordId: UUID? = nil
    ) -> TestableViewModel {
        let aiService = MockSageCoachingAIService()
        let healthBuilder = MockHealthSummaryBuilder()
        let coreRepo = MockCoreProfileRepository()
        let coachingRepo = MockCoachingProfileRepository()
        let adaptedRepo = MockAdaptedProgramRepository()
        let storeKitService = MockStoreKitService()

        let program = AdaptedProgram(
            templateId: "running-beginner-c25k",
            sport: .running,
            level: .beginner,
            appliedAt: Date(),
            weeks: [
                AdaptedWeek(weekNumber: 1, theme: "Découverte", goal: "Reprise", sessions: [
                    AdaptedSession(
                        day: 1, name: "S1", durationMinutes: 25, type: .endurance,
                        warmup: nil,
                        exercises: [AdaptedExercise(name: "Footing 25 min", originalName: "Footing 25 min")],
                        cooldown: nil
                    )
                ])
            ],
            appliedRules: [],
            requiresAIAssist: requiresAIAssist,
            aiAssistReason: aiAssistReason
        )

        let vm = AdaptedProgramViewModel(
            program: program,
            initialLeonNotes: initialLeonNotes,
            recordId: recordId,
            aiService: aiService,
            healthSummaryBuilder: healthBuilder,
            coreRepo: coreRepo,
            coachingRepo: coachingRepo,
            adaptedRepo: adaptedRepo,
            storeKitService: storeKitService
        )

        return TestableViewModel(
            vm: vm,
            aiService: aiService,
            healthBuilder: healthBuilder,
            coreRepo: coreRepo,
            coachingRepo: coachingRepo,
            adaptedRepo: adaptedRepo,
            storeKitService: storeKitService
        )
    }
}

/// Helper qui expose les mocks pour assertions tout en proxyfiant le VM.
@MainActor
@dynamicMemberLookup
private final class TestableViewModel {
    let vm: AdaptedProgramViewModel
    let aiService: MockSageCoachingAIService
    let healthBuilder: MockHealthSummaryBuilder
    let coreRepo: MockCoreProfileRepository
    let coachingRepo: MockCoachingProfileRepository
    let adaptedRepo: MockAdaptedProgramRepository
    let storeKitService: MockStoreKitService

    init(vm: AdaptedProgramViewModel, aiService: MockSageCoachingAIService,
         healthBuilder: MockHealthSummaryBuilder, coreRepo: MockCoreProfileRepository,
         coachingRepo: MockCoachingProfileRepository, adaptedRepo: MockAdaptedProgramRepository,
         storeKitService: MockStoreKitService) {
        self.vm = vm
        self.aiService = aiService
        self.healthBuilder = healthBuilder
        self.coreRepo = coreRepo
        self.coachingRepo = coachingRepo
        self.adaptedRepo = adaptedRepo
        self.storeKitService = storeKitService
    }

    subscript<T>(dynamicMember keyPath: KeyPath<AdaptedProgramViewModel, T>) -> T {
        vm[keyPath: keyPath]
    }

    func triggerLeonIfNeeded() async { await vm.triggerLeonIfNeeded() }
    func requestLeonExplicit() async { await vm.requestLeonExplicit() }
}
