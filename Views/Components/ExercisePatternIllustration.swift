// Views/Components/ExercisePatternIllustration.swift
// Story 3.19 — strip horizontal multi-frames pour un exo. Pivot view qui dispatche
// vers l'illu spécifique selon le pattern résolu, et ajoute les flèches entre frames.
// `.generic` → délègue à `ExercisePatternGenericFallback` (SF Symbol sport).
import SwiftUI

struct ExercisePatternIllustration: View {
    let pattern: ExercisePattern
    let sportCode: String
    /// Hint optionnel sur le nom de l'exercice pour détecter des variantes
    /// (ex: "Plank latéral" → variante side plank dans `CoreIllustration`).
    var exerciseName: String? = nil
    var size: CGFloat = IllustrationStyle.frameSize

    var body: some View {
        Group {
            if pattern == .generic {
                ExercisePatternGenericFallback(sportCode: sportCode, size: size)
            } else if pattern.isStatic {
                staticIllustration
                    .frame(height: size)
            } else {
                // POC muscu (Sophie 2026-06-06) : le strip s'auto-dimensionne à la
                // hauteur réelle du dessin agrandi (≈ frameSize × facteur) au lieu de
                // réclamer `size` → supprime le vide vertical de la boîte (reco Sally :
                // boîte au ratio du dessin, pas à moitié vide).
                dynamicStrip
            }
        }
        .dynamicTypeSize(.medium ... .accessibility2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityKey))
    }

    // MARK: - Dispatch

    @ViewBuilder
    private var staticIllustration: some View {
        switch pattern {
        case .core:
            CoreIllustration(sportCode: sportCode, variant: coreVariant, size: min(size, 176))
        case .mobility:
            MobilityIllustration(sportCode: sportCode)
        case .yoga:
            // POC yoga (D4) : le dessin honore `size` (avant : figé 80×48 → riquiqui).
            // Plafonné à 176 pt de haut → largeur ≈ 293 pt, tient dans la boîte sur
            // tous les iPhone (≥ 320 pt). Timeline (size 48 par défaut) → inchangée.
            YogaIllustration(sportCode: sportCode, exerciseName: exerciseName, size: min(size, 176))
        case .forearmPlank:
            ForearmPlankIllustration(sportCode: sportCode, size: min(size, 176))
        case .birdDog:
            BirdDogIllustration(sportCode: sportCode, size: min(size, 176))
        case .foamRolling:
            FoamRollingIllustration(sportCode: sportCode, size: min(size, 176))
        default:
            // Décision produit Sophie 2026-05-23 : pas de dessin pour les
            // gestes universels connus (running, cycling, swim continu).
            // .runDrills / .cycleEndurance / .cycleInterval → fallback SF Symbol sport.
            ExercisePatternGenericFallback(sportCode: sportCode, size: size)
        }
    }

    private var coreVariant: CoreIllustration.Variant {
        guard let lower = exerciseName?.lowercased() else { return .frontal }
        if lower.contains("latéral") || lower.contains("lateral") || lower.contains("side") {
            return .lateral
        }
        return .frontal
    }

    @ViewBuilder
    private var dynamicStrip: some View {
        switch pattern {
        case .squat:
            // Chantier refonte muscu — propager exerciseName pour la variante équipement
            // (goblet / barre nuque / bulgare / poids du corps).
            tripletStrip { SquatIllustration(sportCode: sportCode, frame: $0, exerciseName: exerciseName) }
        case .hinge:
            tripletStrip { HingeIllustration(sportCode: sportCode, frame: $0, exerciseName: exerciseName) }
        case .pullVertical:
            tripletStrip { PullVerticalIllustration(sportCode: sportCode, frame: $0, exerciseName: exerciseName) }
        case .pushHorizontal:
            // Story 3.23 — propager exerciseName pour variante DB bench press
            tripletStrip { PushHorizontalIllustration(sportCode: sportCode, frame: $0, exerciseName: exerciseName) }
        case .pushVertical:
            tripletStrip { PushVerticalIllustration(sportCode: sportCode, frame: $0, exerciseName: exerciseName) }
        case .pullHorizontal:
            tripletStrip { PullHorizontalIllustration(sportCode: sportCode, frame: $0, exerciseName: exerciseName) }
        case .lunge:
            tripletStrip { LungeIllustration(sportCode: sportCode, frame: $0, exerciseName: exerciseName) }
        case .plyo:
            tripletStrip { PlyoIllustration(sportCode: sportCode, frame: $0, exerciseName: exerciseName) }
        case .hipThrust:
            // Story 3.23 Tier 1 Jalon 2 — 246 occ × 33 tpl ; chantier muscu : variante banc/sol
            tripletStrip { HipThrustIllustration(sportCode: sportCode, frame: $0, exerciseName: exerciseName) }
        case .calfRaise:
            // Story 3.23 Tier 1 Jalon 2 — 228 occ × 23 tpl ; chantier muscu : variante debout/assis
            tripletStrip { CalfRaiseIllustration(sportCode: sportCode, frame: $0, exerciseName: exerciseName) }
        case .ytwActivation:
            // Story 3.23 Lot 3 — Y-T-W rotator cuff activation
            tripletStrip { YTWActivationIllustration(sportCode: sportCode, frame: $0) }
        case .pallofPress:
            // Story 3.23 Lot 3 — Pallof press câble anti-rotation
            tripletStrip { PallofPressIllustration(sportCode: sportCode, frame: $0) }
        case .nordicCurl:
            // Story 3.23 Lot 3 — Nordic curl excentrique ischio
            tripletStrip { NordicCurlIllustration(sportCode: sportCode, frame: $0) }
        case .deadBug:
            // Story 3.23 Lot 5 — Dead-bug gainage controlatéral
            tripletStrip { DeadBugIllustration(sportCode: sportCode, frame: $0) }
        case .clamshell:
            // Story 3.23 Lot 5 — Clamshell glute med
            tripletStrip { ClamshellIllustration(sportCode: sportCode, frame: $0) }
        case .kbSwing:
            // Story 3.23 Lot 5 — KB Swing Russian
            tripletStrip { KBSwingIllustration(sportCode: sportCode, frame: $0) }
        case .facePull:
            // Story 3.23 Lot 5 — Face pull câble rear-delt
            tripletStrip { FacePullIllustration(sportCode: sportCode, frame: $0) }
        case .bicepsCurl:
            // Story 3.23 Lot 5 → chantier lot 2 : variante haltères/barre
            tripletStrip { BicepsCurlIllustration(sportCode: sportCode, frame: $0, exerciseName: exerciseName) }
        case .tricepsPushdown:
            // Story 3.23 Lot 7 — Triceps pushdown câble
            tripletStrip { TricepsPushdownIllustration(sportCode: sportCode, frame: $0) }
        case .lateralRaises:
            // Story 3.23 Lot 7 — Lateral raises haltères deltoïdes
            tripletStrip { LateralRaisesIllustration(sportCode: sportCode, frame: $0) }
        case .hangingLegRaise:
            tripletStrip { HangingLegRaiseIllustration(sportCode: sportCode, frame: $0) }
        case .tricepsOverhead:
            tripletStrip { TricepsOverheadIllustration(sportCode: sportCode, frame: $0) }
        case .woodchopper:
            tripletStrip { WoodchopperIllustration(sportCode: sportCode, frame: $0) }
        case .pullover:
            tripletStrip { PulloverIllustration(sportCode: sportCode, frame: $0) }
        // Party illustrations 2026-06-08 — lot muscu machines
        case .cableFly:
            tripletStrip { CableFlyIllustration(sportCode: sportCode, frame: $0) }
        case .legExtension:
            tripletStrip { LegExtensionIllustration(sportCode: sportCode, frame: $0) }
        case .legCurl:
            tripletStrip { LegCurlIllustration(sportCode: sportCode, frame: $0) }
        case .legPress:
            tripletStrip { LegPressIllustration(sportCode: sportCode, frame: $0) }
        case .reverseHyper:
            tripletStrip { ReverseHyperIllustration(sportCode: sportCode, frame: $0) }
        // Party illustrations 2026-06-08 — lot HIIT
        case .mountainClimber:
            tripletStrip { MountainClimberIllustration(sportCode: sportCode, frame: $0) }
        case .jumpingJack:
            tripletStrip { JumpingJackIllustration(sportCode: sportCode, frame: $0) }
        case .tibialisRaise:
            tripletStrip { TibialisRaiseIllustration(sportCode: sportCode, frame: $0) }
        case .turkishGetUp:
            tripletStrip { TurkishGetUpIllustration(sportCode: sportCode, frame: $0) }
        case .powerClean:
            tripletStrip { PowerCleanIllustration(sportCode: sportCode, frame: $0) }
        case .sledPush:
            tripletStrip { SledPushIllustration(sportCode: sportCode, frame: $0) }
        case .farmerCarry:
            tripletStrip { FarmerCarryIllustration(sportCode: sportCode, frame: $0) }
        case .doubleUnders:
            tripletStrip { DoubleUndersIllustration(sportCode: sportCode, frame: $0) }
        default:
            // Décision produit Sophie 2026-05-23 : pas de dessin pour les
            // gestes universels (foulée running, crawl, fractionné, drill rattrapé).
            // → fallback SF Symbol sport, le texte de la note décrit le geste.
            ExercisePatternGenericFallback(sportCode: sportCode, size: size)
        }
    }

    /// Strip de 3 frames séparées par 2 flèches mouvement.
    /// POC muscu (Sophie 2026-06-06 « trop petit ») : les frames hardcodent 48×48,
    /// donc `size` était ignoré → dessins riquiqui. On agrandit chaque frame via
    /// `scaleEffect` (Canvas vectoriel = net) en revendiquant l'espace correspondant.
    /// Facteur dérivé de `size` : timeline (48) → 1 (inchangée) ; FOCUS (180/200) → ~1,6×.
    private func tripletStrip<Content: View>(@ViewBuilder _ frame: @escaping (Int) -> Content) -> some View {
        let fs = IllustrationStyle.frameSize
        let factor = max(1, size / 110)
        return HStack(spacing: IllustrationStyle.frameSpacing) {
            frame(0).scaleEffect(factor, anchor: .center).frame(width: fs * factor, height: fs * factor)
            arrow
            frame(1).scaleEffect(factor, anchor: .center).frame(width: fs * factor, height: fs * factor)
            arrow
            frame(2).scaleEffect(factor, anchor: .center).frame(width: fs * factor, height: fs * factor)
        }
    }

    private var arrow: some View {
        Image(systemName: "arrow.right")
            .font(.system(size: IllustrationStyle.arrowSize, weight: .semibold))
            .foregroundStyle(IllustrationStyle.movementArrow)
    }

    // MARK: - Accessibility

    private var accessibilityKey: LocalizedStringKey {
        let frameCount = pattern.frameCount
        return "coaching.session.exercise.illustration.a11y \(pattern.rawValue) \(frameCount)"
    }
}

#if DEBUG
#Preview("ExercisePatternIllustration — 4 pilotes strength") {
    VStack(spacing: 12) {
        ExercisePatternIllustration(pattern: .squat, sportCode: "strengthTraining")
        ExercisePatternIllustration(pattern: .hinge, sportCode: "strengthTraining")
        ExercisePatternIllustration(pattern: .pullVertical, sportCode: "strengthTraining")
        ExercisePatternIllustration(pattern: .core, sportCode: "strengthTraining")
        ExercisePatternIllustration(pattern: .generic, sportCode: "tennis")
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
