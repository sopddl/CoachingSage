// App/AppDependencies.swift
// Container d'injection de dépendances — injecté via SwiftUI environment.
// Story 1.1a bootstrap : version minimale (auth + core profile repo).
// Enrichi au fil des stories (SyncService Story 1.3, repositories domaine Epic 2+).
import SwiftUI
import SwiftData

struct AppDependencies {
    let coreProfileRepository: any CoreProfileRepository
    let authService: any AuthServiceProtocol

    @MainActor
    static func live(modelContext: ModelContext) -> AppDependencies {
        AppDependencies(
            coreProfileRepository: DefaultCoreProfileRepository(modelContext: modelContext),
            authService: AuthService()
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
