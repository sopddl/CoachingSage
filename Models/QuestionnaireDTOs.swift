// Models/QuestionnaireDTOs.swift
// Story 3.1 — DTOs typés Codable pour les champs JSONB de coaching_sport_profiles.
// Aucun [String: Any] ni LocalizedStringKey (review P0-1, P0-2).
import Foundation

/// Payload du champ `goals_json` (Postgres JSONB).
/// V1 contient seulement `primary` (5k/10k/half_marathon/marathon/wellness).
/// Évolutif : ajouter des fields optionnels Codable, le parser ignorera les anciens.
struct GoalsPayload: Codable, Equatable {
    let primary: String
}

/// Entrée d'historique de conversation, stockée dans `conversation_history_json`.
/// Sert à : audit, debug Léon Story 3.3 (citer la conversation), monitoring questions ambigües (Story 3.7).
struct ConversationEntry: Codable, Equatable, Identifiable {
    let id: UUID
    let questionId: String
    let questionTextKey: String?
    let answer: AnswerValueDTO?
    let askedAt: Date
    let skipped: Bool
    let skipReason: String?

    init(
        id: UUID = UUID(),
        questionId: String,
        questionTextKey: String?,
        answer: AnswerValueDTO?,
        askedAt: Date,
        skipped: Bool = false,
        skipReason: String? = nil
    ) {
        self.id = id
        self.questionId = questionId
        self.questionTextKey = questionTextKey
        self.answer = answer
        self.askedAt = askedAt
        self.skipped = skipped
        self.skipReason = skipReason
    }
}

/// Valeur de réponse, sérialisable Codable (review P0-2 — pas [String: Any]).
enum AnswerValueDTO: Codable, Equatable {
    case single(String)
    case multi([String])
    case text(String?)

    private enum CodingKeys: String, CodingKey {
        case type, value
    }

    private enum AnswerType: String, Codable {
        case single, multi, text
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .single(let s):
            try container.encode(AnswerType.single, forKey: .type)
            try container.encode(s, forKey: .value)
        case .multi(let arr):
            try container.encode(AnswerType.multi, forKey: .type)
            try container.encode(arr, forKey: .value)
        case .text(let s):
            try container.encode(AnswerType.text, forKey: .type)
            try container.encodeIfPresent(s, forKey: .value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(AnswerType.self, forKey: .type)
        switch type {
        case .single:
            self = .single(try container.decode(String.self, forKey: .value))
        case .multi:
            self = .multi(try container.decode([String].self, forKey: .value))
        case .text:
            self = .text(try container.decodeIfPresent(String.self, forKey: .value))
        }
    }
}
