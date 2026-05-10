// ViewModels/ProfileViewModel.swift
// Story 2.3 — hub de modification : fetch core+coaching profiles, toggle analytics inline debouncé.
// Sécurité cross-user : capture userId au début de fetch, discard si auth bascule (review P0-4).
import Foundation
import os
import SwiftUI
import SageCore

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

    // MARK: - Dependencies

    private let coreProfileRepository: any CoreProfileRepository
    private let coachingProfileRepository: any CoachingProfileRepository
    private let authService: any AuthServiceProtocol

    // MARK: - Internals

    private var analyticsDebounceTask: Task<Void, Never>?

    init(
        coreProfileRepository: any CoreProfileRepository,
        coachingProfileRepository: any CoachingProfileRepository,
        authService: any AuthServiceProtocol
    ) {
        self.coreProfileRepository = coreProfileRepository
        self.coachingProfileRepository = coachingProfileRepository
        self.authService = authService
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
}
