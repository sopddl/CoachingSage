// Services/AccountService.swift
// [COPIE IDENTIQUE — synchroniser avec GardenSage] (variante V1 simplifiée : pas de repos plants/tasks/garden)
// Story 1.4 — suppression de compte RGPD Art. 17.
// Pattern ceinture-bretelles côté serveur : softDelete (trace de sécu) → edge function (hard-delete immédiat).
// signOut côté client : orchestré par AccountViewModel APRÈS la transition .success
// (évite la race authStateChanges → démontage VM avant set .success).
import Foundation
import os
import SageCore

// MARK: - Protocol

protocol AccountServiceProtocol {
    /// Supprime le compte côté serveur : soft-delete SwiftData + Supabase, puis hard-delete via edge function.
    /// **Ne fait PAS signOut** : le caller (ViewModel) déclenche signOut après avoir mis l'état UI à .success.
    /// RGPD Art. 17 — hard-delete immédiat ; filet pg_cron 30j si l'edge function échoue.
    func deleteAccount() async throws
}

// MARK: - Implémentation

final class AccountService: AccountServiceProtocol {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "service")
    private let coreProfileRepository: any CoreProfileRepository
    private let deleteAuthUserOverride: (@Sendable () async throws -> Void)?

    init(
        coreProfileRepository: any CoreProfileRepository,
        deleteAuthUser: (@Sendable () async throws -> Void)? = nil
    ) {
        self.coreProfileRepository = coreProfileRepository
        self.deleteAuthUserOverride = deleteAuthUser
    }

    func deleteAccount() async throws {
        // 1. Soft-delete profil (SwiftData + Supabase). Throws si la trace de sécu rate.
        if let profile = try await coreProfileRepository.fetchCurrentProfile() {
            try await coreProfileRepository.softDelete(profile)
        }
        // (Si pas de profil local, on tente quand même l'étape 2 : le user a un JWT valide.)

        // 2. Hard-delete via edge function (throws sur HTTP≠200 — pas de swallow).
        if let override = deleteAuthUserOverride {
            try await override()
        } else {
            try await deleteAuthUser()
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
