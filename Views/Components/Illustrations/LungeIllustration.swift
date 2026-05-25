// Views/Components/Illustrations/LungeIllustration.swift
// Story 3.19 Jalon 2a — fente avant 3 frames.
// Refonte Story 3.23 Lot 1 (2026-05-25) : pieds AVANT + ARRIÈRE fixes sur les 3
// frames (split-stance dès frame 0), hanche seule descend → 3 frames lus comme
// la même personne qui s'enfonce verticalement.
// Source : https://en.wikipedia.org/wiki/Lunge_(exercise)
//
// Frame 0 : split-stance départ (jambes tendues, pied avant déjà avancé d'un pas)
// Frame 1 : descente intermédiaire (genou avant ~110°, hanche à mi-course)
// Frame 2 : fente complète (genou avant 90°, genou arrière proche sol)
import SwiftUI

struct LungeIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)

            // Sol pointillé
            var ground = Path()
            ground.move(to: CGPoint(x: 2 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 46 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Pieds FIXES sur les 3 frames (signature : split-stance dès le départ)
            let frontFootX: CGFloat = 32 * s
            let frontFootY: CGFloat = 46 * s
            let backFootX: CGFloat = 14 * s
            let backFootY: CGFloat = 46 * s

            // Hanche descend selon depth (signature : seul élément qui bouge verticalement)
            let depth: CGFloat
            switch frame {
            case 0: depth = 0.0   // jambes tendues
            case 1: depth = 0.5   // descente intermédiaire
            default: depth = 1.0  // fente complète
            }
            let hipX: CGFloat = 23 * s
            let hipY: CGFloat = (26 + 12 * depth) * s   // 26 → 32 → 38

            // Lean tronc avant proportionnel à la descente
            let leanRad: CGFloat = depth * 10 * .pi / 180
            let trunkLen: CGFloat = 12 * s
            let shoulderX = hipX - sin(leanRad) * trunkLen
            let shoulderY = hipY - cos(leanRad) * trunkLen

            // Tête
            let headSize: CGFloat = 6 * s
            let headCenterX = shoulderX
            let headCenterY = shoulderY - headSize / 2 - 1 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: headCenterX - headSize / 2, y: headCenterY - headSize / 2,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc (épaule → hanche)
            var trunk = Path()
            trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
            trunk.addLine(to: CGPoint(x: hipX, y: hipY))
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Jambe AVANT (hanche → genou aligné au-dessus du pied avant → pied avant fixe)
            // En frame 0 jambe quasi-tendue ; en frame 2 cuisse quasi-horizontale.
            let frontKneeX: CGFloat = frontFootX
            let frontKneeY: CGFloat = (hipY + frontFootY) / 2 + depth * 2 * s
            var frontLeg = Path()
            frontLeg.move(to: CGPoint(x: hipX, y: hipY))
            frontLeg.addLine(to: CGPoint(x: frontKneeX, y: frontKneeY))
            frontLeg.addLine(to: CGPoint(x: frontFootX, y: frontFootY))
            ctx.stroke(frontLeg, with: .color(silhouette), style: stroke)

            // Jambe ARRIÈRE (hanche → genou intermédiaire → pied arrière fixe)
            // En frame 0 tendue, en frame 2 genou descend presque au sol.
            let backKneeX: CGFloat = (hipX + backFootX) / 2
            let backKneeY: CGFloat = hipY + 6 * s + depth * 5 * s   // 26→32 puis 38→45
            var backLeg = Path()
            backLeg.move(to: CGPoint(x: hipX, y: hipY))
            backLeg.addLine(to: CGPoint(x: backKneeX, y: backKneeY))
            backLeg.addLine(to: CGPoint(x: backFootX, y: backFootY))
            ctx.stroke(backLeg, with: .color(silhouette), style: stroke)

            // Bras pendants (mains au niveau des hanches)
            var armL = Path()
            armL.move(to: CGPoint(x: shoulderX - 2 * s, y: shoulderY + 1 * s))
            armL.addLine(to: CGPoint(x: shoulderX - 3 * s, y: hipY + 1 * s))
            ctx.stroke(armL, with: .color(silhouette), style: stroke)

            var armR = Path()
            armR.move(to: CGPoint(x: shoulderX + 2 * s, y: shoulderY + 1 * s))
            armR.addLine(to: CGPoint(x: shoulderX + 3 * s, y: hipY + 1 * s))
            ctx.stroke(armR, with: .color(silhouette), style: stroke)
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
