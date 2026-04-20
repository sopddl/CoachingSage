// App/CoachingSageApp.swift
// Story 1.1a bootstrap — point d'entrée @main.
// Story 1.2 remplace le placeholder authentifié par la TabView 4 onglets.

import os
import SwiftUI
import SwiftData

@main
struct CoachingSageApp: App {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "app")
    private let container: ModelContainer
    private let deps: AppDependencies
    @State private var isAuthenticated: Bool

    init() {
        let env = ProcessInfo.processInfo.environment
        let isUITesting = env["IS_UI_TESTING"] != nil || env["XCTestConfigurationFilePath"] != nil

        let config: ModelConfiguration
        let storeURL: URL?
        if isUITesting {
            config = ModelConfiguration(isStoredInMemoryOnly: true)
            storeURL = nil
        } else {
            let url = AppConstants.sharedStoreURL
            storeURL = url
            config = ModelConfiguration(url: url)
        }

        // Version du schéma SwiftData — incrémenter à chaque modif de modèle.
        let schemaVersion = 1
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
        if !isUITesting, let url = storeURL {
            let currentVersion = sharedDefaults?.integer(forKey: "swiftdata_schema_version")
                ?? UserDefaults.standard.integer(forKey: "swiftdata_schema_version")
            if currentVersion < schemaVersion {
                let fm = FileManager.default
                for suffix in ["", "-wal", "-shm"] {
                    let fileURL = suffix.isEmpty ? url : URL(fileURLWithPath: url.path + suffix)
                    try? fm.removeItem(at: fileURL)
                }
                sharedDefaults?.set(schemaVersion, forKey: "swiftdata_schema_version")
                UserDefaults.standard.set(schemaVersion, forKey: "swiftdata_schema_version")
                Self.logger.info("SwiftData store reset for schema v\(schemaVersion)")
            }
        }

        do {
            let container = try ModelContainer(
                for: SageCoreProfile.self, PendingOperation.self,
                configurations: config
            )
            self.container = container
            self.deps = AppDependencies.live(modelContext: container.mainContext)
        } catch {
            fatalError("Impossible d'initialiser le ModelContainer SwiftData : \(error)")
        }

        if isUITesting {
            // Mode UI testing : forcer l'authentification avec un utilisateur mock.
            let testUserId = UUID()
            _isAuthenticated = State(initialValue: true)
            let core = SageCoreProfile(id: testUserId)
            core.language = "fr"
            core.region = "FR"
            container.mainContext.insert(core)
            try? container.mainContext.save()
        } else {
            _isAuthenticated = State(initialValue: SupabaseService.shared.client.auth.currentSession != nil)
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticated {
                    // Placeholder Story 1.1a — remplacé par TabView en Story 1.2.
                    VStack(spacing: 16) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(Color.coachingPrimary)
                        Text("CoachingSage")
                            .font(.coachingDisplay)
                        Text("Authentifié — TabView en Story 1.2")
                            .font(.coachingBody)
                            .foregroundStyle(.secondary)
                        Button("Déconnexion") {
                            Task { try? await deps.authService.signOut() }
                        }
                        .primaryButtonStyle()
                        .padding(.top, 24)
                        .padding(.horizontal, 48)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.coachingBackground)
                } else {
                    AuthView(
                        authService: deps.authService,
                        coreProfileRepository: deps.coreProfileRepository
                    )
                }
            }
            .environment(\.appDependencies, deps)
            .task {
                // En UI testing, ne pas écouter authStateChanges (placeholder client → .signedOut parasite).
                guard ProcessInfo.processInfo.environment["IS_UI_TESTING"] == nil else { return }
                for await stateChange in SupabaseService.shared.client.auth.authStateChanges {
                    switch stateChange.event {
                    case .signedIn, .initialSession:
                        isAuthenticated = stateChange.session != nil
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
}
