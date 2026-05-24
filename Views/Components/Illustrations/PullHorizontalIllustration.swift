// Views/Components/Illustrations/PullHorizontalIllustration.swift
// Story 3.19 Jalon 2a — bent-over row / rameur 3 frames.
// Grille didactique : corps FIXE penché en avant (hinge léger ~30°), pieds
// au sol. L'haltère/barre se RAPPROCHE du tronc puis s'éloigne.
//
// Frame 0 : haltère bras tendu vers le sol (position basse)
// Frame 1 : haltère mi-hauteur (en cours de tirage)
// Frame 2 : haltère au niveau du tronc (coude derrière, omoplate serrée)
import SwiftUI

struct PullHorizontalIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let strokeHeavy = StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)

            // Sol pointillé
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 44 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Corps FIXE penché en avant (hinge ~45° pour bent-over row)
            // Hanche fixe, tronc incliné vers la gauche, jambes droites
            let hipX: CGFloat = 28 * s
            let hipY: CGFloat = 26 * s
            let trunkLen: CGFloat = 14 * s
            let trunkAngleDeg: CGFloat = 50 // incliné vers la gauche (vers le bas-gauche)
            let trunkRad = trunkAngleDeg * .pi / 180

            // Épaule au bout du tronc, calculée géométriquement
            let shoulderX = hipX - sin(trunkRad) * trunkLen
            let shoulderY = hipY - cos(trunkRad) * trunkLen

            // Tête au bout du tronc (prolongée)
            let headOffset: CGFloat = 3 * s
            let headCenterX = shoulderX - sin(trunkRad) * headOffset
            let headCenterY = shoulderY - cos(trunkRad) * headOffset
            let headSize: CGFloat = 6 * s

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

            // Jambes droites (genoux légèrement fléchis)
            let kneeY: CGFloat = 36 * s
            let ankleY: CGFloat = 46 * s
            var legL = Path()
            legL.move(to: CGPoint(x: hipX - 1 * s, y: hipY))
            legL.addLine(to: CGPoint(x: hipX - 2 * s, y: kneeY))
            legL.addLine(to: CGPoint(x: hipX - 3 * s, y: ankleY))
            ctx.stroke(legL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            var legR = Path()
            legR.move(to: CGPoint(x: hipX + 1 * s, y: hipY))
            legR.addLine(to: CGPoint(x: hipX + 2 * s, y: kneeY))
            legR.addLine(to: CGPoint(x: hipX + 3 * s, y: ankleY))
            ctx.stroke(legR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // BARRE / haltère qui se rapproche du tronc selon frame
            // Frame 0 : barre bras tendu vers le bas (loin du tronc, vers le sol)
            // Frame 1 : barre mi-trajet
            // Frame 2 : barre près du tronc (sous l'épaule, près de la hanche)
            // La barre est sous le bonhomme, gravité — direction verticale
            let barProgress: CGFloat
            switch frame {
            case 0: barProgress = 0.0  // bras tendu vers le bas
            case 1: barProgress = 0.5
            default: barProgress = 1.0 // tirée près du tronc
            }

            // Main bouge sur axe vertical entre "bras tendu" et "près du tronc"
            // Bras tendu : main à shoulderY + 14s vers le sol
            // Tirée : main au niveau du tronc, sous épaule, ~shoulderY + 4s
            let handMaxY: CGFloat = shoulderY + 14 * s // bras tendu
            let handMinY: CGFloat = shoulderY + 4 * s  // tirée
            let handY: CGFloat = handMaxY - (handMaxY - handMinY) * barProgress
            let handX: CGFloat = shoulderX + 2 * s // décalé un peu à droite (latéral)

            // Coude entre épaule et main (sort un peu vers l'arrière quand bras plié)
            let elbowOutset: CGFloat = barProgress * 4 * s
            let elbowX = handX + elbowOutset
            let elbowY = (shoulderY + handY) / 2

            var arm = Path()
            arm.move(to: CGPoint(x: shoulderX, y: shoulderY))
            arm.addLine(to: CGPoint(x: elbowX, y: elbowY))
            arm.addLine(to: CGPoint(x: handX, y: handY))
            ctx.stroke(arm, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Barre horizontale (équipement) avec haltère/disques aux deux bouts
            let barHalfLen: CGFloat = 7 * s
            var bar = Path()
            bar.move(to: CGPoint(x: handX - barHalfLen, y: handY))
            bar.addLine(to: CGPoint(x: handX + barHalfLen, y: handY))
            ctx.stroke(bar, with: .color(IllustrationStyle.equipment), style: strokeHeavy)

            // Disques aux extrémités
            let plateW: CGFloat = 2 * s
            let plateH: CGFloat = 5 * s
            ctx.fill(
                Path(roundedRect: CGRect(x: handX - barHalfLen - plateW, y: handY - plateH / 2,
                                          width: plateW, height: plateH), cornerRadius: 0.5 * s),
                with: .color(IllustrationStyle.load)
            )
            ctx.fill(
                Path(roundedRect: CGRect(x: handX + barHalfLen, y: handY - plateH / 2,
                                          width: plateW, height: plateH), cornerRadius: 0.5 * s),
                with: .color(IllustrationStyle.load)
            )
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("PullHorizontal — row 3 frames") {
    HStack(spacing: 4) {
        PullHorizontalIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PullHorizontalIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PullHorizontalIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
