// Coaching/AI/SageCoachingAIService.swift
// Story 3.3b — appelle l'Edge Function `sage-coaching-ai?mode=adapt-rare` côté
// Supabase. Pattern URLSession direct (cf AccountService.deleteAuthUser) plutôt
// que SDK `client.functions.invoke` pour contrôle fin sur erreurs HTTP.
//
// Le payload `profile_json` doit inclure `first_name` (CoreProfile) pour activer
// la personnalisation du ton Léon (cf prompts.ts v1.1.0).
import Foundation
import os
import TemplateModel

protocol SageCoachingAIServiceProtocol: Sendable {
    /// Demande à Léon un raffinement IA d'un AdaptedProgram. Throws `LeonError`.
    /// Le programme algo-only reste utilisable même en cas de throw — le caller
    /// doit afficher l'erreur sans perdre le programme.
    func requestAdaptRare(
        triggeredReason: AdaptRareReason,
        templateJSON: Data,
        profileJSON: Data,
        healthSummary: HealthSummary,
        adaptedProgramJSON: Data
    ) async throws -> AdaptRareResponse
}

final class DefaultSageCoachingAIService: SageCoachingAIServiceProtocol {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "leon")
    private let session: URLSession
    private let timeoutSeconds: TimeInterval

    init(session: URLSession = .shared, timeoutSeconds: TimeInterval = 35) {
        // Timeout 35s = NFR1b cible 30s P90 + marge réseau. Au-delà, on remonte
        // .anthropicUnavailable et le user retombe sur le programme algo-only.
        self.session = session
        self.timeoutSeconds = timeoutSeconds
    }

    func requestAdaptRare(
        triggeredReason: AdaptRareReason,
        templateJSON: Data,
        profileJSON: Data,
        healthSummary: HealthSummary,
        adaptedProgramJSON: Data
    ) async throws -> AdaptRareResponse {
        let session = try await SupabaseService.shared.client.auth.session
        let jwt = session.accessToken

        guard let host = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_HOST") as? String,
              let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
              let url = URL(string: "https://\(host)/functions/v1/sage-coaching-ai") else {
            throw LeonError.network("Supabase configuration introuvable")
        }

        let body = try Self.encodeRequestBody(
            triggeredReason: triggeredReason,
            templateJSON: templateJSON,
            profileJSON: profileJSON,
            healthSummary: healthSummary,
            adaptedProgramJSON: adaptedProgramJSON
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeoutSeconds
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.httpBody = body

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await self.session.data(for: request)
        } catch {
            throw LeonError.network(error.localizedDescription)
        }

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

        if statusCode == 200 {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                return try decoder.decode(AdaptRareResponse.self, from: data)
            } catch {
                #if DEBUG
                // Diag temporaire (Story 3.3b post-déploiement) : print le raw
                // payload pour comprendre le mismatch decode. À retirer une fois
                // le format Edge Function aligné avec le modèle Swift.
                let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
                Self.logger.error("Failed to decode AdaptRareResponse: \(error.localizedDescription)\nRAW PAYLOAD (first 2000 chars):\n\(raw.prefix(2000))")
                #else
                Self.logger.error("Failed to decode AdaptRareResponse: \(error.localizedDescription)")
                #endif
                throw LeonError.invalidPatch
            }
        }

        // Mapping des erreurs structurées renvoyées par l'Edge Function.
        throw Self.mapErrorResponse(data: data, statusCode: statusCode)
    }

    // MARK: - Helpers

    /// Encode le body de la requête `AdaptRareRequest` (alignement 1:1 types.ts).
    /// Les JSON pré-encodés (`templateJSON`, `profileJSON`, `adaptedProgramJSON`)
    /// sont injectés en sous-objet sans re-decode pour gagner en perf et
    /// préserver l'ordre des clés.
    static func encodeRequestBody(
        triggeredReason: AdaptRareReason,
        templateJSON: Data,
        profileJSON: Data,
        healthSummary: HealthSummary,
        adaptedProgramJSON: Data
    ) throws -> Data {
        // Re-decode chaque JSON entrant pour pouvoir re-encoder l'ensemble en
        // une seule struct racine. Un peu de coût mais évite de bricoler des
        // chaînes JSON à la main (et risque d'injection).
        let templateAny = try JSONSerialization.jsonObject(with: templateJSON, options: [])
        let profileAny = try JSONSerialization.jsonObject(with: profileJSON, options: [])
        let adaptedAny = try JSONSerialization.jsonObject(with: adaptedProgramJSON, options: [])
        let healthAny = try JSONSerialization.jsonObject(
            with: try JSONEncoder().encode(healthSummary),
            options: []
        )

        let root: [String: Any] = [
            "mode": "adapt-rare",
            "triggered_reason": triggeredReason.rawValue,
            "template_json": templateAny,
            "profile_json": profileAny,
            "health_summary": healthAny,
            "adapted_program_json": adaptedAny
        ]
        return try JSONSerialization.data(withJSONObject: root, options: [])
    }

    static func mapErrorResponse(data: Data, statusCode: Int) -> LeonError {
        // Tentative de decode du payload error structuré (cf types.ts).
        struct ErrorPayload: Decodable {
            struct Inner: Decodable {
                let code: String
                let message: String
                let quotaResetsAt: String?

                enum CodingKeys: String, CodingKey {
                    case code, message
                    case quotaResetsAt = "quota_resets_at"
                }
            }
            let error: Inner
        }

        let decoder = JSONDecoder()
        if let payload = try? decoder.decode(ErrorPayload.self, from: data) {
            switch payload.error.code {
            case "quota_exceeded":
                let resetDate = payload.error.quotaResetsAt.flatMap { ISO8601DateFormatter().date(from: $0) }
                return .quotaExceeded(resetsAt: resetDate)
            case "anthropic_unavailable":
                return .anthropicUnavailable
            case "invalid_patch":
                return .invalidPatch
            case "unauthorized":
                return .unauthorized
            case "invalid_request":
                return .invalidRequest(payload.error.message)
            default:
                return .server(statusCode)
            }
        }

        // Fallback : pas de payload structuré (réseau cassé, body vide, etc.)
        if statusCode == 401 { return .unauthorized }
        if statusCode == 429 { return .quotaExceeded(resetsAt: nil) }
        return .server(statusCode)
    }
}
