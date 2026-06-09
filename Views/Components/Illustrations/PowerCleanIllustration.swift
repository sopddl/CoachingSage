// Views/Components/Illustrations/PowerCleanIllustration.swift
// Party illustrations 2026-06-08 — lot HIIT. Power clean (haltérophilie) vue de PROFIL, en
// STORYBOARD 3 postures distinctes (pas une interpolation) : départ barre au sol (frame 0) →
// tirage explosif barre à la hanche (frame 1) → réception en rack avant épaules (frame 2).
// Couvre aussi hang clean / power snatch via le resolver.
import SwiftUI

struct PowerCleanIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

            StrengthFigureKit.ground(ctx, s: s)

            switch frame {
            case 0: // Départ : penché, hanche en arrière, barre au sol
                let bar = p(23, 42)
                StrengthFigureKit.headNeck(ctx, head: p(14, 20), shoulder: p(18, 23), color: body, s: s)
                StrengthFigureKit.limb(ctx, [p(18, 23), p(30, 28)], color: body, s: s)  // dos incliné
                StrengthFigureKit.limb(ctx, [p(30, 28), p(27, 38), p(31, 44)], color: body, s: s) // hanche→genou→pied
                StrengthFigureKit.limb(ctx, [p(18, 23), bar], color: body, s: s)        // bras vers la barre
                StrengthFigureKit.barbellEndOn(ctx, center: bar, s: s)
            case 1: // Tirage : extension complète, barre à la hanche, haussement d'épaules
                let bar = p(25, 28)
                StrengthFigureKit.headNeck(ctx, head: p(23, 9), shoulder: p(23, 15), color: body, s: s)
                StrengthFigureKit.limb(ctx, [p(23, 15), p(25, 29)], color: body, s: s)  // tronc droit
                StrengthFigureKit.limb(ctx, [p(25, 29), p(24, 38), p(25, 44)], color: body, s: s) // jambe quasi tendue
                StrengthFigureKit.limb(ctx, [p(23, 15), bar], color: body, s: s)        // bras tendus tenant la barre
                StrengthFigureKit.barbellEndOn(ctx, center: bar, s: s)
            default: // Réception : rack avant, coudes hauts, quart de squat
                let bar = p(24, 18)
                StrengthFigureKit.headNeck(ctx, head: p(24, 9), shoulder: p(25, 16), color: body, s: s)
                StrengthFigureKit.limb(ctx, [p(25, 16), p(25, 30)], color: body, s: s)  // tronc
                StrengthFigureKit.limb(ctx, [p(25, 30), p(22, 38), p(25, 44)], color: body, s: s) // quart de squat
                StrengthFigureKit.limb(ctx, [p(25, 16), p(31, 16), bar], color: body, s: s) // coude haut → barre au rack
                StrengthFigureKit.barbellEndOn(ctx, center: bar, s: s)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Power clean") {
    HStack(spacing: 4) {
        PowerCleanIllustration(sportCode: "hiit", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PowerCleanIllustration(sportCode: "hiit", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PowerCleanIllustration(sportCode: "hiit", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
