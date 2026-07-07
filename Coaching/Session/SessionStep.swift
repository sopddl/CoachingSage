// Coaching/Session/SessionStep.swift
// Story 3.33 (FOCUS) — modèle d'étape d'exécution d'une séance, dérivé d'une
// `AdaptedSession`. Façon `ProjectStep` (TailorSage) mais STRUCTURE PURE, zéro
// SwiftData (la complétion est persistée séparément en JSON plat via
// `SessionProgressStore`, cf Décision 6 P0.3).
//
// Ordre de référence = warmup (si présent) → exos → cooldown (si présent),
// IDENTIQUE à `SessionTimelineView` / `SessionOverviewList` → l'`index` est aussi
// la cible d'ancrage `SessionStepAnchor`.
import Foundation
import TemplateModel

enum SessionStepKind: Equatable {
    /// Texte localisable porté brut ; résolu via locale au render (warmup/cooldown).
    /// Pour le parsing de durée (SessionTimerPhase) on lit `.canonical`.
    case warmup(LocalizedText)
    case exercise(AdaptedExercise)
    case cooldown(LocalizedText)
}

struct SessionStep: Identifiable, Equatable {
    /// Index dans l'ordre de référence (warmup→exos→cooldown). Stable → sert d'id
    /// et de clé de persistance de complétion.
    let index: Int
    let kind: SessionStepKind

    var id: Int { index }

    /// Numéro d'exercice (1-based) pour les étapes `.exercise`, nil sinon.
    let exerciseNumber: Int?

    /// Construit les étapes FOCUS d'une séance. Warmup/cooldown ne sont inclus
    /// que s'ils sont non vides (cohérent avec la timeline).
    static func steps(for session: AdaptedSession) -> [SessionStep] {
        var result: [SessionStep] = []
        var index = 0
        if let w = session.warmup, !w.canonical.isEmpty {
            result.append(SessionStep(index: index, kind: .warmup(w), exerciseNumber: nil))
            index += 1
        }
        var exNumber = 0
        for ex in session.exercises {
            exNumber += 1
            result.append(SessionStep(index: index, kind: .exercise(ex), exerciseNumber: exNumber))
            index += 1
        }
        if let c = session.cooldown, !c.canonical.isEmpty {
            result.append(SessionStep(index: index, kind: .cooldown(c), exerciseNumber: nil))
        }
        return result
    }
}
