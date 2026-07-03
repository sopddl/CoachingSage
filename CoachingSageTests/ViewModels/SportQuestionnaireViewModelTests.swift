// CoachingSageTests/ViewModels/SportQuestionnaireViewModelTests.swift
// Story 3.1 (Phase 2 #5 update) — tests ViewModel critiques.
// Focus : cross-user race au submit (P0-4), idempotence double-tap (P1-8), recovery UserDefaults (P1-6).
// Phase 2 #5 : flow universel 3 questions (Q1 level → Q2 goal → Q3 frequency).
import Testing
import Foundation
import Supabase

@MainActor
@Suite("SportQuestionnaireViewModel")
struct SportQuestionnaireViewModelTests {

    /// Mock auth dont currentUserId peut changer entre 2 awaits — dédié au test cross-user race.
    final class MutableMockAuthService: AuthServiceProtocol, @unchecked Sendable {
        var stubbedUserId: UUID? = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        var currentUserId: UUID? { stubbedUserId }
        func signInWithApple(idToken: String, nonce: String) async throws -> Supabase.User { fatalError() }
        func signIn(email: String, password: String) async throws -> Supabase.User { fatalError() }
        func signUp(email: String, password: String) async throws -> Supabase.User { fatalError() }
        func signOut() async throws {}
        func resetPasswordForEmail(_ email: String) async throws {}
        func updatePassword(_ newPassword: String) async throws {}
        func handleSessionFromURL(_ url: URL) async throws {}
    }

    /// Gate à continuation : `wait()` suspend jusqu'à `release()`. Nécessaire au test
    /// double-tap — `NoTypingDelay.wait()` (async vide) ne garantit AUCUNE suspension,
    /// donc le 1er `answer()` peut se terminer d'une traite avant le 2e tap.
    private actor TypingGate: TypingDelayProvider {
        private var waiters: [CheckedContinuation<Void, Never>] = []
        private(set) var waiterCount = 0
        func wait() async {
            waiterCount += 1
            await withCheckedContinuation { waiters.append($0) }
        }
        func release() {
            waiters.forEach { $0.resume() }
            waiters.removeAll()
        }
    }

    private func makeViewModel(
        sportCode: String = "running",
        authService: MutableMockAuthService = MutableMockAuthService(),
        repo: MockCoachingSportProfileRepository = MockCoachingSportProfileRepository(),
        typingDelay: TypingDelayProvider = NoTypingDelay()
    ) -> (SportQuestionnaireViewModel, MutableMockAuthService, MockCoachingSportProfileRepository) {
        // Purge tout brouillon UserDefaults résiduel pour ce (user × sport) — sinon recovery prompt
        // s'enclenche et `startFreshFlow` n'est jamais appelé (tests pollués entre runs).
        if let uid = authService.stubbedUserId {
            UserDefaults.standard.removeObject(forKey: "pending_questionnaire_\(uid.uuidString.lowercased())_\(sportCode)")
        }
        let vm = SportQuestionnaireViewModel(
            questionnaire: UniversalQuestionnaire(sportCode: sportCode),
            repository: repo,
            authService: authService,
            typingDelay: typingDelay
        )
        return (vm, authService, repo)
    }

    // MARK: - Initial state

    @Test
    func initialState_isIdle() {
        let (vm, _, _) = makeViewModel()
        #expect(vm.messages.isEmpty)
        #expect(vm.currentQuestion == nil)
        if case .idle = vm.state {} else { Issue.record("Expected .idle initial state") }
    }

    // MARK: - Start

    @Test
    func start_appendsIntroAndFirstQuestion() {
        let (vm, _, _) = makeViewModel()
        vm.start(requiresMedicalClearance: false)
        #expect(vm.currentQuestion?.id == "q1_level")
        // 2 bulles Léon (intro + Q1) attendues
        let leonCount = vm.messages.filter { if case .leonText = $0 { return true } else { return false } }.count
        #expect(leonCount >= 2)
    }

    @Test("Bulle medical clearance affichée si flag true")
    func start_appendsMedicalClearanceBubbleIfFlag() {
        let (vm, _, _) = makeViewModel()
        vm.start(requiresMedicalClearance: true)
        // 3 bulles Léon : intro + medical + Q1
        let leonCount = vm.messages.filter { if case .leonText = $0 { return true } else { return false } }.count
        #expect(leonCount >= 3)
    }

    // MARK: - Cross-user race (review P0-4)

