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

    // Revue dessins muscu 2026-06-08 — 4 patterns créés (dessinés sur demande Sophie)
    case hangingLegRaise // 3 frames — suspendu barre, jambes montent à l'horizontale
    case tricepsOverhead // 3 frames — haltère derrière la nuque, extension verticale
    case woodchopper     // 3 frames — câble diagonal haut→bas (coup de hache)
    case pullover        // 3 frames — allongé banc, haltère arc derrière tête → poitrine

    // Party illustrations 2026-06-08 — lot muscu machines (trous .generic confirmés au dump)
    case cableFly        // 3 frames — écarté poulie/pec deck, bras ouvrent→ferment devant
    case legExtension    // 3 frames — assis machine, jambes tendent (quadriceps)
    case legCurl         // 3 frames — allongé machine, talons fléchissent (ischios)
    case legPress        // 3 frames — assis incliné, jambes poussent le chariot
    case reverseHyper    // 3 frames — buste sur banc, jambes montent à l'horizontale (lombaires)

    // Party illustrations 2026-06-08 — lot HIIT (mouvements .generic confirmés au dump)
    case mountainClimber // 3 frames — gainage planche, genou qui monte alterné
    case jumpingJack     // 3 frames — bras+jambes ouvrent (jumping/step-jack) vue de face
    case tibialisRaise   // 3 frames — dos calé, orteils montent (tibial antérieur)
    case turkishGetUp    // 3 frames storyboard — allongé→appui→debout, charge au-dessus
    case powerClean      // 3 frames storyboard — barre sol→tirage→réception épaules
    case sledPush        // 3 frames — buste penché, pousse le traîneau lesté
    case farmerCarry     // 3 frames — marche debout, charges aux deux mains
    case doubleUnders    // 3 frames — petit saut, corde passe (vue de face)

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

    /// Famille « renforcement musculaire » (gainage, squat, hinge, mollets…) par
    /// opposition aux patterns cardio/sport (course, vélo, natation, yoga, mobilité).
    /// Sert au filtre indoor/outdoor vélo (décision Sophie 2026-06-12, 2A) : en SORTIE
    /// EXTÉRIEURE on retire le renfo hors-vélo (sur la route, on ne fait que pédaler) ;
    /// en INDOOR (home-trainer) on le garde (on descend, on enchaîne au sol).
    /// Switch exhaustif SANS `default` → tout nouveau pattern force une classification.
    public var isStrengthFamily: Bool {
        switch self {
        case .squat, .hinge, .pushHorizontal, .pushVertical, .pullHorizontal, .pullVertical,
             .lunge, .core, .plyo, .hipThrust, .calfRaise, .forearmPlank, .ytwActivation,
             .pallofPress, .nordicCurl, .birdDog, .deadBug, .clamshell, .kbSwing, .facePull,
             .foamRolling, .bicepsCurl, .tricepsPushdown, .lateralRaises, .hangingLegRaise,
             .tricepsOverhead, .woodchopper, .pullover,
             .cableFly, .legExtension, .legCurl, .legPress, .reverseHyper,
             .mountainClimber, .jumpingJack, .tibialisRaise, .turkishGetUp, .powerClean,
             .sledPush, .farmerCarry, .doubleUnders:
            return true
        case .mobility, .runEndurance, .runInterval, .runDrills, .swimDrill, .swimEndurance,
             .cycleEndurance, .cycleInterval, .yoga, .generic:
            return false
        }
    }
}
