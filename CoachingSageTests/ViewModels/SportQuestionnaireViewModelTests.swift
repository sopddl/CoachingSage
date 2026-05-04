// CoachingSageTests/ViewModels/SportQuestionnaireViewModelTests.swift
// Story 3.1 — tests ViewModel critiques (review pré-implem 2026-04-29).
// Focus : cross-user race au submit (P0-4), idempotence double-tap (P1-8), recovery UserDefaults (P1-6).
import Testing
import Foundation
import Supabase
@testable import CoachingSage

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

    private func makeViewModel(
        authService: MutableMockAuthService = MutableMockAuthService(),
        repo: MockCoachingSportProfileRepository = MockCoachingSportProfileRepository()
    ) -> (SportQuestionnaireViewModel, MutableMockAuthService, MockCoachingSportProfileRepository) {
        // Purge tout brouillon UserDefaults résiduel pour ce (user × running) — sinon recovery prompt
        // s'enclenche et `startFreshFlow` n'est jamais appelé (tests pollués entre runs).
        if let uid = authService.stubbedUserId {
            UserDefaults.standard.removeObject(forKey: "pending_questionnaire_\(uid.uuidString.lowercased())_running")
        }
        let vm = SportQuestionnaireViewModel(
            questionnaire: RunningQuestionnaire(),
            repository: repo,
            authService: authService,
            typingDelay: NoTypingDelay()
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
        // Compléter rapidement les 6 questions
        await vm.answer(.single("regular"))
        await vm.answer(.single("5k"))
        await vm.answer(.single("3"))
        await vm.answer(.multi(["none"]))
        await vm.answer(.multi(["none"]))
        // Cross-user : changer le userId AVANT le dernier answer (qui déclenche submit)
        auth.stubbedUserId = UUID()  // user différent
        await vm.answer(.text(nil))
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
        let (vm, _, _) = makeViewModel()
        vm.start(requiresMedicalClearance: false)
        // Lancer 2 answers en parallèle (ce que fait un double-tap rapide)
        async let a1: () = vm.answer(.single("regular"))
        async let a2: () = vm.answer(.single("regular"))
        _ = await (a1, a2)
        // Une seule question doit avoir été enregistrée pour q1_level
        #expect(vm.accumulatedAnswers.count == 1)
        #expect(vm.currentQuestion?.id == "q2_goal")
    }

    // MARK: - Happy path complet → save

    @Test("Flow complet sauve le profil via le repo")
    func fullFlow_savesProfile() async {
        let auth = MutableMockAuthService()
        let (vm, _, repo) = makeViewModel(authService: auth)
        vm.start(requiresMedicalClearance: false)
        await vm.answer(.single("regular"))
        await vm.answer(.single("10k"))
        await vm.answer(.single("3"))
        await vm.answer(.multi(["knee"]))
        await vm.answer(.multi(["gps_watch"]))
        vm.freeTextDraft = "Test note"
        await vm.answer(.text("Test note"))

        #expect(repo.saveCallCount == 1)
        #expect(repo.stored["running"] != nil)
        #expect(repo.stored["running"]?.level == "regular")
        #expect(repo.stored["running"]?.goals.primary == "10k")
        #expect(repo.stored["running"]?.constraints == ["knee"])
        if case .success(let profile) = vm.state {
            #expect(profile.sportCode == "running")
        } else {
            Issue.record("Expected .success after happy path")
        }
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
        await vm.answer(.single("5k"))
        await vm.answer(.single("3"))
        await vm.answer(.multi(["none"]))
        await vm.answer(.multi(["none"]))
        await vm.answer(.text(nil))

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

    @Test("startWithAutoProfile + suite Q2..Q6 → save profil cohérent")
    func startWithAutoProfile_fullFlowSaves() async {
        let auth = MutableMockAuthService()
        let (vm, _, repo) = makeViewModel(authService: auth)
        vm.startWithAutoProfile(level: .competitive, frequency: .fourOrMore, requiresMedicalClearance: false)
        await vm.answer(.single("10k"))           // Q2
        // Q3 déjà pré-remplie → on saute à Q4
        await vm.answer(.multi(["knee"]))         // Q4
        await vm.answer(.multi(["gps_watch"]))    // Q5
        await vm.answer(.text(nil))               // Q6

        #expect(repo.saveCallCount == 1)
        #expect(repo.stored["running"]?.level == "competitive")
        #expect(repo.stored["running"]?.frequencyLabel == "4_or_more")
        #expect(repo.stored["running"]?.frequencyPerWeek == 4)
    }
}