    @Test("submit() abort si currentUserId change entre start et submit")
    func submit_abortsIfUserChanged() async {
        let auth = MutableMockAuthService()
        let (vm, _, repo) = makeViewModel(authService: auth)
        vm.start(requiresMedicalClearance: false)
        // Compléter Q1 + Q2 (goal NON eligible deadline → flow termine à Q3, pas de Q4)
        // puis cross-user avant Q3 (qui déclenche submit).
        await vm.answer(.single("regular"))
        await vm.answer(.single("wellness"))   // running wellness = NOT deadline-eligible → submit après Q3
        auth.stubbedUserId = UUID()  // user différent
        await vm.answer(.single("3"))
        // Le repo NE DOIT PAS avoir saved (cross-user race aborte avant le save)
        #expect(repo.saveCallCount == 0)
        // State doit être .error
        if case .error = vm.state {} else {
            Issue.record("Expected .error after cross-user race, got \(vm.state)")
        }
    }

    // MARK: - Idempotence double-tap (review P1-8)

    @Test("Double-tap rapide sur même option ne saute pas de question")
    func answer_isIdempotentDoubleTap() async {
        let gate = TypingGate()
        let (vm, _, _) = makeViewModel(typingDelay: gate)
        vm.start(requiresMedicalClearance: false)
        // 1er tap : part et se suspend sur le typing delay (isAdvancing reste true).
        async let a1: () = vm.answer(.single("regular"))
        // La gate tient a1 en vol → waiterCount finit forcément par passer à 1.
        while await gate.waiterCount == 0 { await Task.yield() }
        // 2e tap PENDANT que le 1er est en vol → doit être ignoré par la garde isAdvancing.
        await vm.answer(.single("regular"))
        await gate.release()
        _ = await a1
        // Une seule question doit avoir été enregistrée pour q1_level
        #expect(vm.accumulatedAnswers.count == 1)
        #expect(vm.currentQuestion?.id == "q2_goal")
    }

    // MARK: - Happy path complet → save

    @Test("Flow complet (goal eligible) sauve le profil via le repo après Q4")
    func fullFlow_savesProfile() async {
        let auth = MutableMockAuthService()
        let (vm, _, repo) = makeViewModel(authService: auth)
        vm.start(requiresMedicalClearance: false)
        await vm.answer(.single("regular"))     // Q1 level
        await vm.answer(.single("10k"))         // Q2 goal (deadline-eligible)
        await vm.answer(.single("3"))           // Q3 frequency → goal eligible → poses Q4
        await vm.answer(.single(UniversalQuestionnaire.q4Routine3MonthsCode))  // Q4 routine → submit

        #expect(repo.saveCallCount == 1)
        #expect(repo.stored["running"] != nil)
        #expect(repo.stored["running"]?.level == "regular")
        #expect(repo.stored["running"]?.goals.primary == "10k")
        #expect(repo.stored["running"]?.frequencyPerWeek == 3)
        // Story sœur : Q4=routine_3_months → routineCyclic
        #expect(repo.stored["running"]?.durationMode == .routineCyclic)
        #expect(repo.stored["running"]?.targetDate == nil)
        // Phase 2 #5 : equipment + constraints sont vides côté SportProfile (équipement = onboarding global).
        #expect(repo.stored["running"]?.equipment == [])
        #expect(repo.stored["running"]?.constraints == [])
        if case .success(let profile) = vm.state {
            #expect(profile.sportCode == "running")
        } else {
            Issue.record("Expected .success after happy path")
        }
    }

    @Test("Flow universel sur sport non-running (cycling) avec Q4 let_me_estimate")
    func fullFlow_savesProfileForCycling() async {
        let auth = MutableMockAuthService()
        let (vm, _, repo) = makeViewModel(sportCode: "cycling", authService: auth)
        vm.start(requiresMedicalClearance: false)
        await vm.answer(.single("competitive"))
        await vm.answer(.single("cyclosportive"))    // deadline-eligible
        await vm.answer(.single("4_or_more"))         // Q3 → poses Q4
        await vm.answer(.single(UniversalQuestionnaire.q4LetMeEstimateCode))  // Q4 → poses Q5 (cycling)
        await vm.answer(.single("outdoor"))           // Q5 lieu (cycling only) → submit

        #expect(repo.saveCallCount == 1)
        #expect(repo.stored["cycling"]?.level == "competitive")
        #expect(repo.stored["cycling"]?.goals.primary == "cyclosportive")
        #expect(repo.stored["cycling"]?.frequencyPerWeek == 4)
        #expect(repo.stored["cycling"]?.frequencyLabel == "4_or_more")
        #expect(repo.stored["cycling"]?.questionnaireVersion == "universal_v1")
        #expect(repo.stored["cycling"]?.durationMode == .deadlineEstimated)
        // Indoor/outdoor vélo (2026-06-11) — Q5 lieu capturée dans l'historique →
        // consommée au commit pour poser environmentDefaultRaw.
        #expect(UniversalQuestionnaire.environmentDefault(from: repo.stored["cycling"]?.conversationHistory ?? []) == "outdoor")
    }

    // MARK: - Recovery UserDefaults (review P1-6)

