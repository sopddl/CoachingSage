// Coaching/Bootstrap/DormantBootstrapService.swift
// Story 3.15 — Bootstrap 3 dormants au 1er launch post-onboarding via `selectTopN`.
//
// **Conception** :
//   - Idempotent : DEUX flags set à `true` AVANT toute persistance de dormant →
//     pas de retry au prochain launch, même en cas d'échec partiel.
//       * `bootstrappedDormants` : sync Supabase, idempotence globale user.
//       * `bootstrappedDormantsLocal` : SwiftData-only, idempotence sur CE device
//         uniquement (Story 3.21 hotfix Bug F). Skip ssi LES DEUX sont `true`.
//         Cross-device : flag global=true mais flag local=false → bootstrap
//         re-trigger pour repeupler les dormants en local (records non sync).
//   - Cap-aware : respecte `dormantCap = 10`. Si déjà ≥10 dormants, no-op.
//   - Silent on cap : catch `ProgramCapReached.dormant` silencieusement (cas
//     pathologique où le cap est atteint pendant la boucle).
//   - Trigger : `OnboardingViewModel.finalize()` ET `SessionDashboardViewModel.refresh()`
//     (best-effort, idempotent par les deux flags). Le second trigger est ce qui
//     permet au scénario cross-device de se rattraper au cold launch.
//
// **Algorithme** :
//   1. fetch CoachingProfile. Si nil ou `bootstrappedDormants == true` → no-op.
//   2. Compter dormants existants (cap-aware).
//   3. Flip flag `bootstrappedDormants = true` + save (idempotence avant
//      persistance).
//   4. Si l'user a déjà des programmes (started+dormant > 0) → no-op
//      (flag déjà flipped, plus jamais bootstrap).
//   5. selectTopN(n: min(3, dormantSlotsAvailable)).
//   6. Pour chaque template : makeDefaultSportProfile → previewGenerate →
//      commit. Catch `ProgramCapReached` + break.
//
// Retourne le nombre de dormants effectivement persistés (0..3).
import Foundation
import os
import TemplateModel

