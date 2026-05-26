// Views/Components/Illustrations/LateralRaisesIllustration.swift
// Story 3.23 Lot 7 — Lateral raises haltères 3 frames, viewbox 48×48.
// Source : https://en.wikipedia.org/wiki/Anterior_deltoid_raise
// Signature : vue FACE + 2 haltères symétriques + bras TENDUS qui s'écartent
// latéralement jusqu'à former un T (signature deltoïdes latéraux).
import SwiftUI

struct LateralRaisesIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)
            let equipment = IllustrationStyle.equipment

            // Sol pointillé
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 44 * s))
            ground.addLine(to: CGPoint(x: 44 * s, y: 44 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Silhouette FACE invariante
            let cx: CGFloat = 24 * s
            let headSize: CGFloat = 6 * s

            // Tête
            ctx.stroke(
                Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 7 * s,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Épaules transversales
            var shoulders = Path()
            shoulders.move(to: CGPoint(x: 18 * s, y: 17 * s))
            shoulders.addLine(to: CGPoint(x: 30 * s, y: 17 * s))
            ctx.stroke(shoulders, with: .color(silhouette), style: stroke)

            // Tronc (vertical face)
            var trunkL = Path()
            trunkL.move(to: CGPoint(x: 20 * s, y: 17 * s))
            trunkL.addLine(to: CGPoint(x: 20 * s, y: 32 * s))
            ctx.stroke(trunkL, with: .color(silhouette), style: stroke)
            var trunkR = Path()
            trunkR.move(to: CGPoint(x: 28 * s, y: 17 * s))
            trunkR.addLine(to: CGPoint(x: 28 * s, y: 32 * s))
            ctx.stroke(trunkR, with: .color(silhouette), style: stroke)

            // Bassin
            var pelvis = Path()
            pelvis.move(to: CGPoint(x: 19 * s, y: 32 * s))
            pelvis.addLine(to: CGPoint(x: 29 * s, y: 32 * s))
            ctx.stroke(pelvis, with: .color(silhouette), style: stroke)

            // Jambes
            var legL = Path()
            legL.move(to: CGPoint(x: 21 * s, y: 32 * s))
            legL.addLine(to: CGPoint(x: 20 * s, y: 44 * s))
            ctx.stroke(legL, with: .color(silhouette), style: stroke)
            var legR = Path()
            legR.move(to: CGPoint(x: 27 * s, y: 32 * s))
            legR.addLine(to: CGPoint(x: 28 * s, y: 44 * s))
            ctx.stroke(legR, with: .color(silhouette), style: stroke)

            // Pieds
            var feet = Path()
            feet.move(to: CGPoint(x: 17 * s, y: 44 * s))
            feet.addLine(to: CGPoint(x: 23 * s, y: 44 * s))
            feet.move(to: CGPoint(x: 25 * s, y: 44 * s))
            feet.addLine(to: CGPoint(x: 31 * s, y: 44 * s))
            ctx.stroke(feet, with: .color(silhouette), style: stroke)

            // Position mains (haltères) selon frame — bras TENDUS qui s'écartent
            let handLX: CGFloat
            let handLY: CGFloat
            let handRX: CGFloat
            let handRY: CGFloat
            switch frame {
            case 0:
                // Start : bras le long du corps (verticaux pendus)
                handLX = 16 * s; handLY = 30 * s
                handRX = 32 * s; handRY = 30 * s
            case 1:
                // Mid : bras à 45° (oblique haut-extérieur)
                handLX = 10 * s; handLY = 24 * s
                handRX = 38 * s; handRY = 24 * s
            default:
                // End : bras horizontaux parfaits = T
                handLX = 6 * s; handLY = 17 * s
                handRX = 42 * s; handRY = 17 * s
            }

            // Bras gauche TENDU (épaule → main, ligne droite — signature)
            var armL = Path()
            armL.move(to: CGPoint(x: 18 * s, y: 17 * s))
            armL.addLine(to: CGPoint(x: handLX, y: handLY))
            ctx.stroke(armL, with: .color(silhouette), style: stroke)

            // Bras droit TENDU (symétrique)
            var armR = Path()
            armR.move(to: CGPoint(x: 30 * s, y: 17 * s))
            armR.addLine(to: CGPoint(x: handRX, y: handRY))
            ctx.stroke(armR, with: .color(silhouette), style: stroke)

            // Haltères = barre + 2 disques perpendiculaires au bras
            let discSize: CGFloat = 3 * s
            // Haltère gauche — orientation perpendiculaire au bras
            // (frame 0 = bras vertical → haltère horizontal ; frame 2 = bras horizontal → haltère vertical)
            let isVertical = (frame == 2)
            for hx in [handLX, handRX] {
                let hy = (hx == handLX) ? handLY : handRY
                if isVertical {
                    // Frame 2 : disques verticaux (haut/bas du poignet)
                    ctx.stroke(
                        Path(ellipseIn: CGRect(x: hx - discSize / 2, y: hy - 2 * s - discSize / 2,
                                                width: discSize, height: discSize)),
                        with: .color(equipment),
                        style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
                    )
                    ctx.stroke(
                        Path(ellipseIn: CGRect(x: hx - discSize / 2, y: hy + 2 * s - discSize / 2,
                                                width: discSize, height: discSize)),
                        with: .color(equipment),
                        style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
                    )
                } else {
                    // Frame 0/1 : disques horizontaux (gauche/droite du poignet)
                    ctx.stroke(
                        Path(ellipseIn: CGRect(x: hx - 2 * s - discSize / 2, y: hy - discSize / 2,
                                                width: discSize, height: discSize)),
                        with: .color(equipment),
                        style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
                    )
                    ctx.stroke(
                        Path(ellipseIn: CGRect(x: hx + 2 * s - discSize / 2, y: hy - discSize / 2,
                                                width: discSize, height: discSize)),
                        with: .color(equipment),
                        style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
                    )
                }
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Lateral raises") {
    HStack(spacing: 4) {
        LateralRaisesIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LateralRaisesIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LateralRaisesIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
