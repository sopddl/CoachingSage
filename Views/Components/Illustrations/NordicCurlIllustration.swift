// Views/Components/Illustrations/NordicCurlIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — nordic curl REFONDU (profil).
// À genoux, chevilles bloquées, le corps reste DROIT (genou→tête) et descend vers l'avant
// (excentrique ischio). Les mains rattrapent près du sol.
import SwiftUI

struct NordicCurlIllustration: View {
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
            let d: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1)

            let knee = p(22, 42)
            // Tibias à plat au sol vers l'arrière + chevilles bloquées (sangle d'ancrage)
            StrengthFigureKit.limb(ctx, [knee, p(12, 44)], color: body, s: s)
            var strap = Path()
            strap.addArc(center: CGPoint(x: 13 * s, y: 44 * s), radius: 2.6 * s,
                         startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            ctx.stroke(strap, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round))

            // Corps RIGIDE depuis le genou, bascule vers l'avant (excentrique ischio)
            let a = L(6, 66, d) * .pi / 180 // angle depuis la verticale
            let dir = CGPoint(x: sin(a), y: -cos(a))
            let hip = CGPoint(x: knee.x + dir.x * 6 * s, y: knee.y + dir.y * 6 * s)
            let shldr = CGPoint(x: knee.x + dir.x * 19 * s, y: knee.y + dir.y * 19 * s)
            let headC = CGPoint(x: knee.x + dir.x * 23 * s, y: knee.y + dir.y * 23 * s)
            StrengthFigureKit.limb(ctx, [knee, hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Bras : le long du corps debout → tendus vers le sol au plus bas (rattrapage)
            let hand = CGPoint(x: shldr.x + L(2, 7, d) * s, y: shldr.y + L(9, 7, d) * s)
            StrengthFigureKit.limb(ctx, [shldr, hand], color: body, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Nordic curl") {
    HStack(spacing: 4) {
        NordicCurlIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        NordicCurlIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        NordicCurlIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
