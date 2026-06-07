// Views/Components/Illustrations/YTWActivationIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — activation Y-T-W REFONDUE.
// Vue de FACE (les lettres Y/T/W sont des FORMES de bras, illisibles de profil).
// Les 3 frames = les 3 positions : Y (bras haut en V) → T (bras horizontaux) → W (coudes pliés).
import SwiftUI

struct YTWActivationIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

            StrengthFigureKit.ground(ctx, s: s)

            // Tronc de face fixe
            StrengthFigureKit.headNeck(ctx, head: p(24, 11), shoulder: p(24, 17), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 17), p(24, 32)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 32), p(20, 44)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 32), p(28, 44)], color: body, s: s)
            let shL = p(20, 17), shR = p(28, 17)
            StrengthFigureKit.limb(ctx, [shL, shR], color: body, s: s)

            switch frame {
            case 0: // Y — bras tendus en V vers le haut
                StrengthFigureKit.limb(ctx, [shL, p(13, 6)], color: body, s: s)
                StrengthFigureKit.limb(ctx, [shR, p(35, 6)], color: body, s: s)
            case 1: // T — bras horizontaux
                StrengthFigureKit.limb(ctx, [shL, p(9, 17)], color: body, s: s)
                StrengthFigureKit.limb(ctx, [shR, p(39, 17)], color: body, s: s)
            default: // W — coudes pliés vers le bas, mains remontées
                StrengthFigureKit.limb(ctx, [shL, p(14, 23), p(18, 14)], color: body, s: s)
                StrengthFigureKit.limb(ctx, [shR, p(34, 23), p(30, 14)], color: body, s: s)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Y-T-W") {
    HStack(spacing: 4) {
        YTWActivationIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        YTWActivationIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        YTWActivationIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
