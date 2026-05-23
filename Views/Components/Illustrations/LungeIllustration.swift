// Views/Components/Illustrations/LungeIllustration.swift
// Story 3.19 Jalon 2a — fente avant 3 frames.
// Grille didactique : pied AVANT FIXE au sol (ancrage). L'autre jambe arrière
// recule + descend en flexion. Le tronc reste droit, hanche descend.
//
// Frame 0 : debout pieds joints (départ)
// Frame 1 : grande fente arrière (jambe arrière reculée, genou avant à ~120°)
// Frame 2 : fente fond (genou arrière proche du sol, fente profonde)
import SwiftUI

struct LungeIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)

            // Sol pointillé
            var ground = Path()
            ground.move(to: CGPoint(x: 2 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 46 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Pied AVANT FIXE (ancrage) — côté droit
            let frontFootX: CGFloat = 30 * s
            let frontFootY: CGFloat = 46 * s

            // Position selon frame
            let depth: CGFloat
            let backFootDistance: CGFloat
            switch frame {
            case 0: depth = 0.0; backFootDistance = 0   // pieds joints
            case 1: depth = 0.5; backFootDistance = 14 * s
            default: depth = 1.0; backFootDistance = 18 * s
            }

            // Pied arrière (recule + monte légèrement quand fente profonde — pointe d'appui)
            let backFootX: CGFloat = frontFootX - backFootDistance
            let backFootY: CGFloat = frontFootY - depth * 1 * s

            // Hauteur hanche selon depth (descend dans la fente)
            // En frame 0 : hanche en hauteur normale debout (~26s)
            // En frame 2 : hanche descendue (~36s)
            let hipY: CGFloat = (26 + 8 * depth) * s
            let hipX: CGFloat = frontFootX - 4 * depth * s // hanche entre les 2 pieds quand fente

            // Tête + tronc (droit, légèrement penché vers l'avant en fente profonde)
            let trunkLen: CGFloat = 12 * s
            let headSize: CGFloat = 6 * s
            let leanRad: CGFloat = depth * 5 * .pi / 180 // léger lean avant en fente
            let shoulderX = hipX - sin(leanRad) * trunkLen
            let shoulderY = hipY - cos(leanRad) * trunkLen
            let headCenterX = shoulderX
            let headCenterY = shoulderY - headSize / 2 - 1 * s

            ctx.stroke(
                Path(ellipseIn: CGRect(x: headCenterX - headSize / 2, y: headCenterY - headSize / 2,
                                        width: headSize, height: headSize)),
                with: .color(IllustrationStyle.silhouette(sportCode: sportCode)),
                style: stroke
            )

            // Tronc (épaule → hanche)
            var trunk = Path()
            trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
            trunk.addLine(to: CGPoint(x: hipX, y: hipY))
            ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Jambe AVANT (hanche → genou avant → pied avant fixe)
            // Genou avant aligné au-dessus du pied avant (verticalement)
            let frontKneeX: CGFloat = frontFootX
            let frontKneeY: CGFloat = (hipY + frontFootY) / 2
            var frontLeg = Path()
            frontLeg.move(to: CGPoint(x: hipX, y: hipY))
            frontLeg.addLine(to: CGPoint(x: frontKneeX, y: frontKneeY))
            frontLeg.addLine(to: CGPoint(x: frontFootX, y: frontFootY))
            ctx.stroke(frontLeg, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Jambe ARRIÈRE (hanche → genou arrière → pied arrière)
            // En frame 0 : pas de fente — jambe identique à la jambe avant (pieds joints)
            // En frame 2 : genou arrière proche du sol (~44s)
            if backFootDistance > 0 {
                let backKneeX: CGFloat = (hipX + backFootX) / 2
                let backKneeY: CGFloat = hipY + 6 * s + depth * 4 * s
                var backLeg = Path()
                backLeg.move(to: CGPoint(x: hipX, y: hipY))
                backLeg.addLine(to: CGPoint(x: backKneeX, y: backKneeY))
                backLeg.addLine(to: CGPoint(x: backFootX, y: backFootY))
                ctx.stroke(backLeg, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
            } else {
                // Frame 0 : 2 pieds côte à côte → 2e jambe parallèle un peu décalée
                var leftLeg = Path()
                leftLeg.move(to: CGPoint(x: hipX, y: hipY))
                leftLeg.addLine(to: CGPoint(x: frontFootX - 4 * s, y: (hipY + frontFootY) / 2))
                leftLeg.addLine(to: CGPoint(x: frontFootX - 4 * s, y: frontFootY))
                ctx.stroke(leftLeg, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
            }

            // Bras pendants (mains au niveau des cuisses)
            var armL = Path()
            armL.move(to: CGPoint(x: shoulderX - 2 * s, y: shoulderY + 1 * s))
            armL.addLine(to: CGPoint(x: shoulderX - 3 * s, y: hipY + 1 * s))
            ctx.stroke(armL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            var armR = Path()
            armR.move(to: CGPoint(x: shoulderX + 2 * s, y: shoulderY + 1 * s))
            armR.addLine(to: CGPoint(x: shoulderX + 3 * s, y: hipY + 1 * s))
            ctx.stroke(armR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Lunge — fente 3 frames") {
    HStack(spacing: 4) {
        LungeIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LungeIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LungeIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
