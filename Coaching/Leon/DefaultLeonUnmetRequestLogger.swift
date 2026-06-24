// Coaching/Leon/DefaultLeonUnmetRequestLogger.swift
// Fil de Léon inc2 phase 2 — écriture du backlog `leon_unmet_requests` (Supabase).
//
// GATED CONSENTEMENT (RGPD) : n'insère QUE si l'user a accordé le consentement
// analytics (core_profiles.analytics_consent). Fail-CLOSED : en cas de doute /
// erreur de lecture du consentement → on n'écrit pas. Best-effort : un échec
// d'insert ne remonte jamais au caller (le fil reste fluide).
//
// Contrat RGPD : enums fermés uniquement, aucun verbatim, pas de program_id
// (cf migration 009 + LeonUnmetRequestLogger.swift).
import Foundation
import os

final class DefaultLeonUnmetRequestLogger: LeonUnmetRequestLogger {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "leon-backlog")

    func log(_ request: LeonUnmetRequest) async {
        guard ProcessInfo.processInfo.environment["IS_UI_TESTING"] == nil else { return }
        guard let userId = SupabaseService.shared.client.auth.currentSession?.user.id else { return }

        // Gate consentement analytics (fail-closed).
        guard await hasAnalyticsConsent(userId: userId) else {
            #if DEBUG
            Self.logger.debug("leon_unmet_requests skipped: analytics consent absent/unknown")
            #endif
            return
        }

        let dto = LeonUnmetRequestInsertDTO(
            user_id: userId.uuidString.lowercased(),
            category: request.category.rawValue,
            response: request.response.rawValue,
            locale: request.locale,
            app_version: request.appVersion
        )
        do {
            try await SupabaseService.shared.client
                .from("leon_unmet_requests")
                .insert(dto)
                .execute()
        } catch {
            Self.logger.error("insert leon_unmet_requests failed: \(error.localizedDescription)")
        }
    }

    private func hasAnalyticsConsent(userId: UUID) async -> Bool {
        do {
            let response = try await SupabaseService.shared.client
                .from("core_profiles")
                .select("analytics_consent")
                .eq("id", value: userId.uuidString)
                .limit(1)
                .execute()
            struct Row: Decodable { let analytics_consent: Bool? }
            let rows = try JSONDecoder.supabase().decode([Row].self, from: response.data)
            return rows.first?.analytics_consent ?? false
        } catch {
            return false // fail-closed : pas de consentement prouvé → pas d'écriture
        }
    }
}

private struct LeonUnmetRequestInsertDTO: Encodable {
    let user_id: String
    let category: String
    let response: String
    let locale: String
    let app_version: String
}
