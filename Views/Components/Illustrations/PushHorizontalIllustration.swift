// Views/Components/Illustrations/PushHorizontalIllustration.swift
// Story 3.19 Jalon 2a — pompe / bench press 3 frames vue de PROFIL.
// Grille didactique : mains au sol fixes (ancrage), corps qui descend/remonte
// en pompe (vs montagne russe verticale). Sol pointillé en bas.
//
// Frame 0 : position haute (bras tendus, corps droit aligné en pompe)
// Frame 1 : descente (coudes pliés à 90°)
// Frame 2 : position basse (poitrine près du sol, coudes très pliés)
import SwiftUI

struct PushHorizontalIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)

            // Sol pointillé fixe en bas (ancrage référentiel)
            var ground = Path()
            ground.move(to: CGPoint(x: 2 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 46 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Mains au sol FIXES (pivot fixe pour les bras)
            let handX: CGFloat = 38 * s
            let handY: CGFloat = 46 * s

            // Pieds au sol FIXES (orteils côté gauche)
            let toeX: CGFloat = 6 * s
            let toeY: CGFloat = 46 * s

            // Position du corps selon frame
            // Hauteur du corps au-dessus du sol (épaule) :
            // Frame 0 : épaule haut (bras tendus presque verticaux)
            // Frame 1 : épaule mi-haut (coudes pliés ~90°)
            // Frame 2 : épaule basse (poitrine près du sol)
            let shoulderY: CGFloat
            switch frame {
            case 0: shoulderY = 22 * s
            case 1: shoulderY = 32 * s
            default: shoulderY = 40 * s
            }

            // Le corps est aligné en planche entre épaule et talons
            let shoulderX: CGFloat = handX - 2 * s // légèrement derrière les mains
            // hanche, genou, talon → on garde le corps droit (alignement plank)
            // Les coordonnées sont sur un AXE OBLIQUE entre épaule (handX-2, shoulderY)
            // et toe (toeX, toeY). On distribue le corps proportionnellement.

            let bodyVecX = toeX - shoulderX
            let bodyVecY = toeY - shoulderY

            // Distribution : tronc 35% / cuisse 35% / tibia 30% (le corps n'est pas
            // un segment unique, on a hanche / genou / talon comme points charnières)
            let hipX = shoulderX + bodyVecX * 0.35
            let hipY = shoulderY + bodyVecY * 0.35
            let kneeX = shoulderX + bodyVecX * 0.70
            let kneeY = shoulderY + bodyVecY * 0.70

            // Tête (cercle) au bout du tronc, à l'opposé de la hanche
            // Vecteur perpendiculaire à l'axe corps pour avoir une tête "en avant"
            let headDistance: CGFloat = 4 * s
            let bodyLen = sqrt(bodyVecX * bodyVecX + bodyVecY * bodyVecY)
            let unitX = bodyVecX / bodyLen
            let unitY = bodyVecY / bodyLen
            // Tête prolonge l'axe corps au-delà de l'épaule (côté droit)
            let headCenterX = shoulderX - unitX * headDistance
            let headCenterY = shoulderY - unitY * headDistance
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

            // Cuisse + tibia (hanche → genou → talon)
            var legs = Path()
            legs.move(to: CGPoint(x: hipX, y: hipY))
            legs.addLine(to: CGPoint(x: kneeX, y: kneeY))
            legs.addLine(to: CGPoint(x: toeX, y: toeY))
            ctx.stroke(legs, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Bras (épaule → coude → main au sol). Le coude est plié selon
            // la distance épaule-main. En frame 2, le coude sort très vers
            // l'arrière (~horizontal au sol). En frame 0, bras presque droit.
            let armReach = handY - shoulderY // distance verticale épaule→sol
            // Plus le corps descend, plus le coude sort sur le côté (vers la droite, behind hand)
            let elbowOutset = max(0, (24 * s - armReach)) * 0.6
            let elbowX = handX + elbowOutset
            // Coude entre épaule et main, légèrement décalé vers l'extérieur
            let elbowY = (shoulderY + handY) / 2

            var arm = Path()
            arm.move(to: CGPoint(x: shoulderX, y: shoulderY))
            arm.addLine(to: CGPoint(x: elbowX, y: elbowY))
            arm.addLine(to: CGPoint(x: handX, y: handY))
            ctx.stroke(arm, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("PushHorizontal — pompe 3 frames") {
    HStack(spacing: 4) {
        PushHorizontalIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PushHorizontalIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PushHorizontalIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
