// Views/Components/Illustrations/FarmerCarryIllustration.swift
// Party illustrations 2026-06-08 — lot HIIT. Farmer carry vue de FACE : debout, une charge
// dans chaque main le long du corps, marche (foulée alternée frame 0→2). Port de charge.
import SwiftUI

struct FarmerCarryIllustration: View {
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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // foulée alternée

            StrengthFigureKit.headNeck(ctx, head: p(24, 9), shoulder: p(24, 15), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 15), p(24, 29)], color: body, s: s)  // tronc
            let shL = p(20, 16), shR = p(28, 16)
            StrengthFigureKit.limb(ctx, [shL, shR], color: body, s: s)

            // Bras tendus le long du corps, charge à chaque main
            let handL = p(18, 30), handR = p(30, 30)
            StrengthFigureKit.limb(ctx, [shL, handL], color: body, s: s)
            StrengthFigureKit.limb(ctx, [shR, handR], color: body, s: s)
            StrengthFigureKit.dumbbell(ctx, center: p(18, 33), s: s)
            StrengthFigureKit.dumbbell(ctx, center: p(30, 33), s: s)

            // Jambes en foulée (un genou avance/se plie selon la frame)
            let hip = p(24, 29)
            StrengthFigureKit.limb(ctx, [hip, p(L(21, 23, r), 44)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [hip, p(L(27, 25, r), L(44, 40, r)), p(L(27, 29, r), 44)], color: body, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Farmer carry") {
    HStack(spacing: 4) {
        FarmerCarryIllustration(sportCode: "hiit", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        FarmerCarryIllustration(sportCode: "hiit", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        FarmerCarryIllustration(sportCode: "hiit", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
