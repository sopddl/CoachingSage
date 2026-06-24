// Coaching/Leon/LeonUnmetRequestLogger.swift
// Onboarding programme « fil de Léon » — backlog des demandes non satisfaites.
//
// Contrat RGPD STRICT (party onboarding 2026-06-23, lentille MDR/RGPD) :
//   - AUCUN champ texte libre (pas de raw_text / verbatim / note) — uniquement
//     des enums fermés + timestamp.
//   - Mapping LLM raté → `category = .unknown`, SANS verbatim de repli.
//   - Catégorie ≠ verbatim santé (« perdre 5 kg » → `.weightLoss`, jamais le texte).
//   - Pseudonymisation : on ne lie JAMAIS à `program_id` (art. 9 — `weightLoss`
//     + program_id ré-identifierait un objectif santé).
//
// **Inc1** : seul le CONTRAT est posé + une implémentation NO-OP. L'interprétation
// (classification ✓/⏳/🚫 + `category`) et l'écriture réelle dans la table Supabase
// `leon_unmet_requests` (avec consentement analytics + finalité nommée + rétention
// bornée) arrivent à l'inc NL. En inc1 la demande libre de l'user est seulement
// CAPTURÉE dans `CoachingSportProfile.freeTextNotes` (sa propre donnée, ≠ backlog
// analytics) — elle n'est PAS interprétée et rien n'est loggé côté backlog.
import Foundation
import os

/// Catégorie de la demande, mappée par Léon (inc NL). Enum fermé : intriable côté
/// produit (`group by category order by count desc`), jamais de verbatim santé.
enum LeonUnmetCategory: String, Codable, CaseIterable {
    case periodisationTemporelle = "periodisation_temporelle"
    case multiSportCombine = "multi_sport_combine"
    case nutrition
    case weightLoss = "weight_loss"
    case healthCondition = "health_condition"
    case unknown
}

/// Type de réponse de Léon à une demande hors périmètre.
enum LeonUnmetResponse: String, Codable {
    /// ⏳ « pas encore » — fonctionnalité non gérée aujourd'hui (backlog priorisable).
    case notYet = "not_yet"
    /// 🚫 refus sécurité MDR (objectif risqué / pathologie / blessure).
    case refusedSafety = "refused_safety"
}

/// Une entrée de backlog. Enums fermés uniquement (cf. contrat RGPD ci-dessus).
struct LeonUnmetRequest: Codable, Equatable {
    let category: LeonUnmetCategory
    let response: LeonUnmetResponse
    let locale: String
    let appVersion: String
}

protocol LeonUnmetRequestLogger {
    /// Enregistre une demande non satisfaite dans le backlog. No-op tant que le
    /// consentement analytics n'est pas accordé (à câbler inc NL).
    func log(_ request: LeonUnmetRequest) async
}

/// Implémentation NO-OP de l'inc1 : trace en debug local, n'écrit rien côté
/// backend. Remplacée par l'implémentation Supabase (gated consentement) à l'inc NL.
struct NoopLeonUnmetRequestLogger: LeonUnmetRequestLogger {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "leon-backlog")

    func log(_ request: LeonUnmetRequest) async {
        #if DEBUG
        Self.logger.debug("leon_unmet_requests (no-op inc1): category=\(request.category.rawValue) response=\(request.response.rawValue)")
        #endif
    }
}
