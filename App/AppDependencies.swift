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
    let weeklyRegenRepository: any WeeklyRegenRepository
    let authService: any AuthServiceProtocol
    let syncService: any SyncServiceProtocol
    let accountService: any AccountServiceProtocol
    let healthKitService: any HealthKitServiceProtocol
    let sageCoachingAIService: any SageCoachingAIServiceProtocol
    /// Story 3.4 Phase B.4 — orchestrateur regen S+1. Composé sur live() à partir
    /// de adaptedProgramRepository + weeklyRegenRepository + RegenInputsBuilder.
    let weeklyRegenApplicationService: any WeeklyRegenApplicationService

    @MainActor
    static func live(modelContext: ModelContext) -> AppDependencies {
        let coreProfileRepository = DefaultCoreProfileRepository(modelContext: modelContext)
        let coachingProfileRepository = DefaultCoachingProfileRepository(modelContext: modelContext)
        let coachingSportProfileRepository = DefaultCoachingSportProfileRepository(modelContext: modelContext)
        let adaptedProgramRepository = DefaultAdaptedProgramRepository(modelContext: modelContext)
        let routineRepository = DefaultRoutineRepository(modelContext: modelContext)
        let weeklyRegenRepository = DefaultWeeklyRegenRepository(modelContext: modelContext)
        let authService = AuthService()
        let healthKitService = DefaultHealthKitService()
        let weeklyRegenApplicationService = DefaultWeeklyRegenApplicationService(
            adaptedProgramRepository: adaptedProgramRepository,
            regenRepository: weeklyRegenRepository,
            inputsProvider: RegenInputsBuilder(
                healthKit: healthKitService,
                regenRepository: weeklyRegenRepository,
                coachingProfileRepository: coachingProfileRepository
            )
        )
        return AppDependencies(
            coreProfileRepository: coreProfileRepository,
            coachingProfileRepository: coachingProfileRepository,
            coachingSportProfileRepository: coachingSportProfileRepository,
            adaptedProgramRepository: adaptedProgramRepository,
            routineRepository: routineRepository,
            weeklyRegenRepository: weeklyRegenRepository,
            authService: authService,
            syncService: SyncService(modelContext: modelContext),
            accountService: AccountService(coreProfileRepository: coreProfileRepository),
            healthKitService: healthKitService,
            sageCoachingAIService: DefaultSageCoachingAIService(),
            weeklyRegenApplicationService: weeklyRegenApplicationService
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
