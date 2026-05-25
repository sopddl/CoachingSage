// Views/Components/Illustrations/YTWActivationIllustration.swift
// Story 3.23 Lot 3 — Y-T-W shoulder activation 3 frames, viewbox 48×48 chaque.
// Source : https://en.wikipedia.org/wiki/Rotator_cuff
// Signature : vue de dessus prone, corps allongé identique, bras dessinent Y/T/W.
import SwiftUI

struct YTWActivationIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)

            // Sol pointillé (tapis allongé — bandeau bas)
            var ground = Path()
            ground.move(to: CGPoint(x: 2 * s, y: 44 * s))
            ground.addLine(to: CGPoint(x: 46 * s, y: 44 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Corps allongé prone vu de dessus (commun aux 3 frames)
            // Tête + tronc + jambes au sol, axe vertical central
            let headSize: CGFloat = 6 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: 24 * s - headSize / 2, y: 33 * s,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc vertical (épaule haut → bassin bas)
            var trunk = Path()
            trunk.move(to: CGPoint(x: 24 * s, y: 18 * s))
            trunk.addLine(to: CGPoint(x: 24 * s, y: 32 * s))
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Jambes (vues dessus, parallèles)
            var legL = Path()
            legL.move(to: CGPoint(x: 22 * s, y: 32 * s))
            legL.addLine(to: CGPoint(x: 22 * s, y: 42 * s))
            ctx.stroke(legL, with: .color(silhouette), style: stroke)
            var legR = Path()
            legR.move(to: CGPoint(x: 26 * s, y: 32 * s))
            legR.addLine(to: CGPoint(x: 26 * s, y: 42 * s))
            ctx.stroke(legR, with: .color(silhouette), style: stroke)

            // Bras — varient selon frame (signature Y/T/W)
            switch frame {
            case 0:
                // Y — bras tendus au-dessus de la tête écartés ~60°
                var armL = Path()
                armL.move(to: CGPoint(x: 22 * s, y: 18 * s))
                armL.addLine(to: CGPoint(x: 10 * s, y: 4 * s))
                ctx.stroke(armL, with: .color(silhouette), style: stroke)
                var armR = Path()
                armR.move(to: CGPoint(x: 26 * s, y: 18 * s))
                armR.addLine(to: CGPoint(x: 38 * s, y: 4 * s))
                ctx.stroke(armR, with: .color(silhouette), style: stroke)
            case 1:
                // T — bras tendus horizontaux perpendiculaires au tronc
                var armL = Path()
                armL.move(to: CGPoint(x: 22 * s, y: 18 * s))
                armL.addLine(to: CGPoint(x: 4 * s, y: 18 * s))
                ctx.stroke(armL, with: .color(silhouette), style: stroke)
                var armR = Path()
                armR.move(to: CGPoint(x: 26 * s, y: 18 * s))
                armR.addLine(to: CGPoint(x: 44 * s, y: 18 * s))
                ctx.stroke(armR, with: .color(silhouette), style: stroke)
            default:
                // W — coudes pliés à 90°, mains à hauteur d'épaules
                var armL = Path()
                armL.move(to: CGPoint(x: 22 * s, y: 18 * s))
                armL.addLine(to: CGPoint(x: 10 * s, y: 10 * s))
                armL.addLine(to: CGPoint(x: 14 * s, y: 2 * s))
                ctx.stroke(armL, with: .color(silhouette), style: stroke)
                var armR = Path()
                armR.move(to: CGPoint(x: 26 * s, y: 18 * s))
                armR.addLine(to: CGPoint(x: 38 * s, y: 10 * s))
                armR.addLine(to: CGPoint(x: 34 * s, y: 2 * s))
                ctx.stroke(armR, with: .color(silhouette), style: stroke)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Y-T-W activation") {
    HStack(spacing: 4) {
        YTWActivationIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        YTWActivationIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        YTWActivationIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
