// Views/Components/Illustrations/WoodchopperIllustration.swift
// Revue dessins muscu 2026-06-08 (re-jet expert pictos) — cable woodchopper.
// Vue 3/4. La poignée part EN HAUT (poulie haute, coin haut-droit) et descend en
// diagonale vers la hanche opposée (« coup de hache »). Corrections revue : mains au
// DÉPART en haut (pas au sol), tronc qui reste droit (jamais plié en avant comme un
// soulevé de terre), mains d'arrivée à hauteur de hanche (pas au sol), 1 seule flèche.
import SwiftUI

struct WoodchopperIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

            StrengthFigureKit.ground(ctx, s: s)

            // Corps debout, stance large, léger squat — IDENTIQUE sur les 3 frames.
            // Tronc droit (pivote, ne se plie PAS en avant).
            let hip = p(26, 28), shldr = p(26, 15), headC = p(26, 9)
            StrengthFigureKit.limb(ctx, [p(16, 44), p(18, 36), hip], color: body, s: s) // jambe G
            StrengthFigureKit.limb(ctx, [p(36, 44), p(34, 36), hip], color: body, s: s) // jambe D
            StrengthFigureKit.limb(ctx, [hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Poignée tenue à 2 mains : HAUT-droite → BAS-gauche (hauteur hanche).
            let handle: CGPoint = frame == 0 ? p(42, 7) : (frame == 1 ? p(28, 22) : p(14, 33))
            StrengthFigureKit.limb(ctx, [shldr, handle], color: body, s: s)
            // Câble depuis la poulie HAUTE (coin haut-droit), suit la poignée.
            var cable = Path()
            cable.move(to: p(46, 3)); cable.addLine(to: handle)
            ctx.stroke(cable, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round))
            StrengthFigureKit.dumbbell(ctx, center: handle, s: s)

            // Flèche unique : diagonale franche HAUT-droite → BAS-gauche.
            var arrow = Path()
            arrow.move(to: p(40, 10)); arrow.addLine(to: p(18, 31))
            arrow.move(to: p(18, 31)); arrow.addLine(to: p(24, 31))
            arrow.move(to: p(18, 31)); arrow.addLine(to: p(20, 25))
            ctx.stroke(arrow, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Woodchopper") {
    HStack {
        WoodchopperIllustration(sportCode: "strengthTraining", frame: 0)
        WoodchopperIllustration(sportCode: "strengthTraining", frame: 1)
        WoodchopperIllustration(sportCode: "strengthTraining", frame: 2)
    }.padding().background(Color.coachingBackground)
}
#endif
