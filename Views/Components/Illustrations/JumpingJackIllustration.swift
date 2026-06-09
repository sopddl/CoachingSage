// Views/Components/Illustrations/JumpingJackIllustration.swift
// Party illustrations 2026-06-08 — lot HIIT. Jumping jack / step-jack vue de FACE :
// bras + jambes s'ouvrent en étoile (frame 0 fermé → frame 2 ouvert overhead).
import SwiftUI

struct JumpingJackIllustration: View {
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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 fermé, 1 ouvert étoile
            let hop = L(0, -2, r) // petit saut quand ouvert

            StrengthFigureKit.headNeck(ctx, head: p(24, 9 + hop), shoulder: p(24, 15 + hop), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 15 + hop), p(24, 29 + hop)], color: body, s: s) // tronc
            let shL = p(21, 16 + hop), shR = p(27, 16 + hop)
            StrengthFigureKit.limb(ctx, [shL, shR], color: body, s: s)

            // Bras : le long du corps → tendus overhead en V
            StrengthFigureKit.limb(ctx, [shL, p(L(20, 14, r), L(28, 7, r) + hop)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [shR, p(L(28, 34, r), L(28, 7, r) + hop)], color: body, s: s)

            // Jambes : serrées → écartées
            let hip = p(24, 29 + hop)
            StrengthFigureKit.limb(ctx, [hip, p(L(22, 15, r), 44)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [hip, p(L(26, 33, r), 44)], color: body, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Jumping jack") {
    HStack(spacing: 4) {
        JumpingJackIllustration(sportCode: "hiit", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        JumpingJackIllustration(sportCode: "hiit", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        JumpingJackIllustration(sportCode: "hiit", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
