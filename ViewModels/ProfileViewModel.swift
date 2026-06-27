// ViewModels/ProfileViewModel.swift
// Story 2.3 — hub de modification : fetch core+coaching profiles, toggle analytics inline debouncé.
// Sécurité cross-user : capture userId au début de fetch, discard si auth bascule (review P0-4).
import Foundation
import os
import SwiftUI
import SageCore
import UserNotifications

@MainActor
@Observable
final class ProfileViewModel {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "viewmodel")

    typealias Profiles = (core: SageCoreProfile, coaching: CoachingProfile)

    // MARK: - State

    var state: ViewState<Profiles> = .idle

    /// Dérivé de `state` — bindable côté ProfileView pour le toggle inline.
    /// Mutation déclenche un save debouncé via `scheduleAnalyticsSave(_:)`.
    var analyticsConsent: Bool = false

    /// Dérivé pour spinner inline pendant un save toggle analytics en cours.
    var isAnalyticsSaving: Bool = false

    /// Affiché 3s après échec save analytics (review P1-2).
    var privacyErrorVisible: Bool = false

    // MARK: - Notifications (Epic 8)

    /// Préférences notifs bindables (toggles + heure). Chargées au refresh.
    var notificationPrefs = NotificationPreferences()
    /// `true` si la permission système est refusée → on affiche un hint « Réglages iOS ».
    var notificationSystemDenied = false
    /// Spinner inline pendant un save des prefs notifs.
    var isNotificationsSaving = false

    // MARK: - Dependencies

    private let coreProfileRepository: any CoreProfileRepository
    private let coachingProfileRepository: any CoachingProfileRepository
    private let authService: any AuthServiceProtocol
    private let notificationService: NotificationService?

    // MARK: - Internals

    private var analyticsDebounceTask: Task<Void, Never>?
    private var notificationDebounceTask: Task<Void, Never>?

    init(
        coreProfileRepository: any CoreProfileRepository,
        coachingProfileRepository: any CoachingProfileRepository,
        authService: any AuthServiceProtocol,
        notificationService: NotificationService? = nil
    ) {
        self.coreProfileRepository = coreProfileRepository
        self.coachingProfileRepository = coachingProfileRepository
        self.authService = authService
        self.notificationService = notificationService
    }

    // MARK: - Derived accessors

    var loadedProfiles: Profiles? {
        if case .success(let p) = state { return p }
        return nil
    }

    var requiresMedicalClearance: Bool {
        loadedProfiles?.coaching.requiresMedicalClearance ?? false
    }

    // MARK: - Refresh

    /// Idempotent : peut être appelé depuis `.onAppear` à chaque pop NavigationLink.
    /// Capture l'userId courant et discard si auth a basculé entre temps (review P0-4).
    func refresh() async {
        let capturedUserId = authService.currentUserId
        if case .idle = state { state = .loading }

        do {
            async let coreTask = coreProfileRepository.fetchCurrentProfile()
            async let coachingTask = coachingProfileRepository.fetchCurrentProfile()
            let core = try await coreTask
            let coaching = try await coachingTask

            // Auth a basculé pendant le fetch → discard.
            guard authService.currentUserId == capturedUserId else {
                Self.logger.debug("ProfileViewModel.refresh: auth changed mid-fetch, discarding")
                return
            }

            guard let core, let coaching else {
                Self.logger.error("ProfileViewModel.refresh: notFound — core=\(core == nil ? "nil" : "ok") coaching=\(coaching == nil ? "nil" : "ok") userId=\(capturedUserId?.uuidString ?? "anon")")
                state = .error(.notFound)
                return
            }

            state = .success((core: core, coaching: coaching))
            analyticsConsent = core.analyticsConsent
            notificationPrefs = core.decodedNotificationPreferences
            if let ns = notificationService {
                notificationSystemDenied = await ns.currentAuthorizationStatus() == .denied
            }
        } catch {
            guard authService.currentUserId == capturedUserId else { return }
            state = .error(error as? AppError ?? .sync(error.localizedDescription))
        }
    }

    // MARK: - Analytics toggle (debounced 500ms)

    func scheduleAnalyticsSave(value: Bool) {
        analyticsDebounceTask?.cancel()
        analyticsDebounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled, let self else { return }
            await self.performAnalyticsSave(value: value)
        }
    }

    private func performAnalyticsSave(value: Bool) async {
        guard let core = loadedProfiles?.core else { return }
        isAnalyticsSaving = true
        defer { isAnalyticsSaving = false }

        core.analyticsConsent = value
        core.updatedAt = Date()
        do {
            try await coreProfileRepository.save(core)
        } catch {
            // Revert seulement si l'utilisateur n'a pas re-toggled depuis (review P1-2).
            if self.analyticsConsent == value {
                self.analyticsConsent = !value
                self.privacyErrorVisible = true
                Task { [weak self] in
                    try? await Task.sleep(for: .seconds(3))
                    self?.privacyErrorVisible = false
                }
            }
        }
    }

    // MARK: - Notifications toggle / save (Epic 8)

    /// Bascule l'interrupteur global. À l'activation, gère la permission système :
    /// `.notDetermined` → demande ; `.denied` → revert + hint ; sinon → active.
    func setNotificationsEnabled(_ on: Bool) async {
        guard let core = loadedProfiles?.core, let ns = notificationService else {
            notificationPrefs.enabled = on
            return
        }
        if on {
            let status = await ns.currentAuthorizationStatus()
            switch status {
            case .notDetermined:
                let granted = await ns.requestAuthorization()
                if granted {
                    notificationPrefs.enabled = true
                    await persistNotificationPrefs(core: core)
                    await ns.reschedule()
                } else {
                    notificationPrefs.enabled = false
                    notificationSystemDenied = await ns.currentAuthorizationStatus() == .denied
                }
            case .denied:
                notificationPrefs.enabled = false
                notificationSystemDenied = true
            default:
                notificationPrefs.enabled = true
                await persistNotificationPrefs(core: core)
                await ns.reschedule()
            }
        } else {
            notificationPrefs.enabled = false
            await persistNotificationPrefs(core: core)
            await ns.cancelAll()
        }
    }

    /// Save debouncé pour les changements de type/heure (quand le global est déjà ON).
    func scheduleNotificationPrefsSave() {
        notificationDebounceTask?.cancel()
        notificationDebounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled, let self else { return }
            guard let core = self.loadedProfiles?.core else { return }
            await self.persistNotificationPrefs(core: core)
            await self.notificationService?.reschedule()
        }
    }

    private func persistNotificationPrefs(core: SageCoreProfile) async {
        isNotificationsSaving = true
        defer { isNotificationsSaving = false }
        core.setNotificationPreferences(notificationPrefs)
        core.updatedAt = Date()
        try? await coreProfileRepository.save(core)
    }
}
