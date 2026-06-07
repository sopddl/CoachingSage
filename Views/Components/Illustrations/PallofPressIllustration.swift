// Views/Components/Illustrations/PallofPressIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — pallof press REFONDU (profil).
// Anti-rotation : câble latéral (côté), on presse la poignée DROIT DEVANT depuis la poitrine,
// le tronc résiste sans tourner.
import SwiftUI

struct PallofPressIllustration: View {
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
            let pp: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 poitrine, 1 bras tendu devant

            let ankle = p(18, 44), knee = p(18, 34), hip = p(18, 25), shldr = p(18, 15), headC = p(19, 10)
            StrengthFigureKit.limb(ctx, [p(14, 44), p(23, 44)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [ankle, knee, hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Câble latéral (vient de la gauche, derrière), mains pressent droit devant
            let hand = p(L(24, 38, pp), 20)
            let elbow = p(L(21, 31, pp), L(18, 20, pp))
            StrengthFigureKit.limb(ctx, [p(2, 24), hand], color: IllustrationStyle.groundLine, s: s) // câble
            StrengthFigureKit.limb(ctx, [shldr, elbow, hand], color: body, s: s)
            StrengthFigureKit.limb(ctx, [CGPoint(x: hand.x, y: hand.y - 2.5 * s), CGPoint(x: hand.x, y: hand.y + 2.5 * s)],
                                   color: IllustrationStyle.equipment, s: s, heavy: true) // poignée
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Pallof press") {
    HStack(spacing: 4) {
        PallofPressIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PallofPressIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PallofPressIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
