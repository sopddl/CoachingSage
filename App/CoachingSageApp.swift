// App/CoachingSageApp.swift
// Point d'entrée @main — gère bootstrap SwiftData, AppDependencies, et bascule Auth ↔ Onboarding ↔ MainTabView.

import os
import SwiftUI
import SwiftData
import SageCore
import UserNotifications

@main
struct CoachingSageApp: App {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "app")
    private let launchStart: Date
    private let container: ModelContainer
    private let deps: AppDependencies
    private let languageManager: LanguageManager
    @State private var isAuthenticated: Bool
    @State private var isLoadingOnboardingState: Bool
    @State private var hasCompletedOnboarding: Bool
    @State private var onboardingViewModel: OnboardingViewModel?
    @State private var coldStartLogged = false

    init() {
        // Capturé dès la 1re ligne de init() pour que NFR7 mesure du @main au 1er rendu.
        // (static let est lazy → donnerait ~0ms.)
        self.launchStart = Date()
        let env = ProcessInfo.processInfo.environment
        let isUITesting = env["IS_UI_TESTING"] != nil || env["XCTestConfigurationFilePath"] != nil

        let config: ModelConfiguration
        if isUITesting {
            config = ModelConfiguration(isStoredInMemoryOnly: true)
        } else {
            config = ModelConfiguration(url: AppConstants.sharedStoreURL)
        }

        do {
            let container = try ModelContainer(
                for: Schema(versionedSchema: SchemaV11.self),
                migrationPlan: CoachingSageMigrationPlan.self,
                configurations: config
            )
            self.container = container
            self.deps = AppDependencies.live(modelContext: container.mainContext)
        } catch {
            fatalError("Impossible d'initialiser le ModelContainer SwiftData : \(error)")
        }
        let lm = LanguageManager()
        self.languageManager = lm

        // **Story 3.11 UI review** — `UI_TEST_LANG=fr|en` permet à l'agent ui-reviewer
        // de forcer la langue au launch (sans devoir passer par le selecteur in-app
        // ni les leviers OS qui sont mal interceptés en mode `UI_TEST_SCENARIO`).
        if let testLang = env["UI_TEST_LANG"], let lang = AppLanguage(rawValue: testLang) {
            lm.switchLanguage(to: lang)
        }

        // Epic 8 — le contenu des notifications suit la langue in-app (bon bundle).
        deps.notificationService.localeProvider = { lm.currentLocale }
        // Epic 8 — présenter les notifs même app au premier plan (sinon iOS les supprime).
        UNUserNotificationCenter.current().delegate = NotificationForegroundPresenter.shared

        if isUITesting {
            // Mode UI testing : pré-authentifié + onboarding bypass (cohérent flow existant).
            let testUserId = UUID()
            _isAuthenticated = State(initialValue: true)
            _isLoadingOnboardingState = State(initialValue: false)
            _hasCompletedOnboarding = State(initialValue: true)
            let core = SageCoreProfile(id: testUserId)
            core.language = "fr"
            core.region = "FR"
            container.mainContext.insert(core)
            try? container.mainContext.save()
        } else {
            let isAuthed = SupabaseService.shared.client.auth.currentSession != nil
            _isAuthenticated = State(initialValue: isAuthed)
            // Si on a une session active, on doit hydrater l'onboarding state avant d'afficher quoi que ce soit.
            // Évite le flash onboarding parasite sur un user qui en a déjà fait un (review P0-2).
            _isLoadingOnboardingState = State(initialValue: isAuthed)
            _hasCompletedOnboarding = State(initialValue: false)
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                // Le container de scénarios UI review n'existe qu'en DEBUG
                // (`UIReviewScenarioContainer` est sous `#if DEBUG`). En Release
                // (archive TestFlight/App Store) il n'y a jamais de scénario → on
                // rend directement le contenu prod. Sans cette garde, l'archive
                // Release ne compilait pas (symbole introuvable).
                #if DEBUG
                if let scenario = Self.resolveUITestScenario() {
                    UIReviewScenarioContainer(scenario: scenario)
                } else {
                    rootContent
                }
                #else
                rootContent
                #endif
            }
            .environment(\.appDependencies, deps)
            .environment(\.languageManager, languageManager)
            .environment(\.locale, languageManager.currentLocale)
            .debugGridOverlay()
            .onAppear {
                // NFR7 cold start : mesuré du `init()` de l'@main jusqu'au 1er rendu.
                // Cible < 3s (NFR7). Log une seule fois par lancement.
                guard !coldStartLogged else { return }
                coldStartLogged = true
                let elapsed = Date().timeIntervalSince(launchStart)
                Self.logger.info("cold_start_ms=\(Int(elapsed * 1000))")
            }
            .task {
                // Story 1.3 — démarre le monitor réseau + drain à reconnexion.
                // Placé dans .task (pas dans init) pour ne pas peser sur le cold start NFR7.
                deps.syncService.start()
            }
            .task(id: isAuthenticated) {
                await refreshOnboardingState()
            }
            .task(id: isAuthenticated) {
                // Epic 8 — (re)planifie les notifications locales d'engagement au
                // lancement (best-effort, idempotent ; no-op si non autorisé/désactivé).
                guard isAuthenticated else { return }
                await deps.notificationService.reschedule()
            }
            .task {
                // En UI testing OU unit tests Cmd+U, ne pas écouter authStateChanges
                // (placeholder client → .signedOut parasite qui bascule vers AuthView
                // alors que `init()` a posé `isAuthenticated = true`).
                let env = ProcessInfo.processInfo.environment
                guard env["IS_UI_TESTING"] == nil, env["XCTestConfigurationFilePath"] == nil else { return }
                for await stateChange in SupabaseService.shared.client.auth.authStateChanges {
                    switch stateChange.event {
                    case .signedIn, .initialSession:
                        if stateChange.session != nil {
                            // Set isLoading AVANT de basculer isAuthenticated pour éviter
                            // un flash MainTabView entre le set isAuthenticated et l'exécution de .task(id:).
                            isLoadingOnboardingState = true
                            isAuthenticated = true
                        } else {
                            isAuthenticated = false
                        }
                    case .signedOut, .userDeleted:
                        isAuthenticated = false
                    default:
                        break
                    }
                }
            }
        }
        .modelContainer(container)
    }

    /// Contenu racine « production » (hors scénario UI review DEBUG) : auth →
    /// hydratation onboarding → onboarding → app. Extrait pour pouvoir compiler
    /// la branche scénario sous `#if DEBUG` sans dupliquer cette chaîne.
    @ViewBuilder
    private var rootContent: some View {
        if !isAuthenticated {
            AuthView(
                authService: deps.authService,
                coreProfileRepository: deps.coreProfileRepository
            )
        } else if isLoadingOnboardingState {
            ZStack {
                Color.coachingBackground.ignoresSafeArea()
                ProgressView()
                    .controlSize(.large)
                    .tint(Color.coachingPrimary)
            }
            .accessibilityIdentifier("onboarding.loading.splash")
        } else if !hasCompletedOnboarding, let vm = onboardingViewModel {
            OnboardingView(viewModel: vm, onCompleted: {
                hasCompletedOnboarding = true
                onboardingViewModel = nil
            })
        } else {
            MainTabView()
        }
    }

    /// Résout le scenario `ui_review_*` au launch en lisant 3 sources successives :
    ///   1. env var `UI_TEST_SCENARIO` (préférée, set via `SIMCTL_CHILD_UI_TEST_SCENARIO` ou `xcrun simctl launch --env`)
    ///   2. launch arg flag `-UI_TEST_SCENARIO <value>` (`xcrun simctl launch ... -UI_TEST_SCENARIO ...`)
    ///   3. launch arg prefix `ui_review_*` (passé directement comme argv)
    ///
    /// Le fallback launch args est nécessaire pour les agents (sandbox Bash + MCP `app_launch`)
    /// qui ne peuvent pas injecter d'env var sur `xcrun simctl`. Cf finding ui-reviewer
    /// 2026-05-19 + mémoire `epic3_ui_review_pattern_ported_cs`. À propager TS/GS.
    #if DEBUG
    private static func resolveUITestScenario() -> String? {
        if let envScenario = ProcessInfo.processInfo.environment["UI_TEST_SCENARIO"],
           !envScenario.isEmpty {
            return envScenario
        }
        let args = ProcessInfo.processInfo.arguments
        if let flagIndex = args.firstIndex(of: "-UI_TEST_SCENARIO"),
           flagIndex + 1 < args.count {
            let value = args[flagIndex + 1]
            if !value.isEmpty { return value }
        }
        if let prefixed = args.first(where: { $0.hasPrefix("ui_review_") }) {
            return prefixed
        }
        return nil
    }
    #endif

    @MainActor
    private func refreshOnboardingState() async {
        // Pas authentifié → reset complet, pas de fetch.
        guard isAuthenticated else {
            isLoadingOnboardingState = false
            hasCompletedOnboarding = false
            onboardingViewModel = nil
            return
        }

        // En UI testing OU unit tests Cmd+U, l'init a déjà tout posé.
        let env = ProcessInfo.processInfo.environment
        guard env["IS_UI_TESTING"] == nil, env["XCTestConfigurationFilePath"] == nil else { return }

        isLoadingOnboardingState = true
        Self.logger.debug("refreshOnboardingState: starting fetchCurrentProfile")

        // Race avec timeout 4s : si Supabase hang, on bascule sur onboarding sans bloquer l'UI.
        let profile: CoachingProfile? = await withTaskGroup(of: CoachingProfile?.self) { group in
            group.addTask { [coachingRepo = deps.coachingProfileRepository] in
                try? await coachingRepo.fetchCurrentProfile()
            }
            group.addTask {
                try? await Task.sleep(for: .seconds(4))
                return nil
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first
        }

        let completed = profile?.onboardingCompletedAt != nil
        Self.logger.debug("refreshOnboardingState: completed=\(completed) profile=\(profile == nil ? "nil" : "found")")
        hasCompletedOnboarding = completed
        if !completed && onboardingViewModel == nil {
            onboardingViewModel = OnboardingViewModel(
                coreProfileRepository: deps.coreProfileRepository,
                coachingProfileRepository: deps.coachingProfileRepository,
                healthKitService: deps.healthKitService,
                dormantBootstrapService: deps.dormantBootstrapService
            )
        }
        isLoadingOnboardingState = false
    }
}
