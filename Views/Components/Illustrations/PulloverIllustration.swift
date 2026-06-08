// Views/Components/Illustrations/PulloverIllustration.swift
// Revue dessins muscu 2026-06-08 — dumbbell pullover. Allongé sur un banc, un haltère tenu
// à 2 mains bras quasi tendus : arc de DERRIÈRE la tête (étirement) vers AU-DESSUS de la
// poitrine. 3 frames.
import SwiftUI

struct PulloverIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)
            let arc: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 derrière tête, 1 au-dessus poitrine

            // Banc horizontal
            StrengthFigureKit.box(ctx, rect: CGRect(x: 22 * s, y: 30 * s, width: 34 * s, height: 6 * s), s: s, filled: true)

            // Corps allongé SUR le banc : hanche → épaule (sur le banc), tête débord à droite
            let hip = p(28, 29), shldr = p(50, 29)
            StrengthFigureKit.limb(ctx, [hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: p(57, 27), shoulder: shldr, color: body, s: s)
            // Jambes : genoux fléchis, pieds au sol
            StrengthFigureKit.limb(ctx, [hip, p(24, 40), p(30, 44)], color: body, s: s)

            // Bras quasi tendus tenant l'haltère : arc derrière la tête → au-dessus de la poitrine
            let hand = p(L(62, 44, arc), L(20, 9, arc))
            StrengthFigureKit.limb(ctx, [shldr, hand], color: body, s: s)
            StrengthFigureKit.dumbbell(ctx, center: hand, s: s)

            // Flèche d'arc (derrière tête → au-dessus poitrine)
            var arrow = Path()
            arrow.move(to: p(60, 16)); arrow.addLine(to: p(40, 10))
            arrow.move(to: p(40, 10)); arrow.addLine(to: p(45, 9))
            arrow.move(to: p(40, 10)); arrow.addLine(to: p(44, 14))
            ctx.stroke(arrow, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Pullover") {
    HStack {
        PulloverIllustration(sportCode: "strengthTraining", frame: 0)
        PulloverIllustration(sportCode: "strengthTraining", frame: 1)
        PulloverIllustration(sportCode: "strengthTraining", frame: 2)
    }.padding().background(Color.coachingBackground)
}
#endif
