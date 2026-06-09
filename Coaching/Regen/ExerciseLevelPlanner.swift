// Coaching/Regen/ExerciseLevelPlanner.swift
// Chantier charge muscu V2 — TRANCHE 5. Règle d'apprentissage PURE (miroir de
// `CycleRenewalPlanner`), 100 % testable, sans I/O. Applique D-E + V-2 + V-4 :
// - « trop dur » → −1 cran DÈS la 1ère fois (asymétrie sécurité, V-2).
// - « facile » → +1 cran seulement après 2× consécutifs (D-E).
// - « juste » → on ne bouge pas, on remet le compteur à zéro.
// - max 1 cran par appel, clamp 1...5.
// - `requiresMedicalClearance` ⇒ les HAUSSES sont bridées SILENCIEUSEMENT (V-4) ;
//   les baisses (sécurité) passent toujours.
import Foundation

public enum ExerciseLevelPlanner {

    public static func apply(_ feedback: ExerciseFeedback,
                             to current: ExerciseLevel,
                             requiresMedicalClearance: Bool = false) -> ExerciseLevel {
        switch feedback {
        case .tooHard:
            // Sécurité : on baisse tout de suite, on oublie les « facile » passés.
            return ExerciseLevel(level: current.level - 1, consecutiveEasy: 0)

        case .right:
            // Bon niveau : aucun changement, on repart à zéro côté compteur.
            return ExerciseLevel(level: current.level, consecutiveEasy: 0)

        case .easy:
            let easies = current.consecutiveEasy + 1
            guard easies >= 2 else {
                // 1er « facile » : on note, on ne monte pas encore.
                return ExerciseLevel(level: current.level, consecutiveEasy: easies)
            }
            // 2× « facile » → +1 cran, SAUF clearance médicale (bride silencieuse, V-4).
            let bumped = requiresMedicalClearance ? current.level : current.level + 1
            return ExerciseLevel(level: bumped, consecutiveEasy: 0)
        }
    }
}