@MainActor
final class DormantBootstrapService {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "dormant-bootstrap")
    private static let dormantCap = 10
    private static let bootstrapN = 3

    private let coachingProfileRepository: any CoachingProfileRepository
    private let adaptedProgramRepository: any AdaptedProgramRepository
    private let factory: AutoProgramFactory
    private let templateLibraryProvider: () async throws -> ProgramTemplateLibrary
    private let suggestionLevelProvider: (CoachingProfile) -> String

    init(
        coachingProfileRepository: any CoachingProfileRepository,
        adaptedProgramRepository: any AdaptedProgramRepository,
        factory: AutoProgramFactory,
        templateLibraryProvider: @escaping () async throws -> ProgramTemplateLibrary = ProgramTemplateLibrary.bundled,
        suggestionLevelProvider: @escaping (CoachingProfile) -> String = { _ in "beginner" }
    ) {
        self.coachingProfileRepository = coachingProfileRepository
        self.adaptedProgramRepository = adaptedProgramRepository
        self.factory = factory
        self.templateLibraryProvider = templateLibraryProvider
        self.suggestionLevelProvider = suggestionLevelProvider
    }

    /// Bootstrap jusqu'à 3 dormants si :
    ///   - le profil coaching existe,
    ///   - `bootstrappedDormants == false`,
    ///   - `startedCount == 0 && dormantCount == 0`.
    ///
    /// Retourne le nombre de dormants effectivement persistés (0..3).
    /// Best-effort : ne throw pas — log + return 0 sur toute erreur d'I/O
    /// (le flag est néanmoins flippé si on a passé l'étape 3, garantissant
    /// l'idempotence).
    @discardableResult
    func bootstrapIfNeeded() async -> Int {
        // Étape 1 — fetch profile + check flag
        let profile: CoachingProfile
        do {
            guard let fetched = try await coachingProfileRepository.fetchCurrentProfile() else {
                Self.logger.debug("bootstrap skipped: no coaching profile")
                return 0
            }
            profile = fetched
        } catch {
            Self.logger.error("bootstrap fetch profile failed: \(error.localizedDescription)")
            return 0
        }
        // Story 3.21 hotfix Bug F : skip ssi LES DEUX flags `true`. Le flag local
        // (SwiftData-only) distingue "ce device a déjà bootstrap" vs "le user a
        // déjà bootstrap sur UN device" (flag global sync Supabase).
        guard !(profile.bootstrappedDormants && profile.bootstrappedDormantsLocal) else {
            Self.logger.debug("bootstrap skipped: both flags already true")
            return 0
        }

        let userId = profile.id

        // Étape 2 — count existing
        let startedCount: Int
        let dormantCount: Int
        do {
            startedCount = try await adaptedProgramRepository.fetchStartedCount(for: userId)
            dormantCount = try await adaptedProgramRepository.fetchDormantCount(for: userId)
        } catch {
            Self.logger.error("bootstrap count failed: \(error.localizedDescription)")
            return 0
        }

        // Étape 3 — flip LES DEUX flags AVANT toute persistance (idempotence
        // globale + locale, cf Story 3.21 hotfix Bug F).
        profile.bootstrappedDormants = true
        profile.bootstrappedDormantsLocal = true
        do {
            try await coachingProfileRepository.save(profile)
        } catch {
            // Si le save throw, on n'a pas pu poser les flags → bootstrap n'est
            // pas garanti idempotent. On préfère ne RIEN persister plutôt que
            // de potentiellement re-générer des dormants au prochain launch.
            Self.logger.error("bootstrap save flag failed: \(error.localizedDescription) — abort")
            return 0
        }

        // Étape 4 — skip si l'user a déjà des programmes
        guard startedCount == 0 && dormantCount == 0 else {
            Self.logger.debug("bootstrap skipped: user already has programs (started=\(startedCount), dormant=\(dormantCount))")
            return 0
        }

        // Étape 5 — selectTopN avec cap-aware nMax
        let availableSlots = max(0, Self.dormantCap - dormantCount)
        let nMax = min(Self.bootstrapN, availableSlots)
        guard nMax > 0 else {
            Self.logger.debug("bootstrap skipped: no dormant slots available (cap=\(Self.dormantCap), current=\(dormantCount))")
            return 0
        }

        let library: ProgramTemplateLibrary
        do {
            library = try await templateLibraryProvider()
        } catch {
            Self.logger.error("bootstrap library load failed: \(error.localizedDescription)")
            return 0
        }
        let selector = ProgramTemplateSelector(library: library)
        let topNProfile = TopNSelectionProfile(
            level: suggestionLevelProvider(profile),
            sportCodes: profile.activeSports
        )
        let templates = selector.selectTopN(profile: topNProfile, n: nMax)
        guard !templates.isEmpty else {
            Self.logger.debug("bootstrap skipped: selectTopN returned 0 templates")
            return 0
        }

        // Étape 6 — generate + commit chaque template
        var persisted = 0
        for template in templates {
            do {
                let sportProfile = AutoProgramFactory.makeDefaultSportProfile(
                    userId: userId,
                    sportCode: template.sport.appSportCode,
                    autoprofileLevel: suggestionLevelProvider(profile),
                    medicalClearanceAcknowledged: profile.requiresMedicalClearance
                )
                let preview = try await factory.previewGenerate(
                    template: template,
                    sportProfile: sportProfile,
                    userId: userId
                )
                _ = try await factory.commit(preview: preview, userId: userId)
                persisted += 1
            } catch ProgramCapReached.dormant {
                Self.logger.debug("bootstrap hit dormant cap mid-loop (persisted=\(persisted))")
                break
            } catch {
                Self.logger.error("bootstrap commit failed for template \(template.id): \(error.localizedDescription) — continue")
                continue
            }
        }

        Self.logger.info("bootstrap completed: persisted \(persisted) dormant(s) for user \(userId)")
        return persisted
    }
}
