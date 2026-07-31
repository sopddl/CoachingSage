// Services/AccountService.swift
// [COPIE IDENTIQUE — synchroniser avec GardenSage] (variante V1 simplifiée : pas de repos plants/tasks/garden)
// Story 1.4 — suppression de compte RGPD Art. 17.
// Pattern ceinture-bretelles côté serveur : softDelete (trace de sécu) → edge function (hard-delete immédiat).
// signOut côté client : orchestré par AccountViewModel APRÈS la transition .success
// (évite la race authStateChanges → démontage VM avant set .success).
//
// Étape 3 (purge locale, ajoutée 2026-07-31) : la purge SwiftData/UserDefaults
// locale se fait ICI, dans le service, PAS dans le ViewModel après signOut.
// Raison : `deleteAccountState = .success` est posé dans le ViewModel avant
// signOut (best-effort) — si l'app est fermée/tuée dans cette fenêtre, signOut
// peut ne jamais s'exécuter. En purgeant AVANT tout retour de `deleteAccount()`
// (donc avant que le ViewModel ne puisse même poser .success), on garantit que
// même dans ce pire cas, le `CoachingProfile` local est déjà parti au prochain
// lancement → le gate d'onboarding ne peut plus trouver un profil "onboardé"
// fantôme d'un compte qui n'existe plus côté serveur.
import Foundation
import os
import SageCore

// MARK: - Protocol

protocol AccountServiceProtocol {
    /// Supprime le compte côté serveur (soft-delete + hard-delete edge function) PUIS purge
    /// l'état local (SwiftData spécifique CoachingSage, journal regen, UserDefaults).
    /// **Ne fait PAS signOut** : le caller (ViewModel) déclenche signOut après avoir mis l'état UI à .success.
    /// RGPD Art. 17 — hard-delete immédiat ; filet pg_cron 30j si l'edge function échoue.
    func deleteAccount() async throws
}

// MARK: - Implémentation

final class AccountService: AccountServiceProtocol {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "service")
    private let coreProfileRepository: any CoreProfileRepository
    private let dataPurger: any AccountDataPurging
    private let deleteAuthUserOverride: (@Sendable () async throws -> Void)?

    init(
        coreProfileRepository: any CoreProfileRepository,
        dataPurger: any AccountDataPurging,
        deleteAuthUser: (@Sendable () async throws -> Void)? = nil
    ) {
        self.coreProfileRepository = coreProfileRepository
        self.dataPurger = dataPurger
        self.deleteAuthUserOverride = deleteAuthUser
    }

    func deleteAccount() async throws {
        var deletedUserId: UUID?

        // 1. Soft-delete profil (SwiftData + Supabase). Throws si la trace de sécu rate.
        if let profile = try await coreProfileRepository.fetchCurrentProfile() {
            deletedUserId = profile.id
            try await coreProfileRepository.softDelete(profile)
        }
        // (Si pas de profil local, on tente quand même l'étape 2 : le user a un JWT valide.)

        // 2. Hard-delete via edge function (throws sur HTTP≠200 — pas de swallow).
        if let override = deleteAuthUserOverride {
            try await override()
        } else {
            try await deleteAuthUser()
        }

        // 3. Purge locale — uniquement si les étapes 1+2 ont réussi (cf. header).
        if let deletedUserId {
            await dataPurger.purgeLocalData(for: deletedUserId)
        }
    }

    /// Appelle l'edge function `delete-account` (POST avec JWT). Throw si HTTP ≠ 200.
    private func deleteAuthUser() async throws {
        guard ProcessInfo.processInfo.environment["IS_UI_TESTING"] == nil else { return }

        let session = try await SupabaseService.shared.client.auth.session
        let jwt = session.accessToken

        guard let host = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_HOST") as? String,
              let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
              let url = URL(string: "https://\(host)/functions/v1/delete-account") else {
            throw AppError.sync("delete-account: configuration Supabase manquante")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        // Pas de body : l'edge function lit le user.id depuis le JWT (cf. spec Task 2.7).

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

        if statusCode == 200 {
            #if DEBUG
            let body = String(data: data, encoding: .utf8) ?? ""
            Self.logger.debug("delete-account succeeded: \(body)")
            #endif
            return
        }

        #if DEBUG
        let body = String(data: data, encoding: .utf8) ?? ""
        Self.logger.warning("delete-account HTTP \(statusCode): \(body)")
        #endif
        throw AppError.sync("delete-account HTTP \(statusCode)")
    }
}
