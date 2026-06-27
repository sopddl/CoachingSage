// Coaching/Notifications/NotificationService.swift
// Epic 8 — orchestrateur : dérive les entrées primitives depuis les services
// existants, appelle le moteur de décision pur, planifie via le scheduler, et
// persiste l'état anti-spam. Best-effort & idempotent : on peut l'appeler
// généreusement aux hooks (launch, refresh dashboard, complétion, création prog).
import Foundation
import UserNotifications
import os

@MainActor
final class NotificationService {
    private let scheduler: any NotificationScheduling
    private let coreProfileRepository: any CoreProfileRepository
    private let adaptedProgramRepository: any AdaptedProgramRepository
    private let routineCycleService: any RoutineCycleService
    private let weeklyStatsService: WeeklyStatsService
    private let nextSessionResolver: NextSessionResolver

    /// Fournit la locale courante (langue in-app). Réglé par l'App après création du
    /// `LanguageManager`. Détermine le bundle de localisation du contenu de notif.
    var localeProvider: @MainActor () -> Locale

    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "notifications")

    init(
        scheduler: any NotificationScheduling,
        coreProfileRepository: any CoreProfileRepository,
        adaptedProgramRepository: any AdaptedProgramRepository,
        routineCycleService: any RoutineCycleService,
        weeklyStatsService: WeeklyStatsService = WeeklyStatsService(),
        nextSessionResolver: NextSessionResolver = NextSessionResolver(),
        localeProvider: @escaping @MainActor () -> Locale = { Locale(identifier: Locale.preferredLanguages.first ?? "fr") }
    ) {
        self.scheduler = scheduler
        self.coreProfileRepository = coreProfileRepository
        self.adaptedProgramRepository = adaptedProgramRepository
        self.routineCycleService = routineCycleService
        self.weeklyStatsService = weeklyStatsService
        self.nextSessionResolver = nextSessionResolver
        self.localeProvider = localeProvider
    }

    // MARK: - (Re)planification

    /// (Re)calcule et replanifie toutes les notifications d'engagement. Silencieux
    /// en cas d'erreur (jamais bloquant pour l'UX).
    func reschedule(now: Date = Date()) async {
        do {
            guard let profile = try await coreProfileRepository.fetchCurrentProfile() else { return }
            let prefs = profile.decodedNotificationPreferences

            // Pas d'autorisation système → on s'assure juste qu'aucun pending ne traîne.
            let status = await scheduler.authorizationStatus()
            let authorized = (status == .authorized || status == .provisional)
            guard authorized, prefs.enabled else {
                await scheduler.replacePending(with: [], locale: localeProvider())
                return
            }

            let programs = try await adaptedProgramRepository.fetchActive(for: profile.id)
            let nextSession = nextSessionResolver.nextSession(across: programs, now: now)
            let stats = weeklyStatsService.computeCurrentWeek(programs: programs, now: now)
            let lastCompletion = programs
                .flatMap { $0.completionState.sessionRecords.values.map(\.completedAt) }
                .max()
            let renewalDue = programs.contains { record in
                if case .due = routineCycleService.renewalState(for: record, now: now) { return true }
                return false
            }

            let input = NotificationDecisionInput(
                prefs: prefs,
                hasPendingSession: nextSession != nil,
                lastCompletionDate: lastCompletion,
                weeklyCompletedCount: stats.completedCount,
                renewalDue: renewalDue,
                now: now,
                calendar: .current
            )
            let decision = NotificationDecisionEngine.decide(input)
            await scheduler.replacePending(with: decision.plans, locale: localeProvider())

            // Persiste l'état anti-spam uniquement s'il a changé (évite une écriture
            // réseau à chaque refresh).
            if decision.updatedPrefs != prefs {
                profile.setNotificationPreferences(decision.updatedPrefs)
                try await coreProfileRepository.save(profile)
            }
        } catch {
            Self.logger.error("notifications.reschedule failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Permission (après le 1er programme créé)

    /// Demande la permission système si elle n'a jamais été demandée (`.notDetermined`)
    /// — appelé après la création d'un programme. Auto-gaté : ne redemande jamais une
    /// fois la décision système prise. Sur octroi : active les notifs + planifie.
    func requestAuthorizationIfNeeded(now: Date = Date()) async {
        let status = await scheduler.authorizationStatus()
        guard status == .notDetermined else { return }

        let granted = await scheduler.requestAuthorization()
        guard granted else { return }

        do {
            if let profile = try await coreProfileRepository.fetchCurrentProfile() {
                var prefs = profile.decodedNotificationPreferences
                prefs.enabled = true
                profile.setNotificationPreferences(prefs)
                try await coreProfileRepository.save(profile)
            }
        } catch {
            Self.logger.error("notifications.enable-on-grant failed: \(error.localizedDescription)")
        }
        await reschedule(now: now)
    }

    /// Annule tout le pending d'engagement (ex : toggle global OFF dans les réglages).
    func cancelAll() async {
        await scheduler.replacePending(with: [], locale: localeProvider())
    }

    // MARK: - Exposé pour l'UI réglages

    /// Statut système courant (pour décider d'afficher un hint « Réglages iOS »).
    func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        await scheduler.authorizationStatus()
    }

    /// Demande la permission système (passe-plat). Retourne `true` si accordée.
    @discardableResult
    func requestAuthorization() async -> Bool {
        await scheduler.requestAuthorization()
    }
}
