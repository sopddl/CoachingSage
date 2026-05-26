// Coaching/Session/ExerciseExplanationPrompt.swift
// Story 3.24b — builder du prompt système + user pour fetch IA Léon on-demand.
//
// V1 livrable : builder déterministe + testable (audit mots bannis). PAS encore
// câblé à une Edge Function (cf `UnavailableRemoteFetcher`). Le câblage V2 (Edge
// Function `sage-exercise-explanation`) consommera cette struct telle quelle —
// pas de re-design à prévoir, contrat figé Sophie 2026-05-24.
//
// Garde-fous EU MDR (cf `epic3_leon_legal_constraints.md`) :
//  - le prompt système BANNIT toute prescription médicale + ton autoritaire
//    impératif.
//  - format réponse strict imposé (3-5 steps + équipement + 1 erreur courante).
//  - aucune mention de douleur / blessure / traitement / diagnostic.
//
// Format de sortie JSON attendu côté Léon (à parser par le fetcher V2) :
//   { "steps": ["...", ...], "equipment": ["...", ...], "commonMistakes": "..." }
import Foundation

public enum ExerciseExplanationPromptBuilder {

    /// Prompt système figé : doctrine + format + garde-fous EU MDR.
    /// Versionné en code Swift pour faciliter l'audit corpus (cf tests).
    public static let systemPromptFR: String = """
    Tu es Léon, le coach assistant de l'app CoachingSage. Tu décris comment \
    exécuter un exercice physique de façon claire et bienveillante.

    Format de sortie strict (JSON valide uniquement) :
    {
      "steps": [3 à 5 phrases courtes en français, style "place...", "vise...", "garde..."],
      "equipment": [liste plate de l'équipement nécessaire en français],
      "commonMistakes": "1 phrase identifiant une erreur courante à éviter"
    }

    Règles inviolables :
    - Pas de prescription médicale : aucun mot lié à douleur, blessure, \
      traitement, diagnostic, pathologie.
    - Pas de ton autoritaire : suggérer ("place...", "vise...") plutôt qu'ordonner \
      ("tu dois", "il faut", "obligatoirement").
    - Réponse en français uniquement.
    - JSON strict, pas de texte avant ou après.
    """

    public static let systemPromptEN: String = """
    You are Léon, the coaching assistant of the CoachingSage app. You describe \
    how to perform a physical exercise in a clear and supportive way.

    Strict output format (valid JSON only):
    {
      "steps": [3 to 5 short English sentences, style "place...", "aim for...", "keep..."],
      "equipment": [flat list of required equipment in English],
      "commonMistakes": "1 sentence identifying a common mistake to avoid"
    }

    Inviolable rules:
    - No medical prescription: no words related to pain, injury, treatment, \
      diagnosis, pathology.
    - No imperative tone: suggest ("place...", "aim for...") rather than command \
      ("you must", "you have to", "always", "never fail to").
    - Response in English only.
    - Strict JSON, no text before or after.
    """

    /// User prompt par exo : contexte minimal pour permettre à Léon de produire
    /// des steps adaptées. On envoie le nom canonique (`originalName`), pas le
    /// nom substitué runtime, pour partager le cache entre variantes.
    public static func userPrompt(for exercise: AdaptedExercise, language: String) -> String {
        let exerciseName = exercise.originalName

        switch language.lowercased() {
        case "fr":
            return "Décris comment exécuter l'exercice : \(exerciseName)."
        case "en":
            return "Describe how to perform the exercise: \(exerciseName)."
        default:
            return "Describe how to perform the exercise: \(exerciseName)."
        }
    }

    /// Renvoie le system prompt pour une langue donnée. Fallback FR.
    public static func systemPrompt(for language: String) -> String {
        switch language.lowercased() {
        case "en": return systemPromptEN
        default: return systemPromptFR
        }
    }
}
