// CoachingSageTests/ViewModels/ProgrammeOnboardingViewModelTests.swift
// Onboarding programme « fil de Léon » (inc1) — logique pure du VM :
// sélection sport → aperçu, rythme éditable (aperçu vivant), profil finalisé,
// relances captées + loggées (pas interprétées), échec génération.
import XCTest
import SwiftData

@MainActor
final class ProgrammeOnboardingViewModelTests: XCTestCase {

    /// `CoachingSportProfile` est un `@Model` : l'instancier hors d'un container actif
    /// crashe. On en crée un en mémoire et on le RETIENT (cf OnboardingViewModelTests).
    private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: CoachingSportProfile.self, configurations: config)
        _ = container.mainContext
    }

    override func tearDown() { container = nil }

    // MARK: - Spy logger

    private final class SpyLogger: LeonUnmetRequestLogger {
        var logged: [LeonUnmetRequest] = []
        var expectation: XCTestExpectation?
        func log(_ request: LeonUnmetRequest) async {
            logged.append(request)
            expectation?.fulfill()
        }
    }

    // MARK: - Helpers

    private func makeVM(
        activeSports: [SportCode] = [.running, .cycling, .yoga],
        autoprofileLevel: String? = nil,
        requiresMedicalClearance: Bool = false,
        weekCount: Int = 12,
        generateThrows: Bool = false,
        logger: SpyLogger = SpyLogger()
    ) -> ProgrammeOnboardingViewModel {
        ProgrammeOnboardingViewModel(
            userId: UUID(),
            activeSports: activeSports,
            requiresMedicalClearance: requiresMedicalClearance,
            autoprofileLevel: autoprofileLevel,
            generatePreview: { _ in
                if generateThrows { throw NSError(domain: "test", code: 1) }
                return weekCount
            },
            unmetLogger: logger,
            appVersion: "9.9",
            localeIdentifier: "fr_FR"
        )
    }

    // MARK: - État initial

    func test_initialState_noProposal_cannotCreate() {
        let vm = makeVM()
        XCTAssertNil(vm.proposal)
        XCTAssertFalse(vm.canCreate)
        XCTAssertNil(vm.finalizedSportProfile())
    }

    // MARK: - Sélection sport → aperçu

    func test_selectSport_generatesProposal() async {
        let vm = makeVM(weekCount: 8)
        vm.selectSport(.running)
        await vm.regenerate()
        XCTAssertEqual(vm.proposal?.sport, .running)
        XCTAssertEqual(vm.proposal?.weekCount, 8)
        XCTAssertEqual(vm.proposal?.frequencyPerWeek, 3) // défaut sain
        XCTAssertTrue(vm.canCreate)
        XCTAssertFalse(vm.generationFailed)
    }

    // MARK: - Rythme éditable (aperçu vivant)

    func test_setFrequency_recomposesProposal() async {
        let vm = makeVM()
        vm.selectSport(.cycling)
        await vm.regenerate()
        vm.setFrequency(4)
        await vm.regenerate()
        XCTAssertEqual(vm.proposal?.frequencyPerWeek, 4)
    }

    // MARK: - Profil finalisé (rendu à SessionView.onCompleted)

    func test_finalizedSportProfile_buildsExpectedProfile() {
        let vm = makeVM()
        vm.selectSport(.yoga)
        vm.demandeText = "  le matin si possible  "
        let profile = vm.finalizedSportProfile()
        XCTAssertEqual(profile?.sportCode, SportCode.yoga.rawValue)
        XCTAssertEqual(profile?.frequencyPerWeek, 3)
        XCTAssertEqual(profile?.frequencyLabel, "3")
        XCTAssertEqual(profile?.durationMode, .routineCyclic)
        XCTAssertEqual(profile?.level, "recreational") // autoprofileLevel nil → défaut
        XCTAssertEqual(profile?.questionnaireVersion, "fil_v1")
        XCTAssertEqual(profile?.freeTextNotes, "le matin si possible") // trim
    }

    func test_finalizedSportProfile_usesAutoprofileLevel() {
        let vm = makeVM(autoprofileLevel: "regular")
        vm.selectSport(.running)
        XCTAssertEqual(vm.finalizedSportProfile()?.level, "regular")
    }

    func test_finalizedSportProfile_freeTextTruncatedTo200() {
        let vm = makeVM()
        vm.selectSport(.running)
        vm.demandeText = String(repeating: "a", count: 250)
        XCTAssertEqual(vm.finalizedSportProfile()?.freeTextNotes?.count, 200)
    }

    func test_finalizedSportProfile_frequency4MapsToLabel() {
        let vm = makeVM()
        vm.selectSport(.running)
        vm.setFrequency(4)
        XCTAssertEqual(vm.finalizedSportProfile()?.frequencyLabel, "4_or_more")
    }

    func test_emptyDemande_givesNilFreeTextNotes() {
        let vm = makeVM()
        vm.selectSport(.running)
        vm.demandeText = "   \n  "
        XCTAssertNil(vm.finalizedSportProfile()?.freeTextNotes)
    }

    // MARK: - Conversation (relances : captées + loggées, PAS interprétées en inc1)

    func test_sendFollowUp_appendsUserAndHoldingReply_andLogs() {
        let logger = SpyLogger()
        let exp = expectation(description: "logged")
        logger.expectation = exp
        let vm = makeVM(logger: logger)
        vm.selectSport(.running)

        vm.sendFollowUp("plutôt le soir")

        XCTAssertEqual(vm.conversation.count, 2)
        XCTAssertEqual(vm.conversation[0].sender, .user)
        XCTAssertEqual(vm.conversation[0].text, "plutôt le soir")
        XCTAssertEqual(vm.conversation[1].sender, .leon)
        XCTAssertEqual(vm.conversation[1].text, ProgrammeOnboardingViewModel.holdingReplyKey)

        wait(for: [exp], timeout: 1.0)
        // Inc1 : pas d'interprétation → category unknown, response not_yet, aucun verbatim.
        XCTAssertEqual(logger.logged.count, 1)
        XCTAssertEqual(logger.logged.first?.category, .unknown)
        XCTAssertEqual(logger.logged.first?.response, .notYet)
        XCTAssertEqual(logger.logged.first?.locale, "fr_FR")
    }

    func test_sendFollowUp_emptyIgnored() {
        let vm = makeVM()
        vm.sendFollowUp("   ")
        XCTAssertTrue(vm.conversation.isEmpty)
    }

    // MARK: - Échec génération

    func test_generationFailure_setsFlag_noProposal() async {
        let vm = makeVM(generateThrows: true)
        vm.selectSport(.running)
        await vm.regenerate()
        XCTAssertNil(vm.proposal)
        XCTAssertTrue(vm.generationFailed)
        XCTAssertFalse(vm.canCreate)
    }
}
