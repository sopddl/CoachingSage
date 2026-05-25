// Views/Components/Illustrations/NordicCurlIllustration.swift
// Story 3.23 Lot 3 — Nordic curl 3 frames, viewbox 48×48.
// Source : https://en.wikipedia.org/wiki/Nordic_hamstring_exercise
// Signature : tronc+cuisses = segment rigide unique pivotant au genou (genoux fixes
// au sol, pieds bloqués). Décalage pivot à x=16 pour rester dans le cadre frame 2.
import SwiftUI

struct NordicCurlIllustration: View {
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

            // Pivot genou FIXE aux 3 frames (signature)
            let kneeX: CGFloat = 16 * s
            let kneeY: CGFloat = 42 * s

            // Bloc de blocage pieds (rectangle équipement à droite des genoux)
            var block = Path()
            block.addRect(CGRect(x: 30 * s, y: 38 * s, width: 6 * s, height: 6 * s))
            ctx.stroke(block, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))

            // Pieds bloqués sous le bloc (segment talon → pointe)
            var feet = Path()
            feet.move(to: CGPoint(x: 22 * s, y: 42 * s))
            feet.addLine(to: CGPoint(x: 30 * s, y: 42 * s))
            ctx.stroke(feet, with: .color(silhouette), style: stroke)

            // Inclinaison du segment rigide tronc+cuisse selon frame
            let angleRad: CGFloat
            switch frame {
            case 0: angleRad = 0                          // vertical
            case 1: angleRad = 45 * .pi / 180             // 45°
            default: angleRad = 80 * .pi / 180            // 80° (presque horizontal, gardons cadre)
            }

            // Segment rigide longueur totale = cuisse 12 + tronc 14 = 26 unités
            let cuisseLen: CGFloat = 12 * s
            let troncLen: CGFloat = 14 * s
            let headSize: CGFloat = 6 * s

            // Bassin = jonction cuisse-tronc
            let bassinX = kneeX + cuisseLen * sin(angleRad)
            let bassinY = kneeY - cuisseLen * cos(angleRad)

            // Épaule = bout du tronc
            let shoulderX = bassinX + troncLen * sin(angleRad)
            let shoulderY = bassinY - troncLen * cos(angleRad)

            // Tête au bout
            let headX = shoulderX + (headSize / 2 + 1 * s) * sin(angleRad)
            let headY = shoulderY - (headSize / 2 + 1 * s) * cos(angleRad)

            // Cuisse (genou → bassin)
            var thigh = Path()
            thigh.move(to: CGPoint(x: kneeX, y: kneeY))
            thigh.addLine(to: CGPoint(x: bassinX, y: bassinY))
            ctx.stroke(thigh, with: .color(silhouette), style: stroke)

            // Tronc continuité rigide (bassin → épaule)
            var trunk = Path()
            trunk.move(to: CGPoint(x: bassinX, y: bassinY))
            trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Tête
            ctx.stroke(
                Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Bras pendants par gravité (depuis épaule vers le bas)
            var arm = Path()
            arm.move(to: CGPoint(x: shoulderX, y: shoulderY))
            arm.addLine(to: CGPoint(x: shoulderX + 1 * s, y: shoulderY + 8 * s))
            ctx.stroke(arm, with: .color(silhouette), style: stroke)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Nordic curl — excentrique ischio") {
    HStack(spacing: 4) {
        NordicCurlIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        NordicCurlIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        NordicCurlIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
