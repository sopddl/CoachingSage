// Views/Components/Illustrations/KBSwingIllustration.swift
// Story 3.23 Lot 5 — KB Swing 3 frames, viewbox 48×48.
// Source : https://en.wikipedia.org/wiki/Kettlebell
// Signature : hip hinge + KB pendulaire entre genoux → mid → KB devant horizontal
// hauteur poitrine (Russian swing). Bras tendus tout le mouvement.
import SwiftUI

struct KBSwingIllustration: View {
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

            let headSize: CGFloat = 6 * s

            switch frame {
            case 0:
                // Hip hinge bas — tronc penché ~45°, KB entre genoux
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: 12 * s - headSize / 2, y: 13 * s,
                                            width: headSize, height: headSize)),
                    with: .color(silhouette), style: stroke
                )
                // Tronc penché vers l'avant
                var trunk = Path()
                trunk.move(to: CGPoint(x: 16 * s, y: 20 * s))
                trunk.addLine(to: CGPoint(x: 28 * s, y: 32 * s))
                ctx.stroke(trunk, with: .color(silhouette), style: stroke)
                // Jambes (cuisses fléchies modérément)
                var legs = Path()
                legs.move(to: CGPoint(x: 28 * s, y: 32 * s))
                legs.addLine(to: CGPoint(x: 26 * s, y: 38 * s))
                legs.addLine(to: CGPoint(x: 28 * s, y: 44 * s))
                ctx.stroke(legs, with: .color(silhouette), style: stroke)
                // Pieds
                var feet = Path()
                feet.move(to: CGPoint(x: 24 * s, y: 44 * s))
                feet.addLine(to: CGPoint(x: 32 * s, y: 44 * s))
                ctx.stroke(feet, with: .color(silhouette), style: stroke)
                // Bras tendus vers KB en arrière
                var arms = Path()
                arms.move(to: CGPoint(x: 16 * s, y: 20 * s))
                arms.addLine(to: CGPoint(x: 22 * s, y: 30 * s))
                arms.addLine(to: CGPoint(x: 28 * s, y: 40 * s))
                ctx.stroke(arms, with: .color(silhouette), style: stroke)
                // KB (cercle + anse)
                let kbSize: CGFloat = 5 * s
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: 28 * s - kbSize / 2, y: 40 * s,
                                            width: kbSize, height: kbSize)),
                    with: .color(equipment),
                    style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
                )
                // Anse au-dessus du cercle
                var handle = Path()
                handle.addArc(center: CGPoint(x: 28 * s, y: 40 * s),
                              radius: 3 * s,
                              startAngle: .degrees(200),
                              endAngle: .degrees(340),
                              clockwise: false)
                ctx.stroke(handle, with: .color(equipment),
                           style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))

            case 1:
                // Mid swing — tronc redressé partiel, KB devant à hauteur taille
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: 14 * s - headSize / 2, y: 11 * s,
                                            width: headSize, height: headSize)),
                    with: .color(silhouette), style: stroke
                )
                var trunk = Path()
                trunk.move(to: CGPoint(x: 16 * s, y: 18 * s))
                trunk.addLine(to: CGPoint(x: 22 * s, y: 32 * s))
                ctx.stroke(trunk, with: .color(silhouette), style: stroke)
                var legs = Path()
                legs.move(to: CGPoint(x: 22 * s, y: 32 * s))
                legs.addLine(to: CGPoint(x: 24 * s, y: 38 * s))
                legs.addLine(to: CGPoint(x: 28 * s, y: 44 * s))
                ctx.stroke(legs, with: .color(silhouette), style: stroke)
                var feet = Path()
                feet.move(to: CGPoint(x: 24 * s, y: 44 * s))
                feet.addLine(to: CGPoint(x: 32 * s, y: 44 * s))
                ctx.stroke(feet, with: .color(silhouette), style: stroke)
                // Bras tendus horizontaux
                var arms = Path()
                arms.move(to: CGPoint(x: 16 * s, y: 18 * s))
                arms.addLine(to: CGPoint(x: 24 * s, y: 22 * s))
                arms.addLine(to: CGPoint(x: 32 * s, y: 28 * s))
                ctx.stroke(arms, with: .color(silhouette), style: stroke)
                // KB devant
                let kbSize: CGFloat = 5 * s
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: 32 * s - kbSize / 2, y: 28 * s - kbSize / 2,
                                            width: kbSize, height: kbSize)),
                    with: .color(equipment),
                    style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
                )

            default:
                // Haut swing — corps debout, KB hauteur poitrine
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: 16 * s - headSize / 2, y: 9 * s,
                                            width: headSize, height: headSize)),
                    with: .color(silhouette), style: stroke
                )
                var trunk = Path()
                trunk.move(to: CGPoint(x: 16 * s, y: 16 * s))
                trunk.addLine(to: CGPoint(x: 16 * s, y: 32 * s))
                ctx.stroke(trunk, with: .color(silhouette), style: stroke)
                var legs = Path()
                legs.move(to: CGPoint(x: 16 * s, y: 32 * s))
                legs.addLine(to: CGPoint(x: 16 * s, y: 44 * s))
                ctx.stroke(legs, with: .color(silhouette), style: stroke)
                var feet = Path()
                feet.move(to: CGPoint(x: 12 * s, y: 44 * s))
                feet.addLine(to: CGPoint(x: 20 * s, y: 44 * s))
                ctx.stroke(feet, with: .color(silhouette), style: stroke)
                // Bras tendus horizontaux devant
                var arms = Path()
                arms.move(to: CGPoint(x: 16 * s, y: 16 * s))
                arms.addLine(to: CGPoint(x: 30 * s, y: 18 * s))
                arms.addLine(to: CGPoint(x: 40 * s, y: 22 * s))
                ctx.stroke(arms, with: .color(silhouette), style: stroke)
                // KB hauteur poitrine
                let kbSize: CGFloat = 6 * s
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: 40 * s - kbSize / 2, y: 22 * s - kbSize / 2,
                                            width: kbSize, height: kbSize)),
                    with: .color(equipment),
                    style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
                )
                var handle = Path()
                handle.addArc(center: CGPoint(x: 40 * s, y: 22 * s),
                              radius: 3.5 * s,
                              startAngle: .degrees(200),
                              endAngle: .degrees(340),
                              clockwise: false)
                ctx.stroke(handle, with: .color(equipment),
                           style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("KB Swing — Russian swing") {
    HStack(spacing: 4) {
        KBSwingIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        KBSwingIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        KBSwingIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
