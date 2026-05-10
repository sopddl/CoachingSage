// App/CoachingSageApp.swift
// Point d'entrée @main — gère bootstrap SwiftData, AppDependencies, et bascule Auth ↔ Onboarding ↔ MainTabView.

import os
import SwiftUI
import SwiftData

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
                for: Schema(versionedSchema: SchemaV5.self),
                migrationPlan: CoachingSageMigrationPlan.self,
                configurations: config
            )
            self.container = container
            self.deps = AppDependencies.live(modelContext: container.mainContext)
        } catch {
            fatalError("Impossible d'initialiser le ModelContainer SwiftData : \(error)")
        }
        self.languageManager = LanguageManager()

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
                healthKitService: deps.healthKitService
            )
        }
        isLoadingOnboardingState = false
    }
}
