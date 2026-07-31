// Services/AccountDataPurgeService.swift
// Story 1.4 follow-up (RGPD Art. 17) — purge de l'état LOCAL restant après
// suppression de compte.
//
// Contexte (bug remonté par Sophie 2026-07-31) : `AccountService.deleteAccount()`
// ne faisait que soft-delete `SageCoreProfile` (flag, pas de suppression physique
// locale). Côté serveur, `coaching_profiles` (FK CASCADE → core_profiles) et
// `coaching_sport_profiles` (FK CASCADE → auth.users) sont bien effacés par
// l'edge function `delete-account` — ce n'est PAS un trou serveur. Mais en local,
// `CoachingProfile.onboardingCompletedAt` restait présent en SwiftData, donc le
// gate d'onboarding (`CoachingSageApp.refreshOnboardingState`) trouvait un profil
// "onboardé" et sautait directement sur l'accueil après une suppression de compte
// — contredisant le critère d'acceptation d'origine de la Story 1.4 ("les données
// locales SwiftData sont effacées").
//
// Ce service comble ce trou : il purge tout ce qui reste en local pour un userId
// donné (SwiftData spécifique CoachingSage, fichier journal regen JSON plat,
// UserDefaults liées aux préférences/onboarding). Appelé en dernière étape de
// `AccountService.deleteAccount()`, uniquement après succès complet (softDelete +
// hard-delete edge function) — jamais sur un échec, pour ne pas effacer les
// données locales d'un compte dont la suppression a en fait échoué.
//
// Volontairement best-effort par item (log + continue) : à ce stade le compte est
// déjà supprimé côté serveur (l'action légalement significative a réussi), une
// erreur de purge locale sur CE device ne doit pas faire remonter une erreur à
// l'utilisateur pour une suppression qui, de son point de vue, a réussi.
import Foundation
import SwiftData
import os

protocol AccountDataPurging {
    /// Purge tout l'état local lié à `userId` : profils/programmes SwiftData
    /// spécifiques CoachingSage, journal regen (fichier JSON), et les clés
    /// UserDefaults liées à l'onboarding/aux préférences.
    @MainActor func purgeLocalData(for userId: UUID)
}

final class AccountDataPurgeService: AccountDataPurging {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "service")

    private let modelContext: ModelContext
    private let journalStore: JournalFileStore
    private let userDefaults: UserDefaults

    /// Clés UserDefaults device-globales (non scopées par userId) liées aux
    /// préférences/à l'onboarding — cf. audit cross-app 2026-07-31.
    private static let globalPreferenceKeys = [
        "coaching.voice.enabled",
        "coaching.voice.gender",
        "coaching.glossary.discovery.tooltip.shown",
        "coaching.session.glossary.firstVisitDone",
        "progress_first_launch_seen",
        "leon_subscription_tier"
    ]

    init(
        modelContext: ModelContext,
        journalStore: JournalFileStore = .documentsDefault(),
        userDefaults: UserDefaults = .standard
    ) {
        self.modelContext = modelContext
        self.journalStore = journalStore
        self.userDefaults = userDefaults
    }

    @MainActor
    func purgeLocalData(for userId: UUID) {
        deleteAll(CoachingProfile.self, predicate: #Predicate { $0.id == userId })
        deleteAll(CoachingSportProfile.self, predicate: #Predicate { $0.userId == userId })
        deleteAll(AdaptedProgramRecord.self, predicate: #Predicate { $0.userId == userId })
        deleteAll(WeeklyExecutionReportRecord.self, predicate: #Predicate { $0.userId == userId })
        // Ghost row locale : `softDelete` (CoreProfileRepository, [COPIE IDENTIQUE])
        // ne fait que flagger `isSoftDeleted` — on supprime physiquement en local
        // ici, sans toucher au comportement partagé de `softDelete` lui-même.
        deleteAll(SageCoreProfile.self, predicate: #Predicate { $0.id == userId })

        do {
            try modelContext.save()
        } catch {
            Self.logger.error("purgeLocalData: modelContext.save failed for user \(userId): \(error)")
        }

        purgeRegenJournal(for: userId)
        purgeUserDefaults(for: userId)
    }

    private func deleteAll<T: PersistentModel>(_ type: T.Type, predicate: Predicate<T>) {
        do {
            let matches = try modelContext.fetch(FetchDescriptor<T>(predicate: predicate))
            for match in matches {
                modelContext.delete(match)
            }
        } catch {
            Self.logger.error("purgeLocalData: fetch/delete \(String(describing: T.self)) failed: \(error)")
        }
    }

    private func purgeRegenJournal(for userId: UUID) {
        do {
            let remaining = try journalStore.loadAll().filter { $0.userId != userId }
            try journalStore.saveAll(remaining)
        } catch {
            Self.logger.error("purgeLocalData: regen journal purge failed for user \(userId): \(error)")
        }
    }

    private func purgeUserDefaults(for userId: UUID) {
        Self.globalPreferenceKeys.forEach { userDefaults.removeObject(forKey: $0) }

        // Clés scopées par userId mais à ratisser explicitement (questionnaire
        // sport en attente) : "pending_questionnaire_<userId>_<sportCode>".
        let prefix = "pending_questionnaire_\(userId.uuidString)_"
        let scopedKeys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(prefix) }
        scopedKeys.forEach { userDefaults.removeObject(forKey: $0) }
    }
}
