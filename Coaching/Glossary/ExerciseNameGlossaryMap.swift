// Coaching/Glossary/ExerciseNameGlossaryMap.swift
// Story 3.26 Phase B-bis — mapping explicite nom-exo → glossary id, pour les
// exercices dont le nom NE contient PAS un terme déjà matché par GlossaryMatcher.
//
// Exemple : "Tadasana" ne contient pas "asana" comme mot indépendant, mais doit
// renvoyer vers yoga.asana pour donner un repère pédagogique au débutant.
//
// Le matcher d'exos exposé via `Glossary.entry(forExerciseName:sportCode:)`
// procède en cascade :
//   1. Match exact (lowercase) dans la table d'overrides → entry direct.
//   2. Fallback `Glossary.matches(in: name)` → 1er terme matché s'il existe.
//   3. Fallback générique selon `sportCode` (yoga → yoga.asana, swimming → en,
//      etc.) si rien d'autre — utile pour l'UI qui veut afficher l'icône info
//      même sur un exo techniquement opaque.
import Foundation

extension Glossary {

    /// Overrides : nom d'exo canonique (lowercase) → id glossaire.
    /// Liste seed couvrant les exos opaques les plus fréquents des templates v2.
    /// À étendre quand l'usage produit révèle d'autres patterns.
    nonisolated(unsafe) static let exerciseNameOverrides: [String: String] = [
        // Yoga — asanas sanskrit fréquents (renvoient au terme générique yoga.asana).
        "tadasana": "yoga.asana",
        "adho mukha svanasana": "yoga.asana",
        "anjaneyasana": "yoga.asana",
        "uttanasana": "yoga.asana",
        "virabhadrasana": "yoga.asana",
        "utkatasana": "yoga.asana",
        "trikonasana": "yoga.asana",
        "bhujangasana": "yoga.asana",
        "balasana": "yoga.asana",
        "padmasana": "yoga.asana",
        "downward dog": "yoga.asana",
        "downward-facing dog": "yoga.asana",
        "child's pose": "yoga.asana",
        "warrior i": "yoga.asana",
        "warrior ii": "yoga.asana",
        "warrior iii": "yoga.asana",
        "triangle pose": "yoga.asana",
        "cobra pose": "yoga.asana",
        "sphinx pose": "yoga.asana",
        "chair pose": "yoga.asana",
        "mountain pose": "yoga.asana",
        "lotus pose": "yoga.asana",
        "tree pose": "yoga.asana",
        // Strength — exos obscurs pour un débutant.
        "bird dog": "reps",
        "bird-dog": "reps",
        "dead bug": "reps",
        "good morning": "rampup",
        // Tennis / Football — drills nommés.
        "shadow drill": "drill",
        "shuttle run": "drill",
        "ladder drill": "drill",
        // Triathlon
        "brick run": "triathlon.brick",
        "transition drill": "triathlon.t1",
    ]

    /// Fallback générique : si rien d'autre, on renvoie au terme universel du sport.
    /// Utile pour donner un repère sur les exos sans terme spécifique reconnaissable.
    private static func fallbackEntryId(forSportCode sportCode: String) -> String? {
        switch sportCode {
        case Sport.yoga:             return "yoga.asana"
        case Sport.swimming:         return "en"
        case Sport.cycling:          return "ftp"
        case Sport.running:          return "race.pace"
        case Sport.hiking:           return "hiking.terrainpace"
        case Sport.strengthTraining: return "reps"
        case Sport.hiit:             return "hiit.workrest"
        case Sport.triathlon:        return "triathlon.brick"
        case Sport.tennis:           return "tennis.footwork"
        case Sport.football:         return "football.transition"
        default:                     return nil
        }
    }

    /// Cherche une entrée de glossaire pertinente pour un nom d'exo.
    ///
    /// - Parameters:
    ///   - name: nom de l'exercice (ex "Adho Mukha Svanasana", "Squat barre").
    ///   - sportCode: code sport du contexte (optionnel). Active le fallback générique.
    ///   - useFallback: si `true`, retourne un terme générique sport quand rien
    ///     n'est trouvé. UI peut décider d'afficher ou non l'icône info dans ce cas.
    /// - Returns: l'entrée glossaire la plus pertinente, ou nil.
    public static func entry(forExerciseName name: String,
                             sportCode: String? = nil,
                             useFallback: Bool = false) -> GlossaryEntry? {
        let lower = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lower.isEmpty else { return nil }

        // 1. Override exact.
        if let id = exerciseNameOverrides[lower],
           let entry = entries.first(where: { $0.id == id }) {
            return entry
        }

        // 2. Match texte dans le nom (réutilise le matcher inline).
        if let firstMatch = matches(in: name).first {
            return firstMatch.entry
        }

        // 3. Fallback sport-générique si demandé.
        if useFallback, let sportCode,
           let fallbackId = fallbackEntryId(forSportCode: sportCode),
           let entry = entries.first(where: { $0.id == fallbackId }) {
            return entry
        }

        return nil
    }
}
