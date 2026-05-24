// Views/Components/Illustrations/PullVerticalIllustration.swift
// Story 3.19 — pull-up / chin-up 3 frames : suspendu bras tendus → mi-traction → menton au-dessus.
// Barre fixe horizontale en haut, silhouette suspendue.
import SwiftUI

struct PullVerticalIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let strokeHeavy = StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)

            // RÉFÉRENTIEL OBSERVATEUR (Sophie 2026-05-23) : corps fixe (pieds
            // au sol, taille humaine constante), la BARRE descend visuellement
            // entre les frames pour matérialiser le geste de pull-up. C'est
            // équivalent visuellement à "corps monte vers barre fixe" et plus
            // lisible didactiquement.
            //
            // Frame 0 : barre TRÈS HAUT (loin au-dessus de la tête) — bras tendus
            // Frame 1 : barre PLUS BAS — mi-traction
            // Frame 2 : barre AU NIVEAU DU MENTON — bras pliés (finition)
            let barY: CGFloat
            switch frame {
            case 0: barY = 2 * s   // bras tendus au max
            case 1: barY = 10 * s  // mi-traction
            default: barY = 18 * s // au menton
            }

            // Corps FIXE — mêmes positions sur les 3 frames
            let centerX: CGFloat = 24 * s
            let handLX: CGFloat = 16 * s
            let handRX: CGFloat = 32 * s
            let handY: CGFloat = barY
            let headSize: CGFloat = 6 * s
            let topOfHeadY: CGFloat = 16 * s
            let shoulderY: CGFloat = topOfHeadY + headSize // 22s
            let hipY: CGFloat = 32 * s
            let kneeY: CGFloat = 40 * s
            let ankleY: CGFloat = 46 * s // pieds au sol

            // Barre fixe horizontale (longueur fixe, position verticale = barY variable)
            var bar = Path()
            bar.move(to: CGPoint(x: 6 * s, y: barY))
            bar.addLine(to: CGPoint(x: 42 * s, y: barY))
            ctx.stroke(bar, with: .color(IllustrationStyle.equipment), style: strokeHeavy)

            // Sol pointillé fixe en bas — référentiel ancrage pieds
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 44 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Tête
            ctx.stroke(
                Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: topOfHeadY,
                                        width: headSize, height: headSize)),
                with: .color(IllustrationStyle.silhouette(sportCode: sportCode)),
                style: stroke
            )

            // Tronc
            var trunk = Path()
            trunk.move(to: CGPoint(x: centerX, y: shoulderY))
            trunk.addLine(to: CGPoint(x: centerX, y: hipY))
            ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Jambes droites pendantes (ankle aligné sur les 3 frames)
            var legL = Path()
            legL.move(to: CGPoint(x: centerX, y: hipY))
            legL.addLine(to: CGPoint(x: centerX - 2 * s, y: kneeY))
            legL.addLine(to: CGPoint(x: centerX - 3 * s, y: ankleY))
            ctx.stroke(legL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            var legR = Path()
            legR.move(to: CGPoint(x: centerX, y: hipY))
            legR.addLine(to: CGPoint(x: centerX + 2 * s, y: kneeY))
            legR.addLine(to: CGPoint(x: centerX + 3 * s, y: ankleY))
            ctx.stroke(legR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Bras : épaule → coude → main sur la barre. La géométrie change
            // selon la position relative épaule/barre :
            //  - épaule BIEN SOUS barre (frame 0) : bras tendus verticaux, coude entre épaule et main.
            //  - épaule SOUS barre (frame 1) : bras mi-pliés, coude sort sur les côtés.
            //  - épaule À HAUTEUR barre (frame 2) : bras horizontaux, coude au-dessus pointant vers le ciel.
            let armReach: CGFloat = shoulderY - handY // distance verticale épaule→barre (positive = épaule sous barre)
            // Plus l'épaule s'approche de la barre, plus le coude sort sur les côtés
            let elbowOutset: CGFloat = max(0, (18 * s - armReach)) * 0.6
            // En frame 2 (armReach négatif), le coude pointe vers le HAUT (au-dessus du shoulder)
            let elbowY: CGFloat
            if armReach > 0 {
                elbowY = handY + armReach * 0.5   // coude entre épaule (en bas) et main (en haut, barre)
            } else {
                elbowY = shoulderY - 3 * s         // coude pointe vers le haut au-dessus de l'épaule
            }
            let elbowLX: CGFloat = handLX - elbowOutset
            let elbowRX: CGFloat = handRX + elbowOutset

            var armL = Path()
            armL.move(to: CGPoint(x: centerX - 1 * s, y: shoulderY))
            armL.addLine(to: CGPoint(x: elbowLX, y: elbowY))
            armL.addLine(to: CGPoint(x: handLX, y: handY))
            ctx.stroke(armL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            var armR = Path()
            armR.move(to: CGPoint(x: centerX + 1 * s, y: shoulderY))
            armR.addLine(to: CGPoint(x: elbowRX, y: elbowY))
            armR.addLine(to: CGPoint(x: handRX, y: handY))
            ctx.stroke(armR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("PullVertical 3 frames") {
    HStack(spacing: 4) {
        PullVerticalIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PullVerticalIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PullVerticalIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
