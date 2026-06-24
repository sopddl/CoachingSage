// ViewModels/OnboardingViewModel.swift
// Onboarding APP « fil de Léon » (party onboarding élargi 2026-06-22/23).
// 3 étapes : ① fil unique (prénom + sports + accord) · ② PARQ-light bref · ③ clôture Léon → finalize.
// ZÉRO saisie corporelle (poids/taille/sexe/date de naissance supprimés — jamais lus dans le code).
import Foundation
import os
import SwiftUI
import SageCore

/// Étapes de l'onboarding app. Le gros du flux tient dans `.welcome` (un seul écran qui défile) ;
/// `.parq` = exception MDR documentée (5 questions sécurité) ; `.closing` = clôture Léon + finalize.
enum OnboardingScreen: Int, CaseIterable {
    case welcome = 0
    case parq = 1
    case closing = 2

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
    /// laisser un spinner infini sur le bouton (cas hang Supabase SDK / réseau lent).
    static let finalizeTimeoutSeconds: TimeInterval = 10

    // MARK: - State machine

    var currentScreen: OnboardingScreen = .welcome

    // MARK: - Fil (écran ①)

    var firstName: String = ""
    var language: String = Locale.current.language.languageCode?.identifier ?? "fr"
    /// Sports pratiqués (rawValues `SportCode`). Multi-sélection, ≥ 1 requis pour valider.
    var activeSports: Set<String> = []
    /// `true` une fois que l'utilisateur a tapé « Autoriser » sur le bloc accord (best-effort,
    /// le refus système reste silencieux côté lecture HealthKit). Sert juste à basculer le
    /// libellé du bouton en « Autorisé ✓ ».
    private(set) var healthAuthorized: Bool = false

    // MARK: - PARQ-light (écran ②)

    var parqResponses: [String: Bool] = PARQQuestion.defaultResponses
    /// Consentement analytics — RGPD : finalité distincte de l'accord Apple Santé, non pré-coché,
    /// refusable sans dégrader le service. Co-localisé dans le bloc accord du fil (Sophie : « un écran »).
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
    /// À appeler depuis `.task` au mount du fil.
    func prefillFromExistingProfile() async {
        guard firstName.isEmpty,
              let existing = try? await coreProfileRepository.fetchCurrentProfile(),
              let storedName = existing.firstName,
              !storedName.isEmpty
        else { return }
        firstName = storedName
    }

    // MARK: - Validators

    /// Prénom valide (1–50 caractères après trim).
    var hasValidFirstName: Bool {
        let trimmed = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return (1...50).contains(trimmed.count)
    }

    /// Le vert « C'est parti » s'active dès qu'on a un prénom ET au moins un sport.
    var canStart: Bool {
        hasValidFirstName && !activeSports.isEmpty
    }

    var anyParqYes: Bool {
        parqResponses.values.contains(true)
    }

    /// Affiche le bouton « Autoriser » tant que HealthKit est dispo et que l'autorisation
    /// n'a pas encore été demandée sur ce device. Sinon → libellé « Autorisé ✓ ».
    var showHealthAuthorizeButton: Bool {
        healthKitService.isHealthDataAvailable
            && !healthKitService.hasRequestedAuthorization
            && !healthAuthorized
    }

    var isHealthDataAvailable: Bool {
        healthKitService.isHealthDataAvailable
    }

    // MARK: - Accord HealthKit (bloc ③ du fil)

    /// Bloc accord — demande la lecture des données de SÉANCE + forme (workouts, FC, énergie,
    /// distances, FC repos, VFC, sommeil, VO2max). Jamais poids/taille/sexe/date de naissance.
    /// Best-effort : un refus système reste silencieux côté lecture, on ne bloque pas « C'est parti ».
    func authorizeHealthData() async {
        do {
            try await healthKitService.requestWorkoutAndFitnessAuthorization()
        } catch {
            #if DEBUG
            print("HealthKit auth failed (acceptable): \(error.localizedDescription)")
            #endif
        }
        healthAuthorized = true
    }

    // MARK: - Navigation

    func goNext() {
        if let next = currentScreen.next {
            currentScreen = next
        }
    }

    /// Revenir à l'écran précédent. No-op sur le premier écran / sur la clôture (finalize en cours).
    func goPrevious() {
        guard canGoPrevious, let previous = OnboardingScreen(rawValue: currentScreen.rawValue - 1) else { return }
        currentScreen = previous
    }

    /// Retour interdit sur le fil (premier écran) et sur la clôture (finalize en cours/terminé).
    var canGoPrevious: Bool {
        currentScreen == .parq
    }

    // MARK: - Finalize

    func finalize() async {
        // Idempotent : pas de double-finalize si la clôture re-déclenche le .task.
        if case .loading = saveState { return }
        if case .success = saveState { return }

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
            // NB onboarding app : on NE touche PAS biologicalSex/dateOfBirth/weightKg/heightCm/equipment —
            // l'app ne collecte plus le corps (zéro saisie corporelle) et l'équipement est déplacé vers
            // l'onboarding programme. On laisse ces champs intacts (nil pour un nouvel utilisateur,
            // conservés pour un retour après réinstall).
            Self.logger.info("finalize: fetchCurrentProfile coaching")
            let coaching = (try? await coachingProfileRepository.fetchCurrentProfile())
                ?? CoachingProfile(id: coreProfile.id)
            coaching.activeSports = Array(activeSports).sorted()
            coaching.parqResponses = parqResponses
            coaching.requiresMedicalClearance = anyParqYes
            coaching.disclaimerVersionAccepted = Self.disclaimerCurrentVersion
            coaching.disclaimerAcceptedAt = Date()
            coaching.onboardingCompletedAt = Date()
            Self.logger.info("finalize: save coaching")
            try await coachingProfileRepository.save(coaching)
            Self.logger.info("finalize: coaching saved")

            // Story 3.16 AC14 — best-effort silencieux : demande l'extension HK
            // natation (distanceSwimming + swimmingStrokeCount) si l'user a choisi
            // natation à l'onboarding. Idempotent côté service.
            if activeSports.contains(SportCode.swimming.rawValue) {
                try? await healthKitService.requestSwimAuthorizationIfNeeded()
            }

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
