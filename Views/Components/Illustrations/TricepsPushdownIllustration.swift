// Views/Components/Illustrations/TricepsPushdownIllustration.swift
// Story 3.23 Lot 7 — Triceps pushdown câble 3 frames, viewbox 48×48.
// Source : https://en.wikipedia.org/wiki/Pushdown
// Signature : vue PROFIL + câble pointillé HAUT + coudes COLLÉS au tronc fixes
// + avant-bras qui DESCENDENT (extension coude). Différenciation Face pull = MONTE.
import SwiftUI

struct TricepsPushdownIllustration: View {
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

            // Poulie HAUT (équipement)
            var pulley = Path()
            pulley.addRect(CGRect(x: 22 * s, y: 2 * s, width: 4 * s, height: 4 * s))
            ctx.stroke(pulley, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))

            // Silhouette debout profil (invariante)
            let cx: CGFloat = 24 * s
            let headSize: CGFloat = 6 * s

            // Tête
            ctx.stroke(
                Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 9 * s,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc vertical
            var trunk = Path()
            trunk.move(to: CGPoint(x: cx, y: 15 * s))
            trunk.addLine(to: CGPoint(x: 23 * s, y: 32 * s))
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Jambes
            var legs = Path()
            legs.move(to: CGPoint(x: 23 * s, y: 32 * s))
            legs.addLine(to: CGPoint(x: 22 * s, y: 44 * s))
            ctx.stroke(legs, with: .color(silhouette), style: stroke)

            // Pieds
            var feet = Path()
            feet.move(to: CGPoint(x: 20 * s, y: 44 * s))
            feet.addLine(to: CGPoint(x: 28 * s, y: 44 * s))
            ctx.stroke(feet, with: .color(silhouette), style: stroke)

            // Épaule + coude FIXE (signature triceps — coudes collés au tronc)
            let shoulderX: CGFloat = cx
            let shoulderY: CGFloat = 19 * s
            let elbowX: CGFloat = 25 * s
            let elbowY: CGFloat = 27 * s

            // Poignet (extrémité avant-bras) — varie selon frame
            let wristX: CGFloat
            let wristY: CGFloat
            switch frame {
            case 0:
                // Start coude 90° — avant-bras horizontal vers l'avant
                wristX = 30 * s; wristY = 23 * s
            case 1:
                // Mid coude 135° — avant-bras oblique
                wristX = 29 * s; wristY = 31 * s
            default:
                // End coude 180° verrouillé — avant-bras vertical le long cuisse
                wristX = 26 * s; wristY = 36 * s
            }

            // Bras = épaule → coude FIXE → poignet (signature pure extension coude)
            var arm = Path()
            arm.move(to: CGPoint(x: shoulderX, y: shoulderY))
            arm.addLine(to: CGPoint(x: elbowX, y: elbowY))
            arm.addLine(to: CGPoint(x: wristX, y: wristY))
            ctx.stroke(arm, with: .color(silhouette), style: stroke)

            // Câble pointillé poulie → poignet (signature triceps)
            var cable = Path()
            cable.move(to: CGPoint(x: 24 * s, y: 6 * s))
            cable.addLine(to: CGPoint(x: wristX, y: wristY))
            ctx.stroke(cable, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: 1.2 * s, dash: [2 * s, 1.5 * s]))

            // Poignée perpendiculaire au câble (segment court au point poignet)
            var grip = Path()
            grip.move(to: CGPoint(x: wristX - 2 * s, y: wristY + 1 * s))
            grip.addLine(to: CGPoint(x: wristX + 2 * s, y: wristY + 1 * s))
            ctx.stroke(grip, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Triceps pushdown") {
    HStack(spacing: 4) {
        TricepsPushdownIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        TricepsPushdownIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        TricepsPushdownIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
