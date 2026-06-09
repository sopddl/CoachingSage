// Views/Components/Illustrations/DoubleUndersIllustration.swift
// Party illustrations 2026-06-08 — lot HIIT. Double-unders (corde à sauter) vue de FACE :
// petit saut, la corde passe sous les pieds (frame 0) → sur les côtés → au-dessus (frame 2).
import SwiftUI

struct DoubleUndersIllustration: View {
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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1)
            let hop = L(0, -3, r) // saut maximal quand la corde est en haut

            StrengthFigureKit.headNeck(ctx, head: p(24, 9 + hop), shoulder: p(24, 15 + hop), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 15 + hop), p(24, 28 + hop)], color: body, s: s) // tronc
            // Bras coudes près du corps, mains qui tiennent les poignées
            let handL = p(16, 24 + hop), handR = p(32, 24 + hop)
            StrengthFigureKit.limb(ctx, [p(24, 16 + hop), handL], color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 16 + hop), handR], color: body, s: s)
            // Jambes légèrement fléchies
            let hip = p(24, 28 + hop)
            StrengthFigureKit.limb(ctx, [hip, p(21, 42 + hop)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [hip, p(27, 42 + hop)], color: body, s: s)

            // Corde : arc entre les deux mains, point de contrôle bas (sous pieds) → haut (overhead)
            var rope = Path()
            rope.move(to: handL)
            rope.addQuadCurve(to: handR, control: p(24, L(50, 0, r)))
            ctx.stroke(rope, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthThin * s, lineCap: .round))
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Double-unders") {
    HStack(spacing: 4) {
        DoubleUndersIllustration(sportCode: "hiit", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        DoubleUndersIllustration(sportCode: "hiit", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        DoubleUndersIllustration(sportCode: "hiit", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
