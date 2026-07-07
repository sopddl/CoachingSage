// Coaching/Leon/LeonIntentService.swift
// Onboarding programme « fil de Léon » — INC2 (moteur NL), phase 1 : le CONTRAT.
//
// Interprétation du texte libre de l'user → restitution + routage ✓/⏳/🚫 + slots.
// Le contrat est partagé avec le backend (edge function `sage-coaching-ai` mode
// `onboarding-intent`, phase 2). En phase 1 seul le STUB honnête existe (aucune
// classification MDR locale — un classifieur on-device serait MDR-risqué, cf party).
//
// MDR (party 2026-06-23) : le 🚫 couvre 2 familles — (1) objectif de résultat
// santé/poids chiffré-daté ou intensité dangereuse ; (2) blessure/douleur/
// pathologie/rééducation. Léon mappe vers le sûr, NE diagnostique PAS, NE compose
// JAMAIS un programme à visée thérapeutique. Jamais d'allégation de bénéfice santé.
import Foundation

/// Route décidée par Léon pour une demande.
enum LeonIntentRoute: String, Codable, Equatable {
    /// ✓ dans le périmètre — Léon compose.
    case supported
    /// ⏳ pas encore géré (→ backlog `leon_unmet_requests`).
    case notYet = "not_yet"
    /// 🚫 refus sécurité MDR (→ backlog + orientation).
    case refusedSafety = "refused_safety"
}

/// Famille du 🚫 (précise le registre de la réponse MDR). Nil hors refus sécurité.
enum LeonRefusalFamily: String, Codable, Equatable {
    /// Famille 1 : objectif de résultat risqué (poids chiffré-daté, intensité dangereuse, promesse médicale).
    case riskyGoal = "risky_goal"
    /// Famille 2 : blessure / douleur / pathologie / rééducation → orienter vers un pro de santé.
    case healthCondition = "health_condition"
}

/// Slots extraits de la demande, applicables au profil (aperçu vivant). Tous optionnels :
/// Léon n'extrait que ce qu'il comprend avec confiance.
struct LeonIntentSlots: Codable, Equatable {
    /// Sport(s) reconnu(s) (rawValue SportCode). Le 1ᵉʳ amorce la proposition (V1 mono-sport).
    var sportCodes: [String]?
    /// Rythme = séances/semaine si l'user l'exprime.
    var frequencyPerWeek: Int?
}

/// Une intention restituée par Léon pour un fragment de demande.
struct LeonIntent: Codable, Equatable {
    let route: LeonIntentRoute
    /// Phrase de restitution mot-à-mot de Léon (déjà localisée par le backend selon la locale).
    let restitution: String
    /// Catégorie pour le backlog (toujours présente si route ≠ supported ; sinon ignorée).
    let category: LeonUnmetCategory?
    /// Famille du refus (seulement si route == refusedSafety).
    let refusalFamily: LeonRefusalFamily?
    let slots: LeonIntentSlots?
}

struct LeonIntentRequest: Codable, Equatable {
    /// Texte libre de l'user (demande initiale ou relance).
    let text: String
    /// Sports déclarés de l'user (rawValues) — aide le mapping (« le matin » sur son sport courant).
    let activeSports: [String]
    /// Sport déjà sélectionné dans le carrousel, s'il y en a un.
    let selectedSport: String?
    let locale: String
}

/// Réponse : 1+ intentions (une demande peut mêler ✓ + ⏳ + 🚫, ex. « vélo + course + perdre 5 kg »).
struct LeonIntentResponse: Codable, Equatable {
    let intents: [LeonIntent]
}

protocol LeonIntentService: Sendable {
    /// Interprète une demande en langage naturel. Throws en cas d'indisponibilité —
    /// le caller doit dégrader proprement (le fil reste utilisable au carrousel).
    func interpret(_ request: LeonIntentRequest) async throws -> LeonIntentResponse
}

/// Phase 1 — STUB honnête : N'INTERPRÈTE PAS (aucune classification MDR locale). Renvoie
/// systématiquement une intention ⏳ « je note, je ne sais pas encore lire le texte libre »
/// → le backend (phase 2) le remplace. Permet de câbler + tester le fil sans backend.
struct StubLeonIntentService: LeonIntentService {
    /// Clé i18n de la restitution d'attente (résolue côté UI).
    static let pendingRestitutionKey = "programme.fil.leon.holding"

    func interpret(_ request: LeonIntentRequest) async throws -> LeonIntentResponse {
        LeonIntentResponse(intents: [
            LeonIntent(
                route: .notYet,
                restitution: Self.pendingRestitutionKey,
                category: .unknown,
                refusalFamily: nil,
                slots: nil
            )
        ])
    }
}
