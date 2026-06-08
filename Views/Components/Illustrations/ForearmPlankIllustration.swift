// Views/Components/Illustrations/ForearmPlankIllustration.swift
// Story 3.23 Lot 3 — forearm plank (low plank) statique 1 frame, viewbox 80×48.
// Distinct de CoreIllustration.frontal (high-plank paumes au sol bras tendus).
// Source : https://en.wikipedia.org/wiki/Plank_(exercise)
// Signature : corps horizontal strict + appui sur AVANT-BRAS coudés à 90° au sol.
import SwiftUI

struct ForearmPlankIllustration: View {
    let sportCode: String
    var size: CGFloat = IllustrationStyle.staticFrameSize.height // revue 2026-06-08 : scale (cf yoga)

    var body: some View {
        Canvas { ctx, size in
            let sx = size.width / IllustrationStyle.staticFrameSize.width
            let sy = size.height / IllustrationStyle.staticFrameSize.height
            let s = min(sx, sy)
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)

            // Sol pointillé
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 44 * s))
            ground.addLine(to: CGPoint(x: 76 * s, y: 44 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Tête (côté gauche, regard vers le sol)
            let headSize: CGFloat = 6 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: 16 * s - headSize / 2, y: 24 * s - headSize / 2,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc HORIZONTAL strict (épaule → bassin → chevilles) — signature gainage
            var trunk = Path()
            trunk.move(to: CGPoint(x: 22 * s, y: 28 * s))    // épaule
            trunk.addLine(to: CGPoint(x: 74 * s, y: 28 * s)) // cheville
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Pied droit en flexion dorsale (pointe au sol)
            var foot = Path()
            foot.move(to: CGPoint(x: 74 * s, y: 28 * s))
            foot.addLine(to: CGPoint(x: 76 * s, y: 44 * s))
            ctx.stroke(foot, with: .color(silhouette), style: stroke)

            // Bras d'appui (humérus pendant + AVANT-BRAS au sol) — SIGNATURE forearm plank
            // Humérus vertical : épaule → coude (au sol)
            var humerus = Path()
            humerus.move(to: CGPoint(x: 22 * s, y: 28 * s))
            humerus.addLine(to: CGPoint(x: 22 * s, y: 40 * s))
            ctx.stroke(humerus, with: .color(silhouette), style: stroke)

            // Avant-bras au sol (coude → poignet horizontal)
            var forearm = Path()
            forearm.move(to: CGPoint(x: 22 * s, y: 40 * s))
            forearm.addLine(to: CGPoint(x: 36 * s, y: 44 * s))
            ctx.stroke(forearm, with: .color(silhouette), style: stroke)

            // Main posée à plat (segment court horizontal au sol)
            var hand = Path()
            hand.move(to: CGPoint(x: 36 * s, y: 44 * s))
            hand.addLine(to: CGPoint(x: 40 * s, y: 44 * s))
            ctx.stroke(hand, with: .color(silhouette), style: stroke)

            // Annotation gainage : flèche horizontale orange au-dessus du bassin
            var hold = Path()
            hold.move(to: CGPoint(x: 46 * s, y: 22 * s))
            hold.addLine(to: CGPoint(x: 58 * s, y: 22 * s))
            ctx.stroke(hold, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, dash: [3 * s, 2 * s]))
        }
        .frame(width: size * (IllustrationStyle.staticFrameSize.width / IllustrationStyle.staticFrameSize.height),
               height: size)
    }
}

#if DEBUG
#Preview("Forearm plank — low plank") {
    ForearmPlankIllustration(sportCode: "strengthTraining")
        .padding()
        .background(Color.coachingBackground)
}
#endif
