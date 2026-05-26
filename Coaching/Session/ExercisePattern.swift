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
    // Strength (12 cases dont 2 statiques)
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
    // Story 3.23 Tier 1 Jalon 2 — patterns dédiés haute fréquence
    case hipThrust   // 246 occ × 33 templates
    case calfRaise   // 228 occ × 23 templates

    // Story 3.23 Lot 3 — patterns haute fréquence ajoutés
    case forearmPlank  // statique — distinct du high-plank de .core
    case ytwActivation // 3 frames — rotator cuff Y/T/W
    case pallofPress   // 3 frames — anti-rotation câble
    case nordicCurl    // 3 frames — excentrique ischio
    case birdDog       // statique — gainage 4 pattes diagonal

    // Story 3.23 Lot 5 — patterns moyenne fréquence ajoutés
    case deadBug       // 3 frames — gainage allongé contralatéral
    case clamshell     // 3 frames — glute med ouverture genou
    case kbSwing       // 3 frames — hip hinge kettlebell
    case facePull      // 3 frames — câble HAUT rear-delt
    case foamRolling   // statique — appui sur cylindre orange
    case bicepsCurl    // 3 frames — flexion coude haltères

    // Story 3.23 Lot 7 — patterns reste (finition catalogue)
    case tricepsPushdown // 3 frames — câble HAUT extension coude
    case lateralRaises   // 3 frames — haltères élévation latérale deltoïdes

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

    // Yoga (1 case ombrelle, sous-poses dispatchées via `exerciseName` dans
    // `YogaIllustration` — Sophie 2026-05-23 : V1 yoga 10 poses fondamentales)
    case yoga

    // Fallback ultime — pas d'illustration custom, délègue à
    // `ExercisePatternGenericFallback` (SF Symbol sport iOS 17 `.palette`).
    case generic

    /// Nombre de frames composant le strip illustration.
    /// 1 = statique (avec annotations), 3 = dynamique (storyboard mouvement),
    /// 0 pour `.generic` (rendu via SF Symbol fallback).
    public var frameCount: Int {
        switch self {
        case .core, .mobility, .runDrills, .cycleEndurance, .cycleInterval, .yoga,
             .forearmPlank, .birdDog, .foamRolling:
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
