// Views/Components/Illustrations/DeadBugIllustration.swift
// Story 3.23 Lot 5 v2 — Dead-bug 3 frames, viewbox 48×48.
// Source : https://en.wikipedia.org/wiki/Dead_bug_(exercise)
// Signature v2 : DOS au sol + table top → extension controlatérale MARQUÉE
// (bras + jambe opposée se TENDENT clairement vers les extrémités du viewbox).
// Refonte v2 : contraste controlatéral plus prononcé pour différencier les frames.
import SwiftUI

struct DeadBugIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)

            // Sol matelas pointillé y=40 (corps couché dessus)
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 40 * s))
            ground.addLine(to: CGPoint(x: 44 * s, y: 40 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Tête (à gauche, sur le sol)
            let headSize: CGFloat = 6 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: 8 * s - headSize / 2, y: 36 * s - headSize / 2,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc allongé horizontal au sol (épaule → bassin sur y=36)
            var trunk = Path()
            trunk.move(to: CGPoint(x: 12 * s, y: 36 * s))
            trunk.addLine(to: CGPoint(x: 30 * s, y: 36 * s))
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            switch frame {
            case 0:
                // Position de départ — TOUS les membres au ciel (table top + bras vertical)
                var armL = Path()
                armL.move(to: CGPoint(x: 12 * s, y: 36 * s))     // épaule
                armL.addLine(to: CGPoint(x: 12 * s, y: 18 * s))  // main au ciel
                ctx.stroke(armL, with: .color(silhouette), style: stroke)
                var armR = Path()
                armR.move(to: CGPoint(x: 14 * s, y: 36 * s))
                armR.addLine(to: CGPoint(x: 14 * s, y: 18 * s))
                ctx.stroke(armR, with: .color(silhouette), style: stroke)

                // Jambes en table top (cuisses verticales)
                var legL = Path()
                legL.move(to: CGPoint(x: 28 * s, y: 36 * s))
                legL.addLine(to: CGPoint(x: 28 * s, y: 22 * s))  // genoux ciel
                legL.addLine(to: CGPoint(x: 22 * s, y: 22 * s))  // tibias horizontaux gauche
                ctx.stroke(legL, with: .color(silhouette), style: stroke)
                var legR = Path()
                legR.move(to: CGPoint(x: 30 * s, y: 36 * s))
                legR.addLine(to: CGPoint(x: 30 * s, y: 22 * s))
                legR.addLine(to: CGPoint(x: 36 * s, y: 22 * s)) // tibias horizontaux droite
                ctx.stroke(legR, with: .color(silhouette), style: stroke)

            case 1:
                // Mi-extension controlatérale — bras GAUCHE et jambe DROITE s'étendent
                // Bras gauche EN HAUT (tendu en arrière au-dessus de la tête)
                var armActive = Path()
                armActive.move(to: CGPoint(x: 12 * s, y: 36 * s))
                armActive.addLine(to: CGPoint(x: 8 * s, y: 24 * s))   // s'étend en arrière
                ctx.stroke(armActive, with: .color(silhouette), style: stroke)

                // Bras droit RESTE table top vertical
                var armStable = Path()
                armStable.move(to: CGPoint(x: 14 * s, y: 36 * s))
                armStable.addLine(to: CGPoint(x: 14 * s, y: 22 * s))
                ctx.stroke(armStable, with: .color(silhouette), style: stroke)

                // Jambe droite TENDUE en bas-droite (extension)
                var legActive = Path()
                legActive.move(to: CGPoint(x: 30 * s, y: 36 * s))
                legActive.addLine(to: CGPoint(x: 38 * s, y: 32 * s))
                legActive.addLine(to: CGPoint(x: 42 * s, y: 30 * s))
                ctx.stroke(legActive, with: .color(silhouette), style: stroke)

                // Jambe gauche RESTE table top
                var legStable = Path()
                legStable.move(to: CGPoint(x: 28 * s, y: 36 * s))
                legStable.addLine(to: CGPoint(x: 28 * s, y: 22 * s))
                legStable.addLine(to: CGPoint(x: 22 * s, y: 22 * s))
                ctx.stroke(legStable, with: .color(silhouette), style: stroke)

            default:
                // Extension MAX controlatérale — bras gauche TENDU bas (en arrière)
                // + jambe droite TENDUE haut (vers le ciel)
                var armActive = Path()
                armActive.move(to: CGPoint(x: 12 * s, y: 36 * s))
                armActive.addLine(to: CGPoint(x: 4 * s, y: 30 * s))   // tendu en arrière proche tête
                ctx.stroke(armActive, with: .color(silhouette), style: stroke)

                var armStable = Path()
                armStable.move(to: CGPoint(x: 14 * s, y: 36 * s))
                armStable.addLine(to: CGPoint(x: 14 * s, y: 22 * s))
                ctx.stroke(armStable, with: .color(silhouette), style: stroke)

                // Jambe droite TENDUE à l'horizontale (signature opposition complète)
                var legActive = Path()
                legActive.move(to: CGPoint(x: 30 * s, y: 36 * s))
                legActive.addLine(to: CGPoint(x: 44 * s, y: 34 * s))   // tendue presque horizontale
                ctx.stroke(legActive, with: .color(silhouette), style: stroke)

                var legStable = Path()
                legStable.move(to: CGPoint(x: 28 * s, y: 36 * s))
                legStable.addLine(to: CGPoint(x: 28 * s, y: 22 * s))
                legStable.addLine(to: CGPoint(x: 22 * s, y: 22 * s))
                ctx.stroke(legStable, with: .color(silhouette), style: stroke)

                // Marqueurs flèche extension orange (signal allongement actif)
                var arrowArm = Path()
                arrowArm.move(to: CGPoint(x: 6 * s, y: 28 * s))
                arrowArm.addLine(to: CGPoint(x: 4 * s, y: 30 * s))
                arrowArm.addLine(to: CGPoint(x: 6 * s, y: 32 * s))
                ctx.stroke(arrowArm, with: .color(IllustrationStyle.movementArrow),
                           style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))
                var arrowLeg = Path()
                arrowLeg.move(to: CGPoint(x: 42 * s, y: 32 * s))
                arrowLeg.addLine(to: CGPoint(x: 44 * s, y: 34 * s))
                arrowLeg.addLine(to: CGPoint(x: 42 * s, y: 36 * s))
                ctx.stroke(arrowLeg, with: .color(IllustrationStyle.movementArrow),
                           style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Dead-bug v2") {
    HStack(spacing: 4) {
        DeadBugIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        DeadBugIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        DeadBugIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
