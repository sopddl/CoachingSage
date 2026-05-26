// Views/Components/Illustrations/BicepsCurlIllustration.swift
// Story 3.23 Lot 5 — Biceps curl 3 frames, viewbox 48×48.
// Source : https://en.wikipedia.org/wiki/Biceps_curl
// Signature : debout profil + haltères (barre + 2 disques) + flexion coude pure
// (épaule fixe, coude collé corps) → haltère à hauteur épaule.
import SwiftUI

struct BicepsCurlIllustration: View {
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

            // Silhouette debout invariante (épaule + coude FIXES — signature curl strict)
            let cx: CGFloat = 16 * s
            let headSize: CGFloat = 6 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 9 * s,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc vertical
            var trunk = Path()
            trunk.move(to: CGPoint(x: cx, y: 15 * s))
            trunk.addLine(to: CGPoint(x: cx, y: 30 * s))
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Bassin
            var pelvis = Path()
            pelvis.move(to: CGPoint(x: cx - 2 * s, y: 30 * s))
            pelvis.addLine(to: CGPoint(x: cx + 2 * s, y: 30 * s))
            ctx.stroke(pelvis, with: .color(silhouette), style: stroke)

            // Jambes verticales
            var legs = Path()
            legs.move(to: CGPoint(x: cx, y: 30 * s))
            legs.addLine(to: CGPoint(x: cx, y: 44 * s))
            ctx.stroke(legs, with: .color(silhouette), style: stroke)

            // Pieds
            var feet = Path()
            feet.move(to: CGPoint(x: cx - 4 * s, y: 44 * s))
            feet.addLine(to: CGPoint(x: cx + 4 * s, y: 44 * s))
            ctx.stroke(feet, with: .color(silhouette), style: stroke)

            // Épaule + coude FIXES
            let shoulderY: CGFloat = 16 * s
            let elbowY: CGFloat = 26 * s

            // Position poignet/haltère selon frame
            let wristX: CGFloat
            let wristY: CGFloat
            switch frame {
            case 0:
                // Bras tendu vers le bas
                wristX = cx; wristY = 36 * s
            case 1:
                // Mi-curl avant-bras horizontal
                wristX = 26 * s; wristY = 26 * s
            default:
                // Haut — haltère à hauteur épaule
                wristX = 20 * s; wristY = 18 * s
            }

            // Bras = épaule → coude FIXE → poignet variable (signature flexion pure)
            var arm = Path()
            arm.move(to: CGPoint(x: cx, y: shoulderY))
            arm.addLine(to: CGPoint(x: cx, y: elbowY))    // coude fixe
            arm.addLine(to: CGPoint(x: wristX, y: wristY))
            ctx.stroke(arm, with: .color(silhouette), style: stroke)

            // Haltère (barre + 2 disques)
            // Si frame 0/2 → disques verticaux (haltère orientation verticale)
            // Si frame 1 → disques horizontaux (avant-bras horizontal, haltère horizontal)
            let discSize: CGFloat = 3 * s
            if frame == 1 {
                // Disques verticaux à gauche et droite du poignet
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: wristX - 1 * s - discSize / 2, y: wristY - discSize / 2,
                                            width: discSize, height: discSize)),
                    with: .color(equipment),
                    style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
                )
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: wristX + 1 * s - discSize / 2, y: wristY - discSize / 2,
                                            width: discSize, height: discSize)),
                    with: .color(equipment),
                    style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
                )
            } else {
                // Disques au-dessus et au-dessous du poignet
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: wristX - discSize / 2, y: wristY - 1 * s - discSize / 2,
                                            width: discSize, height: discSize)),
                    with: .color(equipment),
                    style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
                )
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: wristX - discSize / 2, y: wristY + 1 * s - discSize / 2,
                                            width: discSize, height: discSize)),
                    with: .color(equipment),
                    style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
                )
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Biceps curl") {
    HStack(spacing: 4) {
        BicepsCurlIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        BicepsCurlIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        BicepsCurlIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
