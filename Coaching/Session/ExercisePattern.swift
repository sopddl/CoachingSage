// Coaching/Session/ExercisePattern.swift
// Story 3.19 — Phase 3 didactique. Patterns biomécaniques supportés V1 pour
// rendu illustration multi-frames + tip Léon. Résolus depuis `AdaptedExercise.name`
// via `ExercisePatternResolver` (cascade regex multi-mots → keyword → sport →
// .generic fallback SF Symbol sport).
//
// Split push/pull H/V (review Plan P1-2) : biomécanique trop différente entre
// horizontal (pompe/row) et vertical (overhead/pull-up) pour partager une illu.
import Foundation

public enum ExercisePattern: String, Equatable, Sendable, CaseIterable {
    // Strength (10 cases dont 2 statiques)
    case squat
    case hinge
    case pushHorizontal
    case pushVertical
    case pullHorizontal
    case pullVertical
    case lunge
    case core
    case plyo
    case mobility

    // Running (3 cases dont 1 statique)
    case runEndurance
    case runInterval
    case runDrills

    // Swimming (2 cases dont 0 statique)
    case swimDrill
    case swimEndurance

    // Cycling (2 cases statiques)
    case cycleEndurance
    case cycleInterval

    // Fallback ultime — pas d'illustration custom, délègue à
    // `ExercisePatternGenericFallback` (SF Symbol sport iOS 17 `.palette`).
    case generic

    /// Nombre de frames composant le strip illustration.
    /// 1 = statique (avec annotations), 3 = dynamique (storyboard mouvement),
    /// 0 pour `.generic` (rendu via SF Symbol fallback).
    public var frameCount: Int {
        switch self {
        case .core, .mobility, .runDrills, .cycleEndurance, .cycleInterval:
            return 1
        case .generic:
            return 0
        default:
            return 3
        }
    }

    /// Vrai si l'illu est un dessin unique annoté (vs storyboard multi-frames).
    /// `.generic` n'est PAS statique (rendu via SF Symbol fallback).
    public var isStatic: Bool {
        return frameCount == 1
    }
}
