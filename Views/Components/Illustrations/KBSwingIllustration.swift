// Views/Components/Illustrations/KBSwingIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — KB swing REFONDU (profil).
// Hip hinge balistique : KB entre les jambes (hanche reculée) → extension → KB devant.
import SwiftUI

struct KBSwingIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)
            // s2 : 0 = hinge bas (KB entre jambes), 1 = debout KB projeté devant
            let sw: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1)

            let ankle = p(22, 44)
            let knee  = p(L(20, 22, sw), L(34, 33, sw))
            let hip   = p(L(15, 22, sw), L(28, 22, sw))
            let shldr = p(L(27, 22, sw), L(23, 12, sw))
            let headC = p(L(32, 22, sw), L(22, 8, sw))

            StrengthFigureKit.limb(ctx, [p(18, 44), p(27, 44)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [ankle, knee, hip], color: body, s: s)
            StrengthFigureKit.limb(ctx, [hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Bras tendus depuis l'épaule ; la main passe de bas-entre-jambes à devant-haut
            let hand = p(L(22, 30, sw), L(38, 15, sw))
            StrengthFigureKit.limb(ctx, [shldr, hand], color: body, s: s)
            StrengthFigureKit.kettlebell(ctx, center: hand, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("KB swing") {
    HStack(spacing: 4) {
        KBSwingIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        KBSwingIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        KBSwingIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
