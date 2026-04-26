// App/AppDependencies.swift
// Container d'injection de dépendances — injecté via SwiftUI environment.
// Story 1.1a bootstrap : version minimale (auth + core profile repo).
// Enrichi au fil des stories (SyncService Story 1.3, repositories domaine Epic 2+).
import SwiftUI
import SwiftData
import SageCore

struct AppDependencies {
    let coreProfileRepository: any CoreProfileRepository
    let authService: any AuthServiceProtocol
    let syncService: any SyncServiceProtocol
    let accountService: any AccountServiceProtocol

    @MainActor
    static func live(modelContext: ModelContext) -> AppDependencies {
        let coreProfileRepository = DefaultCoreProfileRepository(modelContext: modelContext)
        let authService = AuthService()
        return AppDependencies(
            coreProfileRepository: coreProfileRepository,
            authService: authService,
            syncService: SyncService(modelContext: modelContext),
            accountService: AccountService(coreProfileRepository: coreProfileRepository)
        )
    }
}

private struct AppDependenciesKey: EnvironmentKey {
    static let defaultValue: AppDependencies? = nil
}

extension EnvironmentValues {
    var appDependencies: AppDependencies? {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}
