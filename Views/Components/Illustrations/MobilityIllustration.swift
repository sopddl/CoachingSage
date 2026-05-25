// Views/Components/Illustrations/MobilityIllustration.swift
// Story 3.19 Jalon 2a — étirement statique 1 frame + annotations.
// Refonte Story 3.23 Lot 1 (2026-05-25) : pied tiré au fessier (hauteur hanche
// DERRIÈRE le tronc) avec main qui forme une boucle fermée pied-main. Arc orange
// repositionné sur la cuisse étirée (zone quadriceps = avant cuisse).
//
// Choix : étirement quadriceps debout (jambe pliée derrière, main qui tient le pied).
// Reconnaissable + universel. Viewbox statique 80×48.
import SwiftUI

struct MobilityIllustration: View {
    let sportCode: String

    var body: some View {
        Canvas { ctx, size in
            let sx = size.width / IllustrationStyle.staticFrameSize.width
            let sy = size.height / IllustrationStyle.staticFrameSize.height
            let s = min(sx, sy)
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)

            // Sol pointillé
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 76 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Personnage face à gauche, jambe étirée bien ÉCARTÉE en arrière à droite.
            // Décalage horizontal franc pour que les 2 jambes ne se confondent pas.
            let standX: CGFloat = 28 * s    // jambe d'appui décalée à gauche
            let headSize: CGFloat = 6 * s
            let topOfHeadY: CGFloat = 7 * s
            let shoulderY: CGFloat = topOfHeadY + headSize    // 13
            let hipY: CGFloat = 26 * s

            // Tête
            ctx.stroke(
                Path(ellipseIn: CGRect(x: standX - headSize / 2, y: topOfHeadY,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc droit
            var trunk = Path()
            trunk.move(to: CGPoint(x: standX, y: shoulderY))
            trunk.addLine(to: CGPoint(x: standX, y: hipY))
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Jambe d'appui (verticale, pied au sol)
            var standLeg = Path()
            standLeg.move(to: CGPoint(x: standX, y: hipY))
            standLeg.addLine(to: CGPoint(x: standX, y: 46 * s))
            ctx.stroke(standLeg, with: .color(silhouette), style: stroke)

            // Jambe étirée signature : cuisse part FRANCHEMENT à droite (≥ 14s d'écart
            // par rapport à la jambe d'appui), tibia remonte vers le fessier.
            // Genou bien à droite + bas, pied à hauteur de hanche derrière le tronc.
            let kneeX: CGFloat = standX + 18 * s    // 46 — bien à droite, séparé visuellement
            let kneeY: CGFloat = 38 * s
            let footX: CGFloat = standX + 14 * s    // 42 — pied collé fessier (au-dessus)
            let footY: CGFloat = hipY + 2 * s       // 28 — légèrement sous la hanche

            var stretchLeg = Path()
            stretchLeg.move(to: CGPoint(x: standX + 1 * s, y: hipY))
            stretchLeg.addLine(to: CGPoint(x: kneeX, y: kneeY))
            stretchLeg.addLine(to: CGPoint(x: footX, y: footY))
            ctx.stroke(stretchLeg, with: .color(silhouette), style: stroke)

            // Bras gauche LIBRE (devant pour équilibre, légèrement levé)
            var freeArm = Path()
            freeArm.move(to: CGPoint(x: standX - 2 * s, y: shoulderY + 1 * s))
            freeArm.addLine(to: CGPoint(x: standX - 8 * s, y: hipY))
            ctx.stroke(freeArm, with: .color(silhouette), style: stroke)

            // Bras droit SIGNATURE : épaule → coude en arrière-haut → main qui rejoint
            // exactement le pied (boucle fermée main-pied à hauteur fessier).
            var graspArm = Path()
            graspArm.move(to: CGPoint(x: standX + 2 * s, y: shoulderY + 1 * s))
            graspArm.addLine(to: CGPoint(x: standX + 10 * s, y: 20 * s))
            graspArm.addLine(to: CGPoint(x: footX, y: footY))
            ctx.stroke(graspArm, with: .color(silhouette), style: stroke)

            // Marqueur visuel "main saisit pied" : petit cercle au point de jonction.
            // Anti-ambigüité signalée par review novice (signature manquante = ce geste).
            let graspSize: CGFloat = 3 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: footX - graspSize / 2, y: footY - graspSize / 2,
                                        width: graspSize, height: graspSize)),
                with: .color(silhouette), style: stroke
            )

            // Annotation étirement : arc orange pointillé sur la cuisse étirée
            // (zone quadriceps = avant cuisse). Centré sur le milieu cuisse.
            var stretchArc = Path()
            stretchArc.addArc(center: CGPoint(x: (standX + kneeX) / 2 + 2 * s, y: 34 * s),
                              radius: 4 * s,
                              startAngle: .degrees(200),
                              endAngle: .degrees(340),
                              clockwise: false)
            ctx.stroke(stretchArc, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, dash: [3 * s, 2 * s]))
        }
        .frame(width: IllustrationStyle.staticFrameSize.width,
               height: IllustrationStyle.staticFrameSize.height)
    }
}

#if DEBUG
#Preview("Mobility — étirement quadriceps") {
    MobilityIllustration(sportCode: "strengthTraining")
        .padding()
        .background(Color.coachingBackground)
}
#endif
