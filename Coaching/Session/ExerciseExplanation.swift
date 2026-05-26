// Coaching/Session/ExerciseExplanation.swift
// Story 3.24b — contrat de données "comment exécuter un exo".
//
// Consommé par `ExerciseTimelineCard` (disclosure UI) et par `GuidedWorkoutView`
// (Story 3.22 Sujet D / 3.25). Tout passe par String localisé au moment du fetch
// (param `language`) pour rester Codable (cache disque) et indépendant du bundle
// SwiftUI courant.
//
// Provenance possible (cf `ExerciseExplanationServiceProtocol`) :
//  - seed catalogue manuel (top 10 exos universels strength) → langue résolue
//    via le dictionnaire bilingue en code Swift.
//  - cache disque (Application Support/ExerciseExplanations/<lang>/<sha>.json)
//    après un hit Léon précédent.
//  - fetch Léon on-demand (V2 — V1 throw .unavailable et l'UI fallback sur tip).
import Foundation

public struct ExerciseExplanation: Codable, Equatable, Sendable {
    /// 3 à 5 étapes courtes d'exécution. Style action concrète à la 2ème personne
    /// neutre ("vise…", "place-toi…", "garde…"), pas de prescription médicale.
    public let steps: [String]

    /// Liste plate d'équipement nécessaire (chip UI). Ex: ["Barre", "Banc plat"].
    public let equipment: [String]

    /// 1 erreur courante à éviter (optionnel). Phrase action ≤ 1 phrase.
    public let commonMistakes: String?

    public init(steps: [String], equipment: [String], commonMistakes: String? = nil) {
        self.steps = steps
        self.equipment = equipment
        self.commonMistakes = commonMistakes
    }
}

/// Erreurs remontées par `ExerciseExplanationServiceProtocol`. Le caller UI doit
/// fallback gracieusement sur `SessionTipCatalog` (tip pattern) — zéro régression.
public enum ExerciseExplanationError: Error, Equatable, Sendable {
    /// Pas de seed pour cet exo ET pas d'IA dispo (V1) OU IA throw .unavailable.
    case notAvailable

    /// Langue non supportée (V1 = "fr" et "en" uniquement).
    case unsupportedLanguage(String)
}

public protocol ExerciseExplanationServiceProtocol: Sendable {
    /// Renvoie une explication d'exécution pour `exercise` dans `language`
    /// ("fr" | "en"). Flux d'éval (cf Story 3.24b AC-b1) :
    ///  1. Seed catalogue manuel (immédiat, zéro latence).
    ///  2. Cache disque (Application Support).
    ///  3. Fetch Léon IA on-demand + cache (V2).
    ///  4. Sinon `throw .notAvailable` → caller fallback tip pattern.
    func explanation(
        for exercise: AdaptedExercise,
        language: String
    ) async throws -> ExerciseExplanation
}
