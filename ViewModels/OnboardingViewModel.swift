// ViewModels/OnboardingViewModel.swift
// Story 2.2 — state machine 4 écrans + import HealthKit + finalize.
import Foundation
import HealthKit
import os
import SwiftUI
import SageCore

enum OnboardingScreen: Int, CaseIterable {
    case firstNameLanguage = 0
    case personalData = 1
    case sportsSelection = 2
    case equipment = 3
    case disclaimerPARQ = 4

    var next: OnboardingScreen? {
        OnboardingScreen(rawValue: rawValue + 1)
    }
}

@MainActor
@Observable
final class OnboardingViewModel {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "onboarding")
    static let disclaimerCurrentVersion = "1.0"
    /// Délai max de la finalize Supabase. Au-delà, bascule en .error visible plutôt que de
    /// laisser un spinner infini sur le bouton Démarrer (cas hang Supabase SDK / réseau lent).
    static let finalizeTimeoutSeconds: TimeInterval = 10

    // MARK: - State machine

    var currentScreen: OnboardingScreen = .firstNameLanguage

    // MARK: - Écran 1

    var firstName: String = ""
    var language: String = Locale.current.language.languageCode?.identifier ?? "fr"

    // MARK: - Écran 2 (HealthKit-pre-fillable)

    var biologicalSex: String? {
        didSet { if biologicalSex != nil { hasUserEditedScreen2 = true } }
    }
    var dateOfBirth: Date? {
        didSet { if dateOfBirth != nil { hasUserEditedScreen2 = true } }
    }
    var weightKg: Double? {
        didSet { if weightKg != nil { hasUserEditedScreen2 = true } }
    }
    var heightCm: Double? {
        didSet { if heightCm != nil { hasUserEditedScreen2 = true } }
    }
    private(set) var hasUserEditedScreen2: Bool = false

    // MARK: - Écran 3

    var activeSports: Set<String> = []

    // MARK: - Écran 4

    /// Équipement générique multi-sport. Vide possible (user sans matériel).
    /// L'équipement spécifique sport (treadmill, etc.) reste dans le questionnaire sport.
    var equipment: Set<String> = []
    private(set) var hasUserEditedEquipment: Bool = false

    /// `true` si HealthKit voit un workout sourcé par un appareil watchOS dans la fenêtre récente.
    /// Utilisé pour pré-cocher gps_watch + heart_rate_monitor à l'écran équipement (overridable).
    private(set) var appleWatchDetected: Bool = false

    // MARK: - Écran 5

    var parqResponses: [String: Bool] = PARQQuestion.defaultResponses
    var analyticsConsent: Bool = false

    // MARK: - Save state

    var saveState: ViewState<Void> = .idle

    /// Bool dérivé Equatable — observé par OnboardingView (ViewState n'est pas Equatable côté SageCore SPM 1.3.0).
    /// Pattern aligné avec GardenSage OnboardingCompletionView (KNOWN-ISSUES.md:67-72).
    var isOnboardingFinalized: Bool {
        if case .success = saveState { return true }
        return false
    }

    var isSaving: Bool {
        if case .loading = saveState { return true }
        return false
    }

    var saveErrorMessage: String? {
        if case .error(let err) = saveState { return err.localizedDescription }
        return nil
    }

    // MARK: - Dependencies

    private let coreProfileRepository: any CoreProfileRepository
    private let coachingProfileRepository: any CoachingProfileRepository
    private let healthKitService: any HealthKitServiceProtocol

    init(
        coreProfileRepository: any CoreProfileRepository,
        coachingProfileRepository: any CoachingProfileRepository,
        healthKitService: any HealthKitServiceProtocol
    ) {
        self.coreProfileRepository = coreProfileRepository
        self.coachingProfileRepository = coachingProfileRepository
        self.healthKitService = healthKitService
    }

    /// Pré-remplit `firstName` depuis le profil core existant (cas user qui revient — ex. après réinstall).
    /// À appeler depuis `.task` au mount de l'écran 1.
    func prefillFromExistingProfile() async {
        guard firstName.isEmpty,
              let existing = try? await coreProfileRepository.fetchCurrentProfile(),
              let storedName = existing.firstName,
              !storedName.isEmpty
        else { return }
        firstName = storedName
    }

    // MARK: - Validators

    var canContinueScreen1: Bool {
        let trimmed = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return (1...50).contains(trimmed.count)
    }

    var canContinueScreen2: Bool {
        guard let sex = biologicalSex, !sex.isEmpty,
              dateOfBirth != nil,
              let w = weightKg, (30.0...250.0).contains(w),
              let h = heightCm, (100.0...230.0).contains(h)
        else { return false }
        return true
    }

    var canContinueScreen3: Bool {
        !activeSports.isEmpty
    }

    /// Équipement = facultatif (l'user peut n'avoir aucun matériel).
    var canContinueScreen4: Bool { true }

    /// Pré-coche `gps_watch + heart_rate_monitor` si HealthKit a vu un workout sourcé Apple Watch
    /// et que l'utilisateur n'a pas encore édité l'équipement. Idempotent.
    func applyAppleWatchEquipmentSuggestionIfNeeded() {
        guard appleWatchDetected, !hasUserEditedEquipment, equipment.isEmpty else { return }
        equipment.insert(EquipmentCode.gpsWatch.rawValue)
        equipment.insert(EquipmentCode.heartRateMonitor.rawValue)
    }

    func toggleEquipment(_ code: EquipmentCode) {
        hasUserEditedEquipment = true
        if equipment.contains(code.rawValue) {
            equipment.remove(code.rawValue)
        } else {
            equipment.insert(code.rawValue)
        }
    }

    /// Vrai si une capsule équipement a été pré-cochée depuis l'Apple Watch et n'a pas encore été touchée.
    func isAppleWatchSuggested(_ code: EquipmentCode) -> Bool {
        guard appleWatchDetected, !hasUserEditedEquipment else { return false }
        return code == .gpsWatch || code == .heartRateMonitor
    }

    var anyParqYes: Bool {
        parqResponses.values.contains(true)
    }

    var showHealthKitCTA: Bool {
        healthKitService.isHealthDataAvailable && !healthKitService.hasRequestedAuthorization
    }

    // MARK: - Navigation

    func goNext() {
        if currentScreen == .disclaimerPARQ {
            Task { await finalize() }
            return
        }
        if let next = currentScreen.next {
            currentScreen = next
        }
    }

    // MARK: - HealthKit import (écran 2)

    func importFromHealthKit() async {
        do {
            try await healthKitService.requestProfileAuthorization()
        } catch {
            #if DEBUG
            print("HealthKit auth failed (acceptable): \(error.localizedDescription)")
            #endif
        }

        let data = await healthKitService.fetchProfileData()

        // Détection Apple Watch (orthogonale au pré-fill profil ; ne dépend pas de hasUserEditedScreen2).
        let summary = await healthKitService.fetchWorkoutSummary(weeksBack: 8)
        appleWatchDetected = summary.appleWatchDetected

        // Préserve toute saisie utilisateur déjà faite (review P1-1).
        guard !hasUserEditedScreen2 else { return }

        if biologicalSex == nil, let sex = data.biologicalSex {
            biologicalSex = Self.mapBiologicalSex(sex)
        }
        if dateOfBirth == nil, let dob = data.dateOfBirth {
            dateOfBirth = dob
        }
        if weightKg == nil, let w = data.bodyMassKg, (30.0...250.0).contains(w) {
            weightKg = w
        }
        if heightCm == nil, let h = data.heightCm, (100.0...230.0).contains(h) {
            heightCm = h
        }

        // Les setters ont marqué hasUserEditedScreen2=true via didSet.
        // On reset car l'edit vient de la machine, pas de l'utilisateur.
        hasUserEditedScreen2 = false
    }

    static func mapBiologicalSex(_ value: HKBiologicalSex) -> String? {
        switch value {
        case .female: return "female"
        case .male: return "male"
        case .other: return "other"
        case .notSet: return nil
        @unknown default: return nil
        }
    }

    // MARK: - Finalize

    func finalize() async {
        saveState = .loading
        Self.logger.info("finalize: start")

        // Watchdog : si Supabase hang (cas réseau dégradé, SDK qui ne return jamais),
        // on bascule saveState en .error après 10s pour libérer le user du spinner.
        let watchdog = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Self.finalizeTimeoutSeconds))
            guard let self else { return }
            await MainActor.run {
                if case .loading = self.saveState {
                    Self.logger.error("finalize: TIMEOUT after \(Self.finalizeTimeoutSeconds)s — Supabase save did not return")
                    self.saveState = .error(.sync(String(localized: "onboarding.finalize.timeout")))
                }
            }
        }
        defer { watchdog.cancel() }

        do {
            // 1. Update core_profiles : first_name + language + analytics_consent.
            Self.logger.info("finalize: fetchCurrentProfile core")
            let coreProfile: SageCoreProfile
            if let existing = try await coreProfileRepository.fetchCurrentProfile() {
                coreProfile = existing
            } else {
                guard let userId = SupabaseService.shared.client.auth.currentSession?.user.id else {
                    Self.logger.error("finalize: no auth session")
                    saveState = .error(.sync("Session utilisateur introuvable"))
                    return
                }
                coreProfile = SageCoreProfile(id: userId, language: language)
            }
            coreProfile.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            coreProfile.language = language
            coreProfile.analyticsConsent = analyticsConsent
            coreProfile.updatedAt = Date()
            Self.logger.info("finalize: save core")
            try await coreProfileRepository.save(coreProfile)
            Self.logger.info("finalize: core saved")

            // 2. Save coaching_profiles avec onboarding_completed_at.
            // Réutilise une row existante (cas hydrate-on-miss : reprise sur nouveau device après réinstall)
            // pour éviter un conflit @Attribute(.unique) var id.
            Self.logger.info("finalize: fetchCurrentProfile coaching")
            let coaching = (try? await coachingProfileRepository.fetchCurrentProfile())
                ?? CoachingProfile(id: coreProfile.id)
            coaching.biologicalSex = biologicalSex
            coaching.dateOfBirth = dateOfBirth
            coaching.weightKg = weightKg
            coaching.heightCm = heightCm
            coaching.activeSports = Array(activeSports).sorted()
            coaching.equipment = Array(equipment).sorted()
            coaching.parqResponses = parqResponses
            coaching.requiresMedicalClearance = anyParqYes
            coaching.disclaimerVersionAccepted = Self.disclaimerCurrentVersion
            coaching.disclaimerAcceptedAt = Date()
            coaching.onboardingCompletedAt = Date()
            Self.logger.info("finalize: save coaching")
            try await coachingProfileRepository.save(coaching)
            Self.logger.info("finalize: coaching saved")

            // Si on a déjà timeout, ne pas écraser .error avec .success.
            if case .loading = saveState {
                saveState = .success(())
                Self.logger.info("finalize: success")
            } else {
                Self.logger.info("finalize: completed but state already \(String(describing: self.saveState))")
            }
        } catch {
            Self.logger.error("finalize: error \(error.localizedDescription)")
            if case .loading = saveState {
                saveState = .error(error as? AppError ?? .sync(error.localizedDescription))
            }
        }
    }
}
