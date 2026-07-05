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
    let weeklyRegenRepository: any WeeklyRegenRepository
    let authService: any AuthServiceProtocol
    let syncService: any SyncServiceProtocol
    let accountService: any AccountServiceProtocol
    let healthKitService: any HealthKitServiceProtocol
    let sageCoachingAIService: any SageCoachingAIServiceProtocol
    /// Story 3.4 Phase B.4 — orchestrateur regen S+1. Composé sur live() à partir
    /// de adaptedProgramRepository + weeklyRegenRepository + RegenInputsBuilder.
    let weeklyRegenApplicationService: any WeeklyRegenApplicationService
    /// Story 3.31 — renouvellement de cycle des routines (`routineCyclic`).
    /// Câblé sur live() à partir de l'`adaptedProgramRepository`.
    let routineCycleService: any RoutineCycleService
    /// Story 3.11 — re-planification d'un programme (reportSession + shiftWeek).
    /// Câblé sur live() à partir de l'`adaptedProgramRepository` uniquement.
    let replanifyService: any ReplanifyService
    /// Chantier durée réglable, pilote cycling (Increment 3) — ajustement in-program
    /// de la durée d'une séance. Câblé sur live() à partir de l'`adaptedProgramRepository`
    /// uniquement (même pattern que `replanifyService`).
    let sessionDurationAdjustmentService: any SessionDurationAdjustmentService
    /// Story 3.15 — bootstrap 3 dormants au 1er launch post-onboarding via
    /// `selectTopN`. Appelé UNIQUEMENT depuis `OnboardingViewModel.finalize()`.
    let dormantBootstrapService: DormantBootstrapService
    /// Epic 8 — notifications locales d'engagement (rappel séance, relance, célébration,
    /// renouvellement). Câblé sur live() ; `localeProvider` réglé par l'App.
    let notificationService: NotificationService

    @MainActor
    static func live(modelContext: ModelContext) -> AppDependencies {
        let coreProfileRepository = DefaultCoreProfileRepository(modelContext: modelContext)
        let coachingProfileRepository = DefaultCoachingProfileRepository(modelContext: modelContext)
        let coachingSportProfileRepository = DefaultCoachingSportProfileRepository(modelContext: modelContext)
        let adaptedProgramRepository = DefaultAdaptedProgramRepository(modelContext: modelContext)
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
        let routineCycleService = DefaultRoutineCycleService(
            adaptedProgramRepository: adaptedProgramRepository
        )
        let replanifyService = DefaultReplanifyService(
            adaptedProgramRepository: adaptedProgramRepository
        )
        let sessionDurationAdjustmentService = DefaultSessionDurationAdjustmentService(
            adaptedProgramRepository: adaptedProgramRepository
        )
        let autoProgramFactory = AutoProgramFactory(
            sportProfileRepository: coachingSportProfileRepository,
            adaptedProgramRepository: adaptedProgramRepository,
            coachingProfileRepository: coachingProfileRepository
        )
        let dormantBootstrapService = DormantBootstrapService(
            coachingProfileRepository: coachingProfileRepository,
            adaptedProgramRepository: adaptedProgramRepository,
            factory: autoProgramFactory
        )
        let notificationService = NotificationService(
            scheduler: SystemNotificationScheduler(),
            coreProfileRepository: coreProfileRepository,
            adaptedProgramRepository: adaptedProgramRepository,
            routineCycleService: routineCycleService
        )
        return AppDependencies(
            coreProfileRepository: coreProfileRepository,
            coachingProfileRepository: coachingProfileRepository,
            coachingSportProfileRepository: coachingSportProfileRepository,
            adaptedProgramRepository: adaptedProgramRepository,
            weeklyRegenRepository: weeklyRegenRepository,
            authService: authService,
            syncService: SyncService(modelContext: modelContext),
            accountService: AccountService(coreProfileRepository: coreProfileRepository),
            healthKitService: healthKitService,
            sageCoachingAIService: DefaultSageCoachingAIService(),
            weeklyRegenApplicationService: weeklyRegenApplicationService,
            routineCycleService: routineCycleService,
            replanifyService: replanifyService,
            sessionDurationAdjustmentService: sessionDurationAdjustmentService,
            dormantBootstrapService: dormantBootstrapService,
            notificationService: notificationService
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
