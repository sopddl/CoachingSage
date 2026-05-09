// App/AppDependencies.swift
// Container d'injection de dépendances — injecté via SwiftUI environment.
// Story 1.1a bootstrap : version minimale (auth + core profile repo).
// Enrichi au fil des stories (SyncService Story 1.3, repositories domaine Epic 2+).
import SwiftUI
import SwiftData
import SageCore

struct AppDependencies {
    let coreProfileRepository: any CoreProfileRepository
    let coachingProfileRepository: any CoachingProfileRepository
    let coachingSportProfileRepository: any CoachingSportProfileRepository
    let adaptedProgramRepository: any AdaptedProgramRepository
    let routineRepository: any RoutineRepository
    let authService: any AuthServiceProtocol
    let syncService: any SyncServiceProtocol
    let accountService: any AccountServiceProtocol
    let healthKitService: any HealthKitServiceProtocol
    let sageCoachingAIService: any SageCoachingAIServiceProtocol

    @MainActor
    static func live(modelContext: ModelContext) -> AppDependencies {
        let coreProfileRepository = DefaultCoreProfileRepository(modelContext: modelContext)
        let coachingProfileRepository = DefaultCoachingProfileRepository(modelContext: modelContext)
        let coachingSportProfileRepository = DefaultCoachingSportProfileRepository(modelContext: modelContext)
        let adaptedProgramRepository = DefaultAdaptedProgramRepository(modelContext: modelContext)
        let routineRepository = DefaultRoutineRepository(modelContext: modelContext)
        let authService = AuthService()
        return AppDependencies(
            coreProfileRepository: coreProfileRepository,
            coachingProfileRepository: coachingProfileRepository,
            coachingSportProfileRepository: coachingSportProfileRepository,
            adaptedProgramRepository: adaptedProgramRepository,
            routineRepository: routineRepository,
            authService: authService,
            syncService: SyncService(modelContext: modelContext),
            accountService: AccountService(coreProfileRepository: coreProfileRepository),
            healthKitService: DefaultHealthKitService(),
            sageCoachingAIService: DefaultSageCoachingAIService()
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
