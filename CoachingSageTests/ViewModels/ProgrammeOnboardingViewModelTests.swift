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

    /// Service d'intention contrôlé (renvoie une réponse fixée).
    private struct FakeIntentService: LeonIntentService {
        let response: LeonIntentResponse
        func interpret(_ request: LeonIntentRequest) async throws -> LeonIntentResponse { response }
    }

    private func makeVM(
        activeSports: [SportCode] = [.running, .cycling, .yoga],
        autoprofileLevel: String? = nil,
        requiresMedicalClearance: Bool = false,
        weekCount: Int = 12,
        generateThrows: Bool = false,
        intentService: LeonIntentService = StubLeonIntentService(),
        logger: SpyLogger = SpyLogger(),
        onGenerate: (() -> Void)? = nil
    ) -> ProgrammeOnboardingViewModel {
        ProgrammeOnboardingViewModel(
            userId: UUID(),
            activeSports: activeSports,
            requiresMedicalClearance: requiresMedicalClearance,
            autoprofileLevel: autoprofileLevel,
            generatePreview: { _ in
                onGenerate?()
                if generateThrows { throw NSError(domain: "test", code: 1) }
                return weekCount
            },
            intentService: intentService,
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

        // La bulle user est synchrone ; la restitution + le log suivent l'interprétation async.
        XCTAssertEqual(vm.conversation.first?.sender, .user)
        XCTAssertEqual(vm.conversation.first?.text, "plutôt le soir")

        wait(for: [exp], timeout: 1.0)
        // Stub (phase 1) : pas d'interprétation → ⏳ holding + category unknown, response not_yet.
        XCTAssertEqual(vm.conversation.count, 2)
        XCTAssertEqual(vm.conversation[1].sender, .leon)
        XCTAssertEqual(vm.conversation[1].text, ProgrammeOnboardingViewModel.holdingReplyKey)
        XCTAssertEqual(logger.logged.count, 1)
        XCTAssertEqual(logger.logged.first?.category, .unknown)
        XCTAssertEqual(logger.logged.first?.response, .notYet)
        XCTAssertEqual(logger.logged.first?.locale, "fr_FR")
    }

    func test_sendFollowUp_supportedIntent_appliesSlotsAndRecomposes() {
        let intent = LeonIntent(
            route: .supported,
            restitution: "✓ Vélo 4×",
            category: nil,
            refusalFamily: nil,
            slots: LeonIntentSlots(sportCodes: ["cycling"], frequencyPerWeek: 4)
        )
        let service = FakeIntentService(response: LeonIntentResponse(intents: [intent]))
        // L'application des slots déclenche regenerate → generatePreview : on s'en sert de signal.
        let exp = expectation(description: "recomposed")
        let vm = makeVM(intentService: service, onGenerate: { exp.fulfill() })

        vm.sendFollowUp("vélo 4 fois par semaine")

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(vm.selectedSport, .cycling)
        XCTAssertEqual(vm.frequencyPerWeek, 4)
        XCTAssertEqual(vm.proposal?.frequencyPerWeek, 4)
        XCTAssertEqual(vm.conversation.last?.text, "✓ Vélo 4×")
    }

    func test_submitDemande_interpretsAndClearsField_keepsNote() {
        let intent = LeonIntent(
            route: .supported,
            restitution: "✓ Yoga",
            category: nil,
            refusalFamily: nil,
            slots: LeonIntentSlots(sportCodes: ["yoga"], frequencyPerWeek: 3)
        )
        let service = FakeIntentService(response: LeonIntentResponse(intents: [intent]))
        let exp = expectation(description: "recomposed")
        let vm = makeVM(intentService: service, onGenerate: { exp.fulfill() })

        vm.demandeText = "yoga le matin"
        vm.submitDemande()
        XCTAssertEqual(vm.demandeText, "") // champ vidé à la soumission

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(vm.selectedSport, .yoga)
        XCTAssertEqual(vm.conversation.first?.text, "yoga le matin") // demande = 1er msg du fil
        XCTAssertEqual(vm.finalizedSportProfile()?.freeTextNotes, "yoga le matin") // note conservée
    }

    // MARK: - Contrat Swift ⇄ Deno (filet : la forme JSON du backend doit décoder)

    func test_leonIntentResponse_decodesBackendContract() throws {
        let json = """
        {"intents":[
          {"route":"supported","restitution":"✓ Course, c'est parti.","category":null,"refusalFamily":null,"slots":{"sportCodes":["running"],"frequencyPerWeek":3}},
          {"route":"not_yet","restitution":"⏳ je note l'idée","category":"multi_sport_combine","refusalFamily":null,"slots":null},
          {"route":"refused_safety","restitution":"🚫 vois ça avec un pro de santé","category":"health_condition","refusalFamily":"health_condition","slots":null}
        ]}
        """.data(using: .utf8)!
        let resp = try JSONDecoder().decode(LeonIntentResponse.self, from: json)
        XCTAssertEqual(resp.intents.count, 3)
        XCTAssertEqual(resp.intents[0].route, .supported)
        XCTAssertEqual(resp.intents[0].slots?.sportCodes, ["running"])
        XCTAssertEqual(resp.intents[0].slots?.frequencyPerWeek, 3)
        XCTAssertEqual(resp.intents[1].route, .notYet)
        XCTAssertEqual(resp.intents[1].category, .multiSportCombine)
        XCTAssertNil(resp.intents[1].slots ?? nil)
        XCTAssertEqual(resp.intents[2].route, .refusedSafety)
        XCTAssertEqual(resp.intents[2].refusalFamily, .healthCondition)
        XCTAssertEqual(resp.intents[2].category, .healthCondition)
    }

    func test_sendFollowUp_refusalSafety_logsRefusedWithFamily() {
        let intent = LeonIntent(
            route: .refusedSafety,
            restitution: "🚫 vois ça avec un pro de santé",
            category: .healthCondition,
            refusalFamily: .healthCondition,
            slots: nil
        )
        let service = FakeIntentService(response: LeonIntentResponse(intents: [intent]))
        let logger = SpyLogger()
        let exp = expectation(description: "logged")
        logger.expectation = exp
        let vm = makeVM(intentService: service, logger: logger)

        vm.sendFollowUp("j'ai mal au dos")

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(logger.logged.first?.category, .healthCondition)
        XCTAssertEqual(logger.logged.first?.response, .refusedSafety)
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
