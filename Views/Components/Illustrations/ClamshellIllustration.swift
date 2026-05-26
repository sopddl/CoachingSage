// Views/Components/Illustrations/ClamshellIllustration.swift
// Story 3.23 Lot 5 v2 — Clamshell glute med 3 frames, viewbox 48×48.
// Source : https://en.wikipedia.org/wiki/Clamshell_(exercise)
// Signature v2 : silhouette HORIZONTALE couchée sur le côté (corps allongé
// horizontal au sol) + jambes pliées 90° + pieds joints + ouverture genou haut.
// Refonte v2 : passage horizontal (vs vertical v1 qui était illisible).
import SwiftUI

struct ClamshellIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)

            // Sol matelas y=40 (le corps est couché DESSUS)
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 40 * s))
            ground.addLine(to: CGPoint(x: 44 * s, y: 40 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Tête à gauche (couchée sur le côté, posée sur le sol)
            let headSize: CGFloat = 6 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: 8 * s - headSize / 2, y: 32 * s - headSize / 2,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc allongé horizontal (épaule → bassin sur y=32)
            var trunk = Path()
            trunk.move(to: CGPoint(x: 12 * s, y: 32 * s))    // épaule (cou + tête à gauche)
            trunk.addLine(to: CGPoint(x: 28 * s, y: 32 * s)) // bassin (hanche au milieu)
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Bras (replié sous la tête pour appui — coussin)
            var arm = Path()
            arm.move(to: CGPoint(x: 12 * s, y: 32 * s))
            arm.addLine(to: CGPoint(x: 6 * s, y: 36 * s))
            arm.addLine(to: CGPoint(x: 8 * s, y: 28 * s))
            ctx.stroke(arm, with: .color(silhouette), style: stroke)

            // Cuisse + tibia BAS (collés au sol — toujours horizontal)
            // hanche (28, 32) → genou bas (34, 38) → pied (38, 40)
            var legBot = Path()
            legBot.move(to: CGPoint(x: 28 * s, y: 32 * s))      // hanche
            legBot.addLine(to: CGPoint(x: 34 * s, y: 38 * s))   // genou bas
            legBot.addLine(to: CGPoint(x: 38 * s, y: 40 * s))   // pied au sol
            ctx.stroke(legBot, with: .color(silhouette), style: stroke)

            // Cuisse + tibia HAUT — varie selon frame (SIGNATURE ouverture)
            let kneeTopX: CGFloat
            let kneeTopY: CGFloat
            switch frame {
            case 0:
                // Fermé : genou haut superposé au genou bas
                kneeTopX = 34 * s; kneeTopY = 38 * s
            case 1:
                // Mi-ouverture : genou s'élève vers le haut
                kneeTopX = 32 * s; kneeTopY = 28 * s
            default:
                // Ouverture max : genou bien levé vers le haut (coquillage ouvert)
                kneeTopX = 30 * s; kneeTopY = 18 * s
            }
            var legTop = Path()
            legTop.move(to: CGPoint(x: 28 * s, y: 32 * s))
            legTop.addLine(to: CGPoint(x: kneeTopX, y: kneeTopY))   // genou s'ouvre vers le haut
            legTop.addLine(to: CGPoint(x: 38 * s, y: 40 * s))         // pied reste joint
            ctx.stroke(legTop, with: .color(silhouette), style: stroke)

            // Marqueur pieds joints (mini cercle signature)
            let footSize: CGFloat = 3 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: 38 * s - footSize / 2, y: 40 * s - footSize / 2,
                                        width: footSize, height: footSize)),
                with: .color(silhouette), style: stroke
            )

            // Flèche ouverture mid + max (signal mouvement vers le haut)
            if frame > 0 {
                var arrow = Path()
                arrow.move(to: CGPoint(x: 34 * s, y: 36 * s))
                arrow.addLine(to: CGPoint(x: kneeTopX, y: kneeTopY + 2 * s))
                arrow.move(to: CGPoint(x: kneeTopX - 1 * s, y: kneeTopY + 4 * s))
                arrow.addLine(to: CGPoint(x: kneeTopX, y: kneeTopY + 2 * s))
                arrow.addLine(to: CGPoint(x: kneeTopX + 1.5 * s, y: kneeTopY + 4 * s))
                ctx.stroke(arrow, with: .color(IllustrationStyle.movementArrow),
                           style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round))
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Clamshell — glute med (v2 horizontal)") {
    HStack(spacing: 4) {
        ClamshellIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        ClamshellIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        ClamshellIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
