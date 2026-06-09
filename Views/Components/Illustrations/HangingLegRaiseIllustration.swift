// Views/Components/Illustrations/HangingLegRaiseIllustration.swift
// Revue dessins muscu 2026-06-08 — relevé de jambes suspendu (hanging leg raise).
// Suspension à une barre fixe (corps vertical), jambes qui montent de la verticale
// vers l'horizontale (L). 3 frames.
import SwiftUI

struct HangingLegRaiseIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 jambes basses, 1 jambes à l'horizontale

            // Barre fixe horizontale en haut (sans disque)
            StrengthFigureKit.limb(ctx, [p(8, 7), p(34, 7)], color: IllustrationStyle.equipment, s: s, heavy: true)
            let hand = p(20, 7)
            let shldr = p(20, 17)
            let hip = p(20, 28)
            // Bras de suspension + tronc (vertical)
            StrengthFigureKit.limb(ctx, [hand, shldr, hip], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: p(25, 13), shoulder: shldr, color: body, s: s)
            // Jambes : de la verticale (basses) vers l'horizontale (relevées)
            let knee = p(L(20, 33, r), L(38, 28, r))
            let foot = p(L(20, 44, r), L(46, 28, r))
            StrengthFigureKit.limb(ctx, [hip, knee, foot], color: body, s: s)
            // Flèche de montée des jambes
            if frame >= 1 {
                var up = Path()
                up.move(to: p(40, 40)); up.addLine(to: p(40, 31))
                up.move(to: p(40, 31)); up.addLine(to: p(37, 34))
                up.move(to: p(40, 31)); up.addLine(to: p(43, 34))
                ctx.stroke(up, with: .color(IllustrationStyle.movementArrow),
                           style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Hanging leg raise") {
    HStack {
        HangingLegRaiseIllustration(sportCode: "strengthTraining", frame: 0)
        HangingLegRaiseIllustration(sportCode: "strengthTraining", frame: 1)
        HangingLegRaiseIllustration(sportCode: "strengthTraining", frame: 2)
    }.padding().background(Color.coachingBackground)
}
#endif
