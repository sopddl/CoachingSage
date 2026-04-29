// Coaching/Questionnaires/QuestionnaireTypes.swift
// Story 3.1 — types support pour les questionnaires sportifs locaux.
// ⚠️ textKey: String partout (PAS LocalizedStringKey — review P0-1).
// La résolution UI se fait via Text(LocalizedStringKey(question.textKey)) côté View.
// Single source of truth = la clé String brute. Réutilisée pour : affichage, sérialisation audit, analytics.
import Foundation

typealias QuestionId = String

/// Représente une question affichée à l'utilisateur dans le flow chat.
struct QuestionnaireQuestion: Equatable, Identifiable {
    let id: QuestionId
    let textKey: String                     // ex: "questionnaire.running.q1.text"
    let answerType: AnswerType
    let options: [QuestionOption]           // vide si freeText

    var idValue: QuestionId { id }
}

enum AnswerType: Equatable {
    case singleChoice
    case multiChoice
    case freeText
}

/// Une option de réponse pour singleChoice / multiChoice.
struct QuestionOption: Equatable, Identifiable {
    let code: String                        // ex: "beginner", "knee" — sérialisé en DB
    let labelKey: String                    // ex: "questionnaire.running.q1.option.beginner"

    var id: String { code }
}

/// Valeur d'une réponse — version interne au moteur (≠ AnswerValueDTO Codable côté DB).
enum AnswerValue: Equatable {
    case single(String)                     // code de l'option choisie
    case multi([String])                    // codes des options choisies (peut contenir ["none"] explicit)
    case text(String?)                      // texte libre, nil si skippé
}

extension AnswerValue {
    /// Conversion vers AnswerValueDTO pour la sérialisation `conversation_history_json`.
    var asDTO: AnswerValueDTO {
        switch self {
        case .single(let s): return .single(s)
        case .multi(let arr): return .multi(arr)
        case .text(let s): return .text(s)
        }
    }

    /// Conversion depuis AnswerValueDTO pour reconstruire l'état au resume du brouillon.
    init(dto: AnswerValueDTO) {
        switch dto {
        case .single(let s): self = .single(s)
        case .multi(let arr): self = .multi(arr)
        case .text(let s): self = .text(s)
        }
    }
}
