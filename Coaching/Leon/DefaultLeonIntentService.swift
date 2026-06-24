// Coaching/Leon/DefaultLeonIntentService.swift
// Fil de Léon inc2 phase 2 — implémentation réseau de LeonIntentService.
// Appelle l'edge function `sage-coaching-ai?mode=onboarding-intent` (pattern
// URLSession direct + JWT, cf DefaultSageCoachingAIService). Décode le
// `LeonIntentResponse` (clés camelCase = noms de propriété Swift).
import Foundation
import os

final class DefaultLeonIntentService: LeonIntentService {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "leon-intent")
    private let session: URLSession
    private let timeoutSeconds: TimeInterval

    init(session: URLSession = .shared, timeoutSeconds: TimeInterval = 35) {
        self.session = session
        self.timeoutSeconds = timeoutSeconds
    }

    func interpret(_ request: LeonIntentRequest) async throws -> LeonIntentResponse {
        let authSession = try await SupabaseService.shared.client.auth.session
        let jwt = authSession.accessToken

        guard let host = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_HOST") as? String,
              let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
              let url = URL(string: "https://\(host)/functions/v1/sage-coaching-ai") else {
            throw LeonError.network("Supabase configuration introuvable")
        }

        // Body en snake_case attendu par l'edge function.
        let root: [String: Any] = [
            "mode": "onboarding-intent",
            "text": request.text,
            "active_sports": request.activeSports,
            "selected_sport": request.selectedSport as Any? ?? NSNull(),
            "locale": request.locale,
        ]
        let body = try JSONSerialization.data(withJSONObject: root, options: [])

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = timeoutSeconds
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
        urlRequest.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = body

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw LeonError.network(error.localizedDescription)
        }

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        if statusCode == 200 {
            do {
                return try JSONDecoder().decode(LeonIntentResponse.self, from: data)
            } catch {
                Self.logger.error("Failed to decode LeonIntentResponse: \(error.localizedDescription)")
                throw LeonError.invalidPatch
            }
        }

        // Réutilise le mapping d'erreurs structuré de l'autre service Léon.
        throw DefaultSageCoachingAIService.mapErrorResponse(data: data, statusCode: statusCode)
    }
}
