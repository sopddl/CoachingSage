// ViewModels/OnboardingViewModel.swift
// Story 2.2 — state machine 4 écrans + import HealthKit + finalize.
import Foundation
import HealthKit
import os
import SwiftUI
import SageCore

enum OnboardingScreen: Int, CaseIterable {
    case firstNameLanguage = 0
    case thirdPartyAppsSync = 1  // Story 3.z — apps non sync Apple Santé, avant la pop-up HK
    case personalData = 2
    case howItWorks = 3          // Story sœur post-3.3b — écran pédagogique
    case sportsSelection = 4
    case equipment = 5
    case disclaimerPARQ = 6

    var next: OnboardingScreen? {
        OnboardingScreen(rawValue: rawValue + 1)
    }
}

/// Story 3.z — apps sport tierces déclarées par l'utilisateur à l'onboarding
/// (cas user qui logge avec Strava/Decathlon/Garmin/Runkeeper sans avoir
/// activé la sync Apple Santé). Persisté en UserDefaults V1 — la donnée sert
/// à afficher un rappel doux dans Progrès si l'historique est vide (V2).
enum ThirdPartyApp: String, CaseIterable, Codable, Sendable {
    case strava
    case decathlon
    case runkeeper
    case garmin
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

    // MARK: - Écran 2 (apps tierces — Story 3.z)

    /// `nil` tant que l'écran n'est pas répondu ; `true` = "Oui j'utilise des apps non sync"
    /// → on affiche la checklist ; `false` = "Non, suivant" → on skippe.
    var usesUnsyncedApps: Bool?

    /// Apps cochées si `usesUnsyncedApps == true`. Set rawValues `ThirdPartyApp.rawValue`.
    var declaredThirdPartyApps: Set<String> = []

    /// Texte libre optionnel (champ "Autre app"). Max 60 chars, non bloquant.
    var otherAppText: String = ""

    /// L'écran apps tierces n'est jamais bloquant — on peut passer "Oui" sans rien cocher
    /// ou "Non" tout court.
    var canContinueScreen2AppsSync: Bool { true }

    func toggleThirdPartyApp(_ app: ThirdPartyApp) {
        if declaredThirdPartyApps.contains(app.rawValue) {
            declaredThirdPartyApps.remove(app.rawValue)
        } else {
            declaredThirdPartyApps.insert(app.rawValue)
        }
    }

    /// Persiste la déclaration en UserDefaults (V1 — en attendant un champ JSONB côté Supabase).
    /// Appelé au goNext depuis l'écran thirdPartyAppsSync.
    func saveThirdPartyAppsDeclaration() {
        guard let answered = usesUnsyncedApps else { return }
        struct Declaration: Codable {
            let usesUnsyncedApps: Bool
            let apps: [String]
            let other: String?
            let timestamp: Date
        }
        let trimmed = otherAppText.trimmingCharacters(in: .whitespacesAndNewlines)
        let payload = Declaration(
            usesUnsyncedApps: answered,
            apps: Array(declaredThirdPartyApps).sorted(),
            other: trimmed.isEmpty ? nil : String(trimmed.prefix(60)),
            timestamp: Date()
        )
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: Self.thirdPartyAppsDefaultsKey)
        }
    }

    static let thirdPartyAppsDefaultsKey = "onboarding_declared_apps"

    // MARK: - Écran 3 (HealthKit-pre-fillable)

    var biologicalSex: String?
    var dateOfBirth: Date?
    var weightKg: Double?
    var heightCm: Double?

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
    /// Story 3.15 — bootstrap 3 dormants post-onboarding. Optional pour
    /// tests qui n'ont pas besoin de tester le bootstrap.
    private let dormantBootstrapService: DormantBootstrapService?

    init(
        coreProfileRepository: any CoreProfileRepository,
        coachingProfileRepository: any CoachingProfileRepository,
        healthKitService: any HealthKitServiceProtocol,
        dormantBootstrapService: DormantBootstrapService? = nil
    ) {
        self.coreProfileRepository = coreProfileRepository
        self.coachingProfileRepository = coachingProfileRepository
        self.healthKitService = healthKitService
        self.dormantBootstrapService = dormantBootstrapService
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
        // Story 3.z — quand on quitte l'écran apps tierces, persiste la déclaration
        // utilisateur (V1 UserDefaults) avant de basculer sur personalData (qui déclenche
        // la pop-up HK).
        if currentScreen == .thirdPartyAppsSync {
            saveThirdPartyAppsDeclaration()
        }
        if let next = currentScreen.next {
            currentScreen = next
        }
    }

    /// Story 3.z — revenir à l'écran précédent. No-op sur le premier écran.
    /// On ne reset aucune donnée saisie : si l'user revient sur l'écran apps tierces
    /// après l'avoir validé, ses réponses sont conservées.
    func goPrevious() {
        guard let previous = OnboardingScreen(rawValue: currentScreen.rawValue - 1) else { return }
        currentScreen = previous
    }

    var canGoPrevious: Bool {
        currentScreen != .firstNameLanguage
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

        // Détection Apple Watch.
        // Story 3.z — fenêtre 12 sem pour aligner sur la promesse "3 mois" du premier topo Progrès.
        let summary = await healthKitService.fetchWorkoutSummary(weeksBack: 12)
        appleWatchDetected = summary.appleWatchDetected

        // Pré-fill per-field, uniquement si l'utilisateur n'a pas déjà saisi cette valeur
        // (le check `== nil` protège la saisie user — pas besoin d'un flag global racy
        // qui se déclenchait à l'ouverture de la pop-up HK, cf bug 2026-05-15).
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

            // Story 3.15 — bootstrap 3 dormants si possible. Best-effort,
            // ne bloque pas le succès onboarding si bootstrap échoue. Le service
            // est idempotent : si flag déjà true ou si l'user a déjà des
            // programmes (cas pre-3.15 / hydrate-on-miss), no-op.
            if let bootstrap = dormantBootstrapService {
                let persisted = await bootstrap.bootstrapIfNeeded()
                Self.logger.info("finalize: bootstrap persisted \(persisted) dormant(s)")
            }

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
