// Coaching/Session/SessionTipCatalog.swift
// Story 3.19 Jalon 3 — catalogue 1 tip Léon court par pattern biomécanique.
// Algo deterministic (pas IA), 1 tip × 2 langues × 18 patterns = 36 strings xcstrings.
//
// Garde-fous EU MDR (cf `epic3_leon_legal_constraints.md`) :
// - aucun "tu dois", "il faut" prescriptif → tips reformulés en suggestion ("vise…", "concentre-toi sur…", "atterrissage moelleux…")
// - pas de prescription médicale (douleur, blessure, articulation = OK contexte technique uniquement)
// - tips P1 review Plan reformulés sur la doctrine publique :
//   Israetel (strength), Daniels (run), Maglischo (swim), Friel (cycling).
//
// Source des keys : `Resources/Localizable.xcstrings` (cf AC19, 18 keys × 2 langues).
import Foundation
import SwiftUI

public enum SessionTipCatalog {

    /// Renvoie une LocalizedStringKey courte (≤ 200 chars FR) pour le pattern.
    /// `.generic` → `nil` (pas de tip, on n'affiche pas la bubble).
    ///
    /// `exerciseName` est passé pour permettre, plus tard, une variante par
    /// sous-pose yoga ou drill swim spécifique (V2). En V1, le tip dépend
    /// uniquement du pattern enum.
    public static func tip(for pattern: ExercisePattern, exerciseName: String) -> LocalizedStringKey? {
        switch pattern {
        case .squat:
            return "coaching.tip.squat"
        case .hinge:
            return "coaching.tip.hinge"
        case .pushHorizontal:
            return "coaching.tip.push.horizontal"
        case .pushVertical:
            return "coaching.tip.push.vertical"
        case .pullHorizontal:
            return "coaching.tip.pull.horizontal"
        case .pullVertical:
            return "coaching.tip.pull.vertical"
        case .lunge:
            return "coaching.tip.lunge"
        case .core:
            return "coaching.tip.core"
        case .plyo:
            return "coaching.tip.plyo"
        case .mobility:
            return "coaching.tip.mobility"
        // Story 3.23 Tier 1 Jalon 2
        case .hipThrust:
            return "coaching.tip.hipThrust"
        case .calfRaise:
            return "coaching.tip.calfRaise"
        // Story 3.23 Lot 3 — patterns haute fréquence
        case .forearmPlank:
            return "coaching.tip.forearmPlank"
        case .ytwActivation:
            return "coaching.tip.ytwActivation"
        case .pallofPress:
            return "coaching.tip.pallofPress"
        case .nordicCurl:
            return "coaching.tip.nordicCurl"
        case .birdDog:
            return "coaching.tip.birdDog"
        // Story 3.23 Lot 5 — patterns moyenne fréquence
        case .deadBug:
            return "coaching.tip.deadBug"
        case .clamshell:
            return "coaching.tip.clamshell"
        case .kbSwing:
            return "coaching.tip.kbSwing"
        case .facePull:
            return "coaching.tip.facePull"
        case .foamRolling:
            return "coaching.tip.foamRolling"
        case .bicepsCurl:
            return "coaching.tip.bicepsCurl"
        // Story 3.23 Lot 7 — patterns reste
        case .tricepsPushdown:
            return "coaching.tip.tricepsPushdown"
        case .lateralRaises:
            return "coaching.tip.lateralRaises"
        case .runEndurance:
            return "coaching.tip.run.endurance"
        case .runInterval:
            return "coaching.tip.run.interval"
        case .runDrills:
            return "coaching.tip.run.drills"
        case .swimEndurance:
            return "coaching.tip.swim.endurance"
        case .swimDrill:
            return "coaching.tip.swim.drill"
        case .cycleEndurance:
            return "coaching.tip.cycle.endurance"
        case .cycleInterval:
            return "coaching.tip.cycle.interval"
        case .yoga:
            return "coaching.tip.yoga"
        case .generic:
            return nil
        }
    }
}
