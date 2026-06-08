// Views/Components/Illustrations/WoodchopperIllustration.swift
// Revue dessins muscu 2026-06-08 — cable woodchopper (rotation anti-rotation câble).
// Debout, poignée câble tenue à 2 mains, mouvement diagonal du HAUT (côté) vers le BAS
// opposé (le « coup de hache »). Câble relié à une poulie haute. 3 frames.
import SwiftUI

struct WoodchopperIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)
            let chop: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 haut-droite, 1 bas-gauche

            // Corps debout (profil), léger fléchissement de hanche en fin de chop
            let ankle = p(26, 44), knee = p(26, 33)
            let hip = p(26, 23), shldr = p(26, 13), headC = p(26, 8)
            StrengthFigureKit.limb(ctx, [p(22, 44), p(31, 44)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [ankle, knee, hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Poignée tenue à 2 mains : diagonale haut-droite → bas-gauche
            let handle = p(L(40, 12, chop), L(11, 34, chop))
            StrengthFigureKit.limb(ctx, [shldr, handle], color: body, s: s)
            // Câble depuis la poulie HAUTE (coin haut-droit) jusqu'à la poignée
            var cable = Path()
            cable.move(to: p(46, 4)); cable.addLine(to: handle)
            ctx.stroke(cable, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round))
            // Poignée (petit trait perpendiculaire) à 2 mains
            StrengthFigureKit.dumbbell(ctx, center: handle, s: s)

            // Flèche diagonale du chop (haut-droite → bas-gauche)
            var arrow = Path()
            arrow.move(to: p(34, 18)); arrow.addLine(to: p(18, 32))
            arrow.move(to: p(18, 32)); arrow.addLine(to: p(23, 31))
            arrow.move(to: p(18, 32)); arrow.addLine(to: p(20, 27))
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
