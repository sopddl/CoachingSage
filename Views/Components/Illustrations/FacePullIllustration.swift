// Views/Components/Illustrations/FacePullIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — face pull REFONDU (profil).
// On tire la corde du câble HAUT vers le visage, coudes qui s'écartent vers l'arrière.
import SwiftUI

struct FacePullIllustration: View {
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
            let pl: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 bras tendu, 1 tiré au visage

            let ankle = p(20, 44), knee = p(20, 34), hip = p(20, 25), shldr = p(20, 15), headC = p(21, 10)
            StrengthFigureKit.limb(ctx, [p(16, 44), p(25, 44)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [ankle, knee, hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Poulie haute devant (ancrage)
            StrengthFigureKit.box(ctx, rect: CGRect(x: 43 * s, y: 4 * s, width: 3 * s, height: 6 * s), s: s, filled: true)
            // La main arrive près du VISAGE ; le coude part en ARRIÈRE (s'écarte) = signature face pull
            let hand = p(L(40, 24, pl), L(13, 12, pl))
            let elbow = p(L(36, 13, pl), 14)
            StrengthFigureKit.limb(ctx, [p(45, 7), hand], color: IllustrationStyle.groundLine, s: s) // câble
            StrengthFigureKit.limb(ctx, [shldr, elbow, hand], color: body, s: s)
            // Corde double (2 brins) à la poignée
            StrengthFigureKit.limb(ctx, [CGPoint(x: hand.x, y: hand.y - 2.5 * s), CGPoint(x: hand.x + 4 * s, y: hand.y - 1 * s)],
                                   color: IllustrationStyle.equipment, s: s)
            StrengthFigureKit.limb(ctx, [CGPoint(x: hand.x, y: hand.y + 2.5 * s), CGPoint(x: hand.x + 4 * s, y: hand.y + 1 * s)],
                                   color: IllustrationStyle.equipment, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Face pull") {
    HStack(spacing: 4) {
        FacePullIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        FacePullIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        FacePullIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
