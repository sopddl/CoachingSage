// Coaching/Session/ChargeGuidance.swift
// Chantier charge muscu V2 — party 2026-06-08 (`party-charge-muscu-v2-2026-06-08.md`).
// D-A : indication de charge = consigne « reps en réserve » + badge type de résistance.
// D-C : poids du corps → consigne progression reps/variante (pas de bloc charge chiffré).
// D-F : affichée en Manuel ET Minuté, même wording. RÈGLE ABSOLUE : JAMAIS de kg ni de
// nombre en kilos (décision Sophie 2026-06-08). EU MDR : on guide, on n'ordonne pas.
//
// TRANCHE 1 = lecture seule (classification + wording). Le niveau relatif persisté et
// l'apprentissage arrivent en T2/T5 ; ici la consigne est la même pour tous au départ.
import Foundation

/// Type de résistance d'un exercice muscu — pilote le wording de la consigne charge.
public enum ChargeResistance: Equatable, Sendable {
    case band            // élastique : badge faible / moyen / fort pertinent
    case freeOrMachine   // haltère / barre / kettlebell / machine / poulie
    case bodyweight      // poids du corps : progression reps / variante, pas de « charge »
}

public enum ChargeGuidance {

    /// Classifie un exo pour décider de la consigne charge. `nil` = pas de bloc charge
    /// (exo non-muscu, ou cas vide → on n'affiche jamais « 0 kg », règle P0).
    /// Heuristique mots-clés (raffinée en T4 via catalogue poids-du-corps).
    public static func resistance(for exercise: AdaptedExercise,
                                  isStrength: Bool) -> ChargeResistance? {
        guard isStrength else { return nil }
        let name = exercise.originalName.lowercased()

        // 1) Élastique explicite (repère universel, honnête sans kg).
        let bandKeys = ["élastique", "elastique", "band", "bande", "résistance élastique"]
        if bandKeys.contains(where: { name.contains($0) }) { return .band }

        // 2) Charge externe explicite → free/machine (prioritaire sur poids du corps :
        //    « squat barre », « fente haltères » sont chargés malgré le mot du geste).
        let loadedKeys = ["haltère", "haltere", "dumbbell", "barre", "barbell", "kettlebell",
                          "kb ", "machine", "poulie", "câble", "cable", "lesté", "leste",
                          "weighted", "goblet", "smith"]
        if loadedKeys.contains(where: { name.contains($0) }) { return .freeOrMachine }

        // 3) Poids du corps : gestes classiques sans charge externe.
        let bodyweightKeys = ["pompe", "push-up", "push up", "traction", "pull-up", "pull up",
                              "dips", "gainage", "planche", "plank", "burpee", "mountain climber",
                              "jumping", "pont fessier", "glute bridge", "bird dog", "bird-dog",
                              "dead bug", "deadbug", "crunch", "relevé de jambe", "leg raise",
                              "chaise", "wall sit", "superman", "hollow"]
        if bodyweightKeys.contains(where: { name.contains($0) }) { return .bodyweight }

        // 4) Par défaut en muscu : charge libre/machine (la consigne reps-en-réserve
        //    reste valable et n'impose aucun kg).
        return .freeOrMachine
    }
}