    @Test("Save échoue → state .error, pending draft conservé")
    func saveFailure_keepsPendingDraft() async {
        let auth = MutableMockAuthService()
        let repo = MockCoachingSportProfileRepository()
        struct FakeError: Error {}
        repo.saveError = FakeError()
        let (vm, _, _) = makeViewModel(authService: auth, repo: repo)

        vm.start(requiresMedicalClearance: false)
        await vm.answer(.single("regular"))
        await vm.answer(.single("wellness"))    // running wellness = NOT deadline-eligible → submit après Q3
        await vm.answer(.single("3"))

        if case .error = vm.state {} else {
            Issue.record("Expected .error after save failure")
        }
        // Pending draft doit toujours être présent dans UserDefaults
        let key = "pending_questionnaire_00000000-0000-0000-0000-000000000001_running"
        #expect(UserDefaults.standard.data(forKey: key) != nil)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Autoprofil HealthKit (Story Autoprofil)

    @Test("startWithAutoProfile pré-remplit q1+q3 et démarre à Q2")
    func startWithAutoProfile_prefillsAndAdvances() {
        let (vm, _, _) = makeViewModel()
        vm.startWithAutoProfile(level: .regular, frequency: .three, requiresMedicalClearance: false)

        #expect(vm.currentQuestion?.id == "q2_goal")
        #expect(vm.accumulatedAnswers["q1_level"] == .single("regular"))
        #expect(vm.accumulatedAnswers["q3_frequency"] == .single("3"))
        // 2 entrées historique flaggées autoFilled
        let autoFilled = vm.conversationHistory.filter { $0.autoFilled == true }
        #expect(autoFilled.count == 2)
        let ids = Set(autoFilled.map { $0.questionId })
        #expect(ids == ["q1_level", "q3_frequency"])
    }

    @Test("startWithAutoProfile + Q2 (goal eligible) → pose Q4 puis save")
    func startWithAutoProfile_fullFlowSaves() async {
        let auth = MutableMockAuthService()
        let (vm, _, repo) = makeViewModel(authService: auth)
        vm.startWithAutoProfile(level: .competitive, frequency: .fourOrMore, requiresMedicalClearance: false)
        await vm.answer(.single("10k"))   // Q2 (eligible) — Q3 déjà pré-remplie, propose Q4
        await vm.answer(.single(UniversalQuestionnaire.q4Routine3MonthsCode))  // Q4 → submit

        #expect(repo.saveCallCount == 1)
        #expect(repo.stored["running"]?.level == "competitive")
        #expect(repo.stored["running"]?.frequencyLabel == "4_or_more")
        #expect(repo.stored["running"]?.frequencyPerWeek == 4)
        #expect(repo.stored["running"]?.durationMode == .routineCyclic)
    }

    // MARK: - Story 3.30 — Remonter le fil (édition directe)

    /// Helper : déroule un flow running complet eligible (Q1..Q4) → submit (saveCallCount == 1).
    private func runFullRunningFlow(_ vm: SportQuestionnaireViewModel, q4: String) async {
        vm.start(requiresMedicalClearance: false)
        await vm.answer(.single("regular"))   // Q1
        await vm.answer(.single("10k"))       // Q2 (eligible)
        await vm.answer(.single("3"))         // Q3 → pose Q4
        await vm.answer(.single(q4))          // Q4 → submit
    }

    @Test("Éditer Q1 (niveau) conserve les réponses aval Q2/Q3/Q4 puis re-soumet")
    func editUpstream_keepsValidDownstream() async {
        let (vm, _, repo) = makeViewModel()
        await runFullRunningFlow(vm, q4: UniversalQuestionnaire.q4Routine3MonthsCode)
        #expect(repo.saveCallCount == 1)

        // Remonter le fil sur Q1 et changer le niveau.
        vm.beginEditing(questionId: "q1_level")
        #expect(vm.currentQuestion?.id == "q1_level")
        await vm.answer(.single("beginner"))

        // Re-soumis avec les réponses aval intactes.
        #expect(repo.saveCallCount == 2)
        #expect(repo.stored["running"]?.level == "beginner")
        #expect(repo.stored["running"]?.goals.primary == "10k")
        #expect(repo.stored["running"]?.frequencyPerWeek == 3)
        #expect(repo.stored["running"]?.durationMode == .routineCyclic)
    }

    @Test("Éditer Q3 → dont_know sort Q4 du parcours (durationMode routineCyclic, date ignorée)")
    func editFrequencyToDontKnow_dropsDurationDownstream() async {
        let (vm, _, repo) = makeViewModel()
        await runFullRunningFlow(vm, q4: UniversalQuestionnaire.q4LetMeEstimateCode)
        #expect(repo.stored["running"]?.durationMode == .deadlineEstimated)

        vm.beginEditing(questionId: "q3_frequency")
        #expect(vm.currentQuestion?.id == "q3_frequency")
        await vm.answer(.single(UniversalQuestionnaire.q3DontKnowCode))

        // Q4 (dormant) ignoré : Q3=dont_know prime → routineCyclic.
        #expect(repo.saveCallCount == 2)
        #expect(repo.stored["running"]?.durationMode == .routineCyclic)
        #expect(repo.stored["running"]?.targetDate == nil)
    }

    @Test("Éditer Q2 goal eligible→non-eligible retire Q4 du parcours")
    func editGoalToNonEligible_removesQ4() async {
        let (vm, _, repo) = makeViewModel()
        await runFullRunningFlow(vm, q4: UniversalQuestionnaire.q4Routine3MonthsCode)

        vm.beginEditing(questionId: "q2_goal")
        await vm.answer(.single("wellness"))   // non-eligible → fin après Q3

        #expect(repo.saveCallCount == 2)
        #expect(repo.stored["running"]?.goals.primary == "wellness")
        #expect(repo.stored["running"]?.durationMode == .routineCyclic)
    }

    @Test("Éditer Q2 goal non-eligible→eligible ré-pose Q4 sans soumettre prématurément")
    func editGoalToEligible_reopensQ4() async {
        let (vm, _, repo) = makeViewModel()
        vm.start(requiresMedicalClearance: false)
        await vm.answer(.single("regular"))    // Q1
        await vm.answer(.single("wellness"))   // Q2 non-eligible
        await vm.answer(.single("3"))          // Q3 → fin (pas de Q4) → submit
        #expect(repo.saveCallCount == 1)

        vm.beginEditing(questionId: "q2_goal")
        await vm.answer(.single("10k"))        // eligible → Q4 ré-ouvert

        // Q4 jamais répondu → on s'arrête dessus, PAS de re-submit.
        #expect(vm.currentQuestion?.id == "q4_duration")
        #expect(repo.saveCallCount == 1)

        // Compléter Q4 → submit normal.
        await vm.answer(.single(UniversalQuestionnaire.q4Routine3MonthsCode))
        #expect(repo.saveCallCount == 2)
        #expect(repo.stored["running"]?.goals.primary == "10k")
    }

    @Test("beginEditing no-op si id inconnu ou réponse absente")
    func beginEditing_noOpGuards() async {
        let (vm, _, _) = makeViewModel()
        vm.start(requiresMedicalClearance: false)
        await vm.answer(.single("regular"))    // currentQuestion = q2_goal

        // id inconnu
        vm.beginEditing(questionId: "q99_unknown")
        #expect(vm.currentQuestion?.id == "q2_goal")
        #expect(vm.isEditingInPlace == false)

        // question valide mais pas encore répondue (q3)
        vm.beginEditing(questionId: "q3_frequency")
        #expect(vm.currentQuestion?.id == "q2_goal")
        #expect(vm.isEditingInPlace == false)
    }

    @Test("Éditer une réponse pré-remplie autoprofil conserve l'autre pré-fill")
    func editAutoprofilePrefill_preservesOtherPrefill() async {
        let (vm, _, _) = makeViewModel()
        vm.startWithAutoProfile(level: .regular, frequency: .three, requiresMedicalClearance: false)
        #expect(vm.currentQuestion?.id == "q2_goal")

        // Éditer Q1 (pré-rempli) — questionHistory vide après autoprofil, doit quand même marcher.
        vm.beginEditing(questionId: "q1_level")
        #expect(vm.currentQuestion?.id == "q1_level")
        await vm.answer(.single("beginner"))

        // On retombe sur Q2 (jamais répondu), Q1 modifié, Q3 pré-fill préservé.
        #expect(vm.currentQuestion?.id == "q2_goal")
        #expect(vm.accumulatedAnswers["q1_level"] == .single("beginner"))
        #expect(vm.accumulatedAnswers["q3_frequency"] == .single("3"))
    }

    @Test("conversationHistory cohérente après édition d'une question médiane")
    func edit_rebuildsConsistentConversationHistory() async {
        let (vm, _, _) = makeViewModel()
        await runFullRunningFlow(vm, q4: UniversalQuestionnaire.q4Routine3MonthsCode)

        // Éditer Q3 : le fil rejoué doit contenir Q1+Q2 (2 entrées), s'arrêter sur Q3.
        vm.beginEditing(questionId: "q3_frequency")
        #expect(vm.currentQuestion?.id == "q3_frequency")
        #expect(vm.conversationHistory.count == 2)
        #expect(vm.questionHistory.map(\.id) == ["q1_level", "q2_goal"])
        // Réponses aval (Q3 ancienne + Q4) restent dormantes, réutilisables.
        #expect(vm.accumulatedAnswers["q4_duration"] != nil)
    }
}
