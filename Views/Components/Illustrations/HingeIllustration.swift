// Views/Components/Illustrations/HingeIllustration.swift
// Story 3.19 — hinge (Romanian Deadlift) 3 frames : debout → 45° → ~90° (haltères en main).
// Le mouvement vient de la hanche, pas du dos. Bassin recule, dos reste droit.
import SwiftUI

struct HingeIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let strokeHeavy = StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)

            // Sol
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 44 * s))
            ground.addLine(to: CGPoint(x: 44 * s, y: 44 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Angle de bascule du tronc selon frame (0°, 45°, 80°)
            let tiltDeg: CGFloat
            switch frame {
            case 0: tiltDeg = 0
            case 1: tiltDeg = 45
            default: tiltDeg = 80
            }
            let tiltRad = tiltDeg * .pi / 180

            // Anchors : hanche fixée en place, bassin recule légèrement aussi (hinge)
            let hipX: CGFloat = (24 - 2 * (tiltDeg / 90)) * s
            let hipY: CGFloat = 26 * s
            let trunkLen: CGFloat = 12 * s

            // Tête au bout du tronc incliné
            let headDX = sin(tiltRad) * trunkLen
            let headDY = -cos(tiltRad) * trunkLen
            let headX = hipX + headDX
            let headY = hipY + headDY

            let headSize: CGFloat = 6 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                        width: headSize, height: headSize)),
                with: .color(IllustrationStyle.silhouette(sportCode: sportCode)),
                style: stroke
            )

            // Tronc (hanche → tête)
            var trunk = Path()
            trunk.move(to: CGPoint(x: hipX, y: hipY))
            trunk.addLine(to: CGPoint(x: headX, y: headY))
            ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Jambes droites (genou légèrement fléchi mais quasi tendu — hinge)
            let kneeBend: CGFloat = 1 * s
            var legL = Path()
            legL.move(to: CGPoint(x: hipX - 1 * s, y: hipY))
            legL.addLine(to: CGPoint(x: hipX - 3 * s - kneeBend, y: 35 * s))
            legL.addLine(to: CGPoint(x: hipX - 4 * s, y: 44 * s))
            ctx.stroke(legL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            var legR = Path()
            legR.move(to: CGPoint(x: hipX + 1 * s, y: hipY))
            legR.addLine(to: CGPoint(x: hipX + 3 * s - kneeBend, y: 35 * s))
            legR.addLine(to: CGPoint(x: hipX + 4 * s, y: 44 * s))
            ctx.stroke(legR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Bras pendants — partent des épaules (~3pt sous la tête le long du tronc)
            let shoulderT: CGFloat = 0.25 // 25% du tronc en partant de la tête
            let shoulderX = headX + (hipX - headX) * shoulderT
            let shoulderY = headY + (hipY - headY) * shoulderT
            // Bras tombent verticalement (gravity)
            let handY: CGFloat = shoulderY + 12 * s

            var armL = Path()
            armL.move(to: CGPoint(x: shoulderX - 2 * s, y: shoulderY))
            armL.addLine(to: CGPoint(x: shoulderX - 2 * s, y: handY))
            ctx.stroke(armL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            var armR = Path()
            armR.move(to: CGPoint(x: shoulderX + 2 * s, y: shoulderY))
            armR.addLine(to: CGPoint(x: shoulderX + 2 * s, y: handY))
            ctx.stroke(armR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Haltères dans les mains
            let dumbbellW: CGFloat = 4 * s
            let dumbbellH: CGFloat = 2.5 * s
            ctx.fill(
                Path(roundedRect: CGRect(x: shoulderX - 2 * s - dumbbellW / 2, y: handY - dumbbellH / 2,
                                          width: dumbbellW, height: dumbbellH), cornerRadius: 0.5 * s),
                with: .color(IllustrationStyle.load)
            )
            ctx.fill(
                Path(roundedRect: CGRect(x: shoulderX + 2 * s - dumbbellW / 2, y: handY - dumbbellH / 2,
                                          width: dumbbellW, height: dumbbellH), cornerRadius: 0.5 * s),
                with: .color(IllustrationStyle.load)
            )

            // Barre épaisseur "stick" entre les disques (équipement)
            var bar = Path()
            bar.move(to: CGPoint(x: shoulderX - 2 * s, y: handY))
            bar.addLine(to: CGPoint(x: shoulderX + 2 * s, y: handY))
            ctx.stroke(bar, with: .color(IllustrationStyle.equipment), style: strokeHeavy)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Hinge 3 frames") {
    HStack(spacing: 4) {
        HingeIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        HingeIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        HingeIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
