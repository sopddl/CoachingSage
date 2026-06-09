// Views/Components/Illustrations/FoamRollingIllustration.swift
// Story 3.23 Lot 5 — Foam rolling 1 frame statique, viewbox 80×48.
// Source : https://en.wikipedia.org/wiki/Foam_rolling
// Signature : silhouette ventrale en appui avant-bras + cylindre orange sous
// la cuisse (quadriceps) + flèche horizontale va-et-vient au-dessus du rouleau.
import SwiftUI

struct FoamRollingIllustration: View {
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

            // Tête (à droite, regard vers le sol)
            let headSize: CGFloat = 6 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: 62 * s - headSize / 2, y: 26 * s - headSize / 2,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc oblique (gainé, ~30° par rapport sol — épaule droite haut, bassin gauche bas)
            var trunk = Path()
            trunk.move(to: CGPoint(x: 58 * s, y: 30 * s))     // épaule
            trunk.addLine(to: CGPoint(x: 38 * s, y: 38 * s))  // bassin
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Avant-bras gauche au sol (appui)
            var leftArm = Path()
            leftArm.move(to: CGPoint(x: 56 * s, y: 30 * s))      // épaule
            leftArm.addLine(to: CGPoint(x: 52 * s, y: 36 * s))   // coude
            leftArm.addLine(to: CGPoint(x: 48 * s, y: 44 * s))   // poignet au sol
            ctx.stroke(leftArm, with: .color(silhouette), style: stroke)

            // Main au sol (segment court)
            var hand = Path()
            hand.move(to: CGPoint(x: 44 * s, y: 44 * s))
            hand.addLine(to: CGPoint(x: 50 * s, y: 44 * s))
            ctx.stroke(hand, with: .color(silhouette), style: stroke)

            // Cuisse roulée (bassin → genou au-dessus du rouleau)
            var thigh = Path()
            thigh.move(to: CGPoint(x: 38 * s, y: 38 * s))
            thigh.addLine(to: CGPoint(x: 22 * s, y: 42 * s))
            ctx.stroke(thigh, with: .color(silhouette), style: stroke)

            // Tibia (au sol, derrière le rouleau)
            var shin = Path()
            shin.move(to: CGPoint(x: 22 * s, y: 42 * s))
            shin.addLine(to: CGPoint(x: 12 * s, y: 44 * s))
            ctx.stroke(shin, with: .color(silhouette), style: stroke)
            // Pied
            var foot = Path()
            foot.move(to: CGPoint(x: 8 * s, y: 44 * s))
            foot.addLine(to: CGPoint(x: 14 * s, y: 44 * s))
            ctx.stroke(foot, with: .color(silhouette), style: stroke)

            // Foam roller (cylindre marron, signature équipement)
            var roller = Path()
            roller.addRoundedRect(in: CGRect(x: 16 * s, y: 40 * s, width: 16 * s, height: 4 * s),
                                  cornerSize: CGSize(width: 2 * s, height: 2 * s))
            ctx.stroke(roller, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round))

            // Flèche double horizontale va-et-vient (signature foam rolling)
            var arrow = Path()
            arrow.move(to: CGPoint(x: 14 * s, y: 36 * s))
            arrow.addLine(to: CGPoint(x: 34 * s, y: 36 * s))
            // Pointe gauche
            arrow.move(to: CGPoint(x: 16 * s, y: 34 * s))
            arrow.addLine(to: CGPoint(x: 14 * s, y: 36 * s))
            arrow.addLine(to: CGPoint(x: 16 * s, y: 38 * s))
            // Pointe droite
            arrow.move(to: CGPoint(x: 32 * s, y: 34 * s))
            arrow.addLine(to: CGPoint(x: 34 * s, y: 36 * s))
            arrow.addLine(to: CGPoint(x: 32 * s, y: 38 * s))
            ctx.stroke(arrow, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))
        }
        .frame(width: size * (IllustrationStyle.staticFrameSize.width / IllustrationStyle.staticFrameSize.height),
               height: size)
    }
}

#if DEBUG
#Preview("Foam rolling — quadriceps") {
    FoamRollingIllustration(sportCode: "strengthTraining")
        .padding()
        .background(Color.coachingBackground)
}
#endif
