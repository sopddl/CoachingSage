// Views/Components/Illustrations/PallofPressIllustration.swift
// Story 3.23 Lot 3 — Pallof press câble anti-rotation 3 frames, viewbox 48×48.
// Source : https://en.wikipedia.org/wiki/Anti-rotation_press
// Signature : silhouette de face + câble latéral pointillé orange + mains
// jointes au sternum (start/end) → bras tendus devant (mid).
import SwiftUI

struct PallofPressIllustration: View {
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

            // Pictogramme poulie (équipement fixe à gauche)
            let pulleySize: CGFloat = 4 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: 2 * s, y: 26 * s,
                                        width: pulleySize, height: pulleySize)),
                with: .color(IllustrationStyle.equipment), style: stroke
            )

            // Silhouette de face — corps invariant aux 3 frames
            let cx: CGFloat = 24 * s
            let headSize: CGFloat = 6 * s

            // Tête
            ctx.stroke(
                Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 9 * s,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc droit vertical (signature anti-rotation = pas de torsion)
            var trunk = Path()
            trunk.move(to: CGPoint(x: cx, y: 15 * s))
            trunk.addLine(to: CGPoint(x: cx, y: 32 * s))
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Bassin (largeur)
            var pelvis = Path()
            pelvis.move(to: CGPoint(x: cx - 2 * s, y: 32 * s))
            pelvis.addLine(to: CGPoint(x: cx + 2 * s, y: 32 * s))
            ctx.stroke(pelvis, with: .color(silhouette), style: stroke)

            // Jambes (largeur épaule)
            var legL = Path()
            legL.move(to: CGPoint(x: cx - 2 * s, y: 32 * s))
            legL.addLine(to: CGPoint(x: cx - 4 * s, y: 44 * s))
            ctx.stroke(legL, with: .color(silhouette), style: stroke)
            var legR = Path()
            legR.move(to: CGPoint(x: cx + 2 * s, y: 32 * s))
            legR.addLine(to: CGPoint(x: cx + 4 * s, y: 44 * s))
            ctx.stroke(legR, with: .color(silhouette), style: stroke)

            // Mains — varient selon frame
            let handsX: CGFloat
            let handsY: CGFloat
            switch frame {
            case 0:
                // Start : mains au sternum (proches du corps)
                handsX = cx; handsY = 22 * s
            case 1:
                // Mid press : bras tendus devant (mains éloignées en projection)
                handsX = cx + 8 * s; handsY = 22 * s
            default:
                // End : retour mains au sternum
                handsX = cx; handsY = 22 * s
            }

            // Bras gauche (épaule → coude → mains jointes)
            var armL = Path()
            armL.move(to: CGPoint(x: cx - 4 * s, y: 15 * s))
            armL.addLine(to: CGPoint(x: cx - 2 * s, y: 19 * s))
            armL.addLine(to: CGPoint(x: handsX, y: handsY))
            ctx.stroke(armL, with: .color(silhouette), style: stroke)

            // Bras droit
            var armR = Path()
            armR.move(to: CGPoint(x: cx + 4 * s, y: 15 * s))
            armR.addLine(to: CGPoint(x: cx + 2 * s, y: 19 * s))
            armR.addLine(to: CGPoint(x: handsX, y: handsY))
            ctx.stroke(armR, with: .color(silhouette), style: stroke)

            // Mains jointes (petit cercle marqueur)
            let handsSize: CGFloat = 2.5 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: handsX - handsSize / 2, y: handsY - handsSize / 2,
                                        width: handsSize, height: handsSize)),
                with: .color(silhouette), style: stroke
            )

            // Câble pointillé orange (poulie → mains) — signature anti-rotation
            var cable = Path()
            cable.move(to: CGPoint(x: 6 * s, y: 28 * s))
            cable.addLine(to: CGPoint(x: handsX, y: handsY))
            ctx.stroke(cable, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, dash: [3 * s, 2 * s]))
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Pallof press — anti-rotation") {
    HStack(spacing: 4) {
        PallofPressIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PallofPressIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PallofPressIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
