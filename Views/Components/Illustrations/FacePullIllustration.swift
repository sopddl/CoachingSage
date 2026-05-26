// Views/Components/Illustrations/FacePullIllustration.swift
// Story 3.23 Lot 5 v2 — Face pull câble 3 frames, viewbox 48×48.
// Source : https://en.wikipedia.org/wiki/Face_pull
// Signature v2 : vue FACE + câble pointillé DESCENDANT du HAUT + corde V à 2
// brins + 3 frames mains qui MONTENT vers le visage (coudes hauts à hauteur
// oreilles). Refonte v2 : bras MONTENT (et non bas) — signature critique.
import SwiftUI

struct FacePullIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)

            // Sol pointillé
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 44 * s))
            ground.addLine(to: CGPoint(x: 44 * s, y: 44 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Poulie HAUT (signature)
            var pulley = Path()
            pulley.addRect(CGRect(x: 22 * s, y: 2 * s, width: 4 * s, height: 4 * s))
            ctx.stroke(pulley, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))

            // Position mains/coudes selon frame (les BRAS MONTENT — signature critique v2)
            let elbowX_L: CGFloat
            let elbowY_L: CGFloat
            let handX_L: CGFloat
            let handY_L: CGFloat
            let elbowX_R: CGFloat
            let elbowY_R: CGFloat
            let handX_R: CGFloat
            let handY_R: CGFloat
            switch frame {
            case 0:
                // Départ : bras tendus DEVANT (hauteur épaule, mains près centre, bras vers la poulie)
                elbowX_L = 18 * s; elbowY_L = 22 * s; handX_L = 22 * s; handY_L = 16 * s
                elbowX_R = 30 * s; elbowY_R = 22 * s; handX_R = 26 * s; handY_R = 16 * s
            case 1:
                // Mi-tirage : coudes commencent à s'écarter, mains montent vers le front
                elbowX_L = 14 * s; elbowY_L = 18 * s; handX_L = 20 * s; handY_L = 14 * s
                elbowX_R = 34 * s; elbowY_R = 18 * s; handX_R = 28 * s; handY_R = 14 * s
            default:
                // Tirage max : COUDES HAUTS à hauteur oreilles, mains près des tempes
                elbowX_L = 10 * s; elbowY_L = 14 * s; handX_L = 18 * s; handY_L = 14 * s
                elbowX_R = 38 * s; elbowY_R = 14 * s; handX_R = 30 * s; handY_R = 14 * s
            }

            // Câble principal pointillé (poulie → noeud corde V)
            let cordeY: CGFloat = (handY_L + handY_R) / 2 + 2 * s
            var cable = Path()
            cable.move(to: CGPoint(x: 24 * s, y: 6 * s))
            cable.addLine(to: CGPoint(x: 24 * s, y: cordeY))
            ctx.stroke(cable, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: 1.2 * s, dash: [2 * s, 1.5 * s]))

            // Corde V à 2 brins (signature)
            var cordeV = Path()
            cordeV.move(to: CGPoint(x: 24 * s, y: cordeY))
            cordeV.addLine(to: CGPoint(x: handX_L, y: handY_L))
            cordeV.move(to: CGPoint(x: 24 * s, y: cordeY))
            cordeV.addLine(to: CGPoint(x: handX_R, y: handY_R))
            ctx.stroke(cordeV, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: 1.2 * s, dash: [2 * s, 1.5 * s]))

            // Tête vue de face
            let headSize: CGFloat = 6 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: 24 * s - headSize / 2, y: 15 * s,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc vertical (signature pas de penchement)
            var trunk = Path()
            trunk.move(to: CGPoint(x: 24 * s, y: 22 * s))    // épaules
            trunk.addLine(to: CGPoint(x: 24 * s, y: 34 * s)) // bassin
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Épaules
            var shoulders = Path()
            shoulders.move(to: CGPoint(x: 20 * s, y: 22 * s))
            shoulders.addLine(to: CGPoint(x: 28 * s, y: 22 * s))
            ctx.stroke(shoulders, with: .color(silhouette), style: stroke)

            // Jambes vue face
            var legL = Path()
            legL.move(to: CGPoint(x: 22 * s, y: 34 * s))
            legL.addLine(to: CGPoint(x: 22 * s, y: 44 * s))
            ctx.stroke(legL, with: .color(silhouette), style: stroke)
            var legR = Path()
            legR.move(to: CGPoint(x: 26 * s, y: 34 * s))
            legR.addLine(to: CGPoint(x: 26 * s, y: 44 * s))
            ctx.stroke(legR, with: .color(silhouette), style: stroke)

            // Bras gauche (épaule → coude → main qui MONTE vers visage)
            var armL = Path()
            armL.move(to: CGPoint(x: 20 * s, y: 22 * s))
            armL.addLine(to: CGPoint(x: elbowX_L, y: elbowY_L))
            armL.addLine(to: CGPoint(x: handX_L, y: handY_L))
            ctx.stroke(armL, with: .color(silhouette), style: stroke)

            // Bras droit (symétrique)
            var armR = Path()
            armR.move(to: CGPoint(x: 28 * s, y: 22 * s))
            armR.addLine(to: CGPoint(x: elbowX_R, y: elbowY_R))
            armR.addLine(to: CGPoint(x: handX_R, y: handY_R))
            ctx.stroke(armR, with: .color(silhouette), style: stroke)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Face pull v2") {
    HStack(spacing: 4) {
        FacePullIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        FacePullIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        FacePullIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
