// Views/Components/Illustrations/MobilityIllustration.swift
// Story 3.19 Jalon 2a — étirement statique 1 frame + annotations.
// Choix : étirement quadriceps (jambe pliée derrière, main qui tient le pied).
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

            // Sol pointillé
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 76 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Silhouette en équilibre sur jambe gauche, jambe droite repliée
            // en arrière (talon vers fessier), main droite qui tient le pied droit.
            // Centre humain à x=35s pour laisser place à droite pour la jambe repliée.
            let centerX: CGFloat = 35 * s
            let headSize: CGFloat = 6 * s
            let topOfHeadY: CGFloat = 8 * s
            let shoulderY: CGFloat = topOfHeadY + headSize
            let hipY: CGFloat = 26 * s

            // Tête
            ctx.stroke(
                Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: topOfHeadY,
                                        width: headSize, height: headSize)),
                with: .color(IllustrationStyle.silhouette(sportCode: sportCode)),
                style: stroke
            )

            // Tronc droit
            var trunk = Path()
            trunk.move(to: CGPoint(x: centerX, y: shoulderY))
            trunk.addLine(to: CGPoint(x: centerX, y: hipY))
            ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Jambe d'appui (gauche, droite verticale)
            var standLeg = Path()
            standLeg.move(to: CGPoint(x: centerX - 1 * s, y: hipY))
            standLeg.addLine(to: CGPoint(x: centerX - 1 * s, y: 36 * s))
            standLeg.addLine(to: CGPoint(x: centerX - 2 * s, y: 46 * s))
            ctx.stroke(standLeg, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Jambe étirée : genou pointe vers l'arrière (à droite), pied derrière
            // Cuisse : hanche → genou (à droite + très peu vers le bas)
            let kneeX: CGFloat = centerX + 8 * s
            let kneeY: CGFloat = 30 * s
            // Tibia : genou → cheville (replié vers fessier = vers le haut-gauche)
            let footX: CGFloat = centerX + 4 * s
            let footY: CGFloat = 20 * s

            var stretchLeg = Path()
            stretchLeg.move(to: CGPoint(x: centerX + 1 * s, y: hipY))
            stretchLeg.addLine(to: CGPoint(x: kneeX, y: kneeY))
            stretchLeg.addLine(to: CGPoint(x: footX, y: footY))
            ctx.stroke(stretchLeg, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Bras droit : épaule → main qui tient le pied
            // Le bras descend en arrière pour attraper le pied
            var stretchArm = Path()
            stretchArm.move(to: CGPoint(x: centerX + 2 * s, y: shoulderY + 1 * s))
            stretchArm.addLine(to: CGPoint(x: centerX + 5 * s, y: 16 * s))
            stretchArm.addLine(to: CGPoint(x: footX, y: footY - 1 * s)) // main qui tient pied
            ctx.stroke(stretchArm, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Bras gauche : pendant, en équilibre
            var freeArm = Path()
            freeArm.move(to: CGPoint(x: centerX - 2 * s, y: shoulderY + 1 * s))
            freeArm.addLine(to: CGPoint(x: centerX - 5 * s, y: hipY + 2 * s))
            ctx.stroke(freeArm, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Annotation : petite courbe orange suggérant l'étirement (à droite de la cuisse étirée)
            var stretchArc = Path()
            stretchArc.addArc(center: CGPoint(x: kneeX + 4 * s, y: 26 * s),
                              radius: 5 * s,
                              startAngle: .degrees(160),
                              endAngle: .degrees(280),
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
