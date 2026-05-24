// Views/Components/Illustrations/SquatIllustration.swift
// Story 3.19 — squat 3 frames : debout → mi-squat → fond.
// Coordonnées normalisées 48×48 (ViewBox `IllustrationStyle.frameSize`).
// Silhouette = couleur sport ; barre = `equipment` (bleu marine) ; disques = `load` (or).
import SwiftUI

struct SquatIllustration: View {
    let sportCode: String
    let frame: Int // 0, 1, 2

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let strokeHeavy = StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)

            // Sol (ligne pointillée bas)
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 44 * s))
            ground.addLine(to: CGPoint(x: 44 * s, y: 44 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Frame 0 : debout (squat depth = 0)
            // Frame 1 : mi-squat (depth = 0.5)
            // Frame 2 : squat fond (depth = 1.0)
            let depth: CGFloat
            switch frame {
            case 0: depth = 0.0
            case 1: depth = 0.5
            default: depth = 1.0
            }

            // Hauteur tête, hanche, genou (interpolation simple)
            let headY: CGFloat = (12 + 4 * depth) * s
            let hipY: CGFloat = (24 + 8 * depth) * s
            let kneeY: CGFloat = (34 + 0 * depth) * s
            let ankleY: CGFloat = 44 * s
            let centerX: CGFloat = 24 * s

            // Tête (cercle)
            let headSize: CGFloat = 6 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: headY - headSize / 2,
                                        width: headSize, height: headSize)),
                with: .color(IllustrationStyle.silhouette(sportCode: sportCode)),
                style: stroke
            )

            // Tronc (tête → hanche, légèrement penché vers l'avant à mesure que le squat s'enfonce)
            let leanX = 2 * depth * s
            var trunk = Path()
            trunk.move(to: CGPoint(x: centerX, y: headY + headSize / 2))
            trunk.addLine(to: CGPoint(x: centerX + leanX, y: hipY))
            ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Jambe gauche (hanche → genou → cheville)
            // Genou avance à mesure que le squat s'enfonce
            let kneeOffsetX = 6 * depth * s
            var legL = Path()
            legL.move(to: CGPoint(x: centerX + leanX, y: hipY))
            legL.addLine(to: CGPoint(x: centerX - 4 * s + kneeOffsetX, y: kneeY))
            legL.addLine(to: CGPoint(x: centerX - 6 * s, y: ankleY))
            ctx.stroke(legL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Jambe droite
            var legR = Path()
            legR.move(to: CGPoint(x: centerX + leanX, y: hipY))
            legR.addLine(to: CGPoint(x: centerX + 4 * s + kneeOffsetX, y: kneeY))
            legR.addLine(to: CGPoint(x: centerX + 6 * s, y: ankleY))
            ctx.stroke(legR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Barre sur épaules (légère bascule selon depth)
            let barY: CGFloat = headY + headSize / 2 + 1 * s
            var bar = Path()
            bar.move(to: CGPoint(x: 8 * s, y: barY))
            bar.addLine(to: CGPoint(x: 40 * s, y: barY))
            ctx.stroke(bar, with: .color(IllustrationStyle.equipment), style: strokeHeavy)

            // Disques (2 de chaque côté)
            let plate1 = CGRect(x: 5 * s, y: barY - 4 * s, width: 3 * s, height: 8 * s)
            let plate2 = CGRect(x: 40 * s, y: barY - 4 * s, width: 3 * s, height: 8 * s)
            ctx.fill(Path(roundedRect: plate1, cornerRadius: 1 * s),
                     with: .color(IllustrationStyle.load))
            ctx.fill(Path(roundedRect: plate2, cornerRadius: 1 * s),
                     with: .color(IllustrationStyle.load))
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Squat 3 frames") {
    HStack(spacing: 4) {
        SquatIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        SquatIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        SquatIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
