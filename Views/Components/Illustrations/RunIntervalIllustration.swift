// Views/Components/Illustrations/RunIntervalIllustration.swift
// Story 3.19 Jalon 2a — running interval / fractionné 3 frames.
// Différence avec endurance : intensité variable visible
//   - Frame 0 : footing facile (foulée courte, peu d'amplitude)
//   - Frame 1 : sprint / fraction rapide (foulée allongée, jambes étirées, en l'air)
//   - Frame 2 : récup (foulée réduite, presque marche)
// Le coureur va dans la même direction sur les 3 frames.
import SwiftUI

struct RunIntervalIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)

            // Sol pointillé
            var ground = Path()
            ground.move(to: CGPoint(x: 2 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 46 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            let centerX: CGFloat = 24 * s
            let headSize: CGFloat = 6 * s

            switch frame {
            case 0: drawJogging(ctx: ctx, s: s, stroke: stroke, centerX: centerX, headSize: headSize)
            case 1: drawSprint(ctx: ctx, s: s, stroke: stroke, centerX: centerX, headSize: headSize)
            default: drawRecovery(ctx: ctx, s: s, stroke: stroke, centerX: centerX, headSize: headSize)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }

    // MARK: - Frame 0 : footing facile

    private func drawJogging(ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle,
                              centerX: CGFloat, headSize: CGFloat) {
        let topOfHeadY: CGFloat = 10 * s
        let shoulderY: CGFloat = topOfHeadY + headSize
        let hipY: CGFloat = 26 * s

        drawHead(ctx: ctx, x: centerX + 1 * s, topY: topOfHeadY, size: headSize, stroke: stroke)
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX + 1 * s, y: shoulderY))
        trunk.addLine(to: CGPoint(x: centerX, y: hipY))
        ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // Jambes foulée moyenne (peu d'amplitude)
        var frontLeg = Path()
        frontLeg.move(to: CGPoint(x: centerX, y: hipY))
        frontLeg.addLine(to: CGPoint(x: centerX + 4 * s, y: 36 * s))
        frontLeg.addLine(to: CGPoint(x: centerX + 6 * s, y: 46 * s))
        ctx.stroke(frontLeg, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        var backLeg = Path()
        backLeg.move(to: CGPoint(x: centerX, y: hipY))
        backLeg.addLine(to: CGPoint(x: centerX - 2 * s, y: 36 * s))
        backLeg.addLine(to: CGPoint(x: centerX - 5 * s, y: 44 * s))
        ctx.stroke(backLeg, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // Bras peu marqués
        var armL = Path()
        armL.move(to: CGPoint(x: centerX - 1 * s, y: shoulderY + 1 * s))
        armL.addLine(to: CGPoint(x: centerX + 3 * s, y: 26 * s))
        ctx.stroke(armL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 2 * s, y: shoulderY + 1 * s))
        armR.addLine(to: CGPoint(x: centerX - 2 * s, y: 26 * s))
        ctx.stroke(armR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
    }

    // MARK: - Frame 1 : SPRINT (foulée allongée, en l'air)

    private func drawSprint(ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle,
                             centerX: CGFloat, headSize: CGFloat) {
        // Corps très penché en avant (sprint), tête plus en avant
        let topOfHeadY: CGFloat = 8 * s
        let shoulderY: CGFloat = topOfHeadY + headSize
        let hipY: CGFloat = 26 * s

        drawHead(ctx: ctx, x: centerX + 4 * s, topY: topOfHeadY, size: headSize, stroke: stroke)
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX + 4 * s, y: shoulderY))
        trunk.addLine(to: CGPoint(x: centerX, y: hipY))
        ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // Jambes très étirées (sprint, en l'air) — grande amplitude
        var frontLeg = Path()
        frontLeg.move(to: CGPoint(x: centerX, y: hipY))
        frontLeg.addLine(to: CGPoint(x: centerX + 8 * s, y: 32 * s))
        frontLeg.addLine(to: CGPoint(x: centerX + 12 * s, y: 38 * s)) // pied en avant en l'air
        ctx.stroke(frontLeg, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        var backLeg = Path()
        backLeg.move(to: CGPoint(x: centerX, y: hipY))
        backLeg.addLine(to: CGPoint(x: centerX - 6 * s, y: 34 * s))
        backLeg.addLine(to: CGPoint(x: centerX - 10 * s, y: 42 * s)) // pied en arrière en l'air
        ctx.stroke(backLeg, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // Bras très marqués (poussée explosive)
        var armL = Path()
        armL.move(to: CGPoint(x: centerX + 1 * s, y: shoulderY + 1 * s))
        armL.addLine(to: CGPoint(x: centerX + 10 * s, y: 22 * s))
        ctx.stroke(armL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 4 * s, y: shoulderY + 1 * s))
        armR.addLine(to: CGPoint(x: centerX - 4 * s, y: 22 * s))
        ctx.stroke(armR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // Petits chevrons orange pour suggérer "vitesse"
        var speed1 = Path()
        speed1.move(to: CGPoint(x: 3 * s, y: 18 * s))
        speed1.addLine(to: CGPoint(x: 7 * s, y: 18 * s))
        ctx.stroke(speed1, with: .color(IllustrationStyle.movementArrow),
                   style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))
        var speed2 = Path()
        speed2.move(to: CGPoint(x: 2 * s, y: 22 * s))
        speed2.addLine(to: CGPoint(x: 8 * s, y: 22 * s))
        ctx.stroke(speed2, with: .color(IllustrationStyle.movementArrow),
                   style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))
    }

    // MARK: - Frame 2 : récup (foulée réduite, presque marche)

    private func drawRecovery(ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle,
                               centerX: CGFloat, headSize: CGFloat) {
        let topOfHeadY: CGFloat = 10 * s
        let shoulderY: CGFloat = topOfHeadY + headSize
        let hipY: CGFloat = 26 * s

        drawHead(ctx: ctx, x: centerX, topY: topOfHeadY, size: headSize, stroke: stroke)
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: centerX, y: hipY))
        ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // Jambes en marche (petite amplitude, pieds quasi alignés)
        var legL = Path()
        legL.move(to: CGPoint(x: centerX, y: hipY))
        legL.addLine(to: CGPoint(x: centerX + 2 * s, y: 36 * s))
        legL.addLine(to: CGPoint(x: centerX + 3 * s, y: 46 * s))
        ctx.stroke(legL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        var legR = Path()
        legR.move(to: CGPoint(x: centerX, y: hipY))
        legR.addLine(to: CGPoint(x: centerX - 2 * s, y: 36 * s))
        legR.addLine(to: CGPoint(x: centerX - 3 * s, y: 46 * s))
        ctx.stroke(legR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // Bras pendants
        var armL = Path()
        armL.move(to: CGPoint(x: centerX - 2 * s, y: shoulderY + 1 * s))
        armL.addLine(to: CGPoint(x: centerX - 3 * s, y: hipY + 1 * s))
        ctx.stroke(armL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 2 * s, y: shoulderY + 1 * s))
        armR.addLine(to: CGPoint(x: centerX + 3 * s, y: hipY + 1 * s))
        ctx.stroke(armR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
    }

    // MARK: - Helper

    private func drawHead(ctx: GraphicsContext, x: CGFloat, topY: CGFloat, size: CGFloat, stroke: StrokeStyle) {
        ctx.stroke(
            Path(ellipseIn: CGRect(x: x - size / 2, y: topY, width: size, height: size)),
            with: .color(IllustrationStyle.silhouette(sportCode: sportCode)),
            style: stroke
        )
    }
}

#if DEBUG
#Preview("RunInterval — fractionné 3 frames") {
    HStack(spacing: 4) {
        RunIntervalIllustration(sportCode: "running", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        RunIntervalIllustration(sportCode: "running", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        RunIntervalIllustration(sportCode: "running", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
