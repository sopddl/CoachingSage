// Views/Components/Illustrations/PlyoIllustration.swift
// Story 3.19 Jalon 2a — jump squat / plyometric 3 frames.
// Grille didactique : EXCEPTION SAUT EXPLICITE. Les pieds DÉCOLLENT visiblement
// en frame 1 (air sous les pieds = message saut). Frame 2 = atterrissage.
//
// Frame 0 : squat préparation (silhouette baissée prête à exploser)
// Frame 1 : SAUT — pieds bien au-dessus du sol, bras tendus, corps vertical
// Frame 2 : atterrissage (genoux fléchis pour absorber)
import SwiftUI

struct PlyoIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)

            // Sol pointillé fixe
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 44 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            let centerX: CGFloat = 24 * s
            let headSize: CGFloat = 6 * s

            // Frame 0 : squat préparation (corps baissé, pieds au sol)
            // Frame 1 : SAUT — corps droit vertical, pieds DÉCOLLÉS du sol
            // Frame 2 : atterrissage (corps mi-haut, pieds au sol, genoux fléchis)

            switch frame {
            case 0: drawSquatPrep(ctx: ctx, s: s, stroke: stroke, centerX: centerX, headSize: headSize)
            case 1: drawJump(ctx: ctx, s: s, stroke: stroke, centerX: centerX, headSize: headSize)
            default: drawLanding(ctx: ctx, s: s, stroke: stroke, centerX: centerX, headSize: headSize)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }

    // MARK: - Frame 0 : squat préparation

    private func drawSquatPrep(ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle,
                                centerX: CGFloat, headSize: CGFloat) {
        let topOfHeadY: CGFloat = 16 * s
        let shoulderY: CGFloat = topOfHeadY + headSize
        let hipY: CGFloat = 32 * s
        let kneeY: CGFloat = 40 * s
        let ankleY: CGFloat = 46 * s

        drawHead(ctx: ctx, x: centerX, topY: topOfHeadY, size: headSize, stroke: stroke)
        drawTrunk(ctx: ctx, from: CGPoint(x: centerX, y: shoulderY),
                  to: CGPoint(x: centerX, y: hipY), stroke: stroke)
        drawLegs(ctx: ctx, hipX: centerX, hipY: hipY,
                 kneeOffsetX: 5 * s, kneeY: kneeY, ankleY: ankleY, stroke: stroke)
        // Bras pendants
        drawArmPair(ctx: ctx, shoulderY: shoulderY, centerX: centerX,
                    handX1: centerX - 4 * s, handY1: hipY,
                    handX2: centerX + 4 * s, handY2: hipY, stroke: stroke)
    }

    // MARK: - Frame 1 : SAUT pieds décollés

    private func drawJump(ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle,
                          centerX: CGFloat, headSize: CGFloat) {
        // Corps remonté, pieds DÉCOLLÉS (ankleY bien au-dessus du sol)
        let topOfHeadY: CGFloat = 4 * s
        let shoulderY: CGFloat = topOfHeadY + headSize
        let hipY: CGFloat = 20 * s
        let kneeY: CGFloat = 28 * s
        let ankleY: CGFloat = 36 * s // 10s AU-DESSUS du sol (46s) = saut clair !

        drawHead(ctx: ctx, x: centerX, topY: topOfHeadY, size: headSize, stroke: stroke)
        drawTrunk(ctx: ctx, from: CGPoint(x: centerX, y: shoulderY),
                  to: CGPoint(x: centerX, y: hipY), stroke: stroke)
        // Jambes tendues (saut)
        drawLegs(ctx: ctx, hipX: centerX, hipY: hipY,
                 kneeOffsetX: 2 * s, kneeY: kneeY, ankleY: ankleY, stroke: stroke)
        // Bras tendus vers le HAUT (signature saut)
        drawArmPair(ctx: ctx, shoulderY: shoulderY, centerX: centerX,
                    handX1: centerX - 3 * s, handY1: 0,
                    handX2: centerX + 3 * s, handY2: 0, stroke: stroke)

        // Marqueur visuel air sous pieds (chevrons orange)
        var marker1 = Path()
        marker1.move(to: CGPoint(x: centerX - 6 * s, y: 42 * s))
        marker1.addLine(to: CGPoint(x: centerX - 4 * s, y: 40 * s))
        marker1.addLine(to: CGPoint(x: centerX - 2 * s, y: 42 * s))
        ctx.stroke(marker1, with: .color(IllustrationStyle.movementArrow),
                   style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
        var marker2 = Path()
        marker2.move(to: CGPoint(x: centerX + 2 * s, y: 42 * s))
        marker2.addLine(to: CGPoint(x: centerX + 4 * s, y: 40 * s))
        marker2.addLine(to: CGPoint(x: centerX + 6 * s, y: 42 * s))
        ctx.stroke(marker2, with: .color(IllustrationStyle.movementArrow),
                   style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
    }

    // MARK: - Frame 2 : atterrissage genoux fléchis

    private func drawLanding(ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle,
                             centerX: CGFloat, headSize: CGFloat) {
        let topOfHeadY: CGFloat = 14 * s
        let shoulderY: CGFloat = topOfHeadY + headSize
        let hipY: CGFloat = 28 * s
        let kneeY: CGFloat = 38 * s
        let ankleY: CGFloat = 46 * s

        drawHead(ctx: ctx, x: centerX, topY: topOfHeadY, size: headSize, stroke: stroke)
        drawTrunk(ctx: ctx, from: CGPoint(x: centerX, y: shoulderY),
                  to: CGPoint(x: centerX, y: hipY), stroke: stroke)
        // Jambes très fléchies (absorption choc)
        drawLegs(ctx: ctx, hipX: centerX, hipY: hipY,
                 kneeOffsetX: 5 * s, kneeY: kneeY, ankleY: ankleY, stroke: stroke)
        // Bras pendants vers l'avant pour équilibre
        drawArmPair(ctx: ctx, shoulderY: shoulderY, centerX: centerX,
                    handX1: centerX - 6 * s, handY1: hipY,
                    handX2: centerX + 6 * s, handY2: hipY, stroke: stroke)
    }

    // MARK: - Helpers

    private func drawHead(ctx: GraphicsContext, x: CGFloat, topY: CGFloat, size: CGFloat, stroke: StrokeStyle) {
        ctx.stroke(
            Path(ellipseIn: CGRect(x: x - size / 2, y: topY, width: size, height: size)),
            with: .color(IllustrationStyle.silhouette(sportCode: sportCode)),
            style: stroke
        )
    }

    private func drawTrunk(ctx: GraphicsContext, from: CGPoint, to: CGPoint, stroke: StrokeStyle) {
        var p = Path()
        p.move(to: from)
        p.addLine(to: to)
        ctx.stroke(p, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
    }

    private func drawLegs(ctx: GraphicsContext, hipX: CGFloat, hipY: CGFloat,
                          kneeOffsetX: CGFloat, kneeY: CGFloat, ankleY: CGFloat, stroke: StrokeStyle) {
        var legL = Path()
        legL.move(to: CGPoint(x: hipX, y: hipY))
        legL.addLine(to: CGPoint(x: hipX - kneeOffsetX, y: kneeY))
        legL.addLine(to: CGPoint(x: hipX - kneeOffsetX + 2, y: ankleY))
        ctx.stroke(legL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        var legR = Path()
        legR.move(to: CGPoint(x: hipX, y: hipY))
        legR.addLine(to: CGPoint(x: hipX + kneeOffsetX, y: kneeY))
        legR.addLine(to: CGPoint(x: hipX + kneeOffsetX - 2, y: ankleY))
        ctx.stroke(legR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
    }

    private func drawArmPair(ctx: GraphicsContext, shoulderY: CGFloat, centerX: CGFloat,
                             handX1: CGFloat, handY1: CGFloat,
                             handX2: CGFloat, handY2: CGFloat, stroke: StrokeStyle) {
        var armL = Path()
        armL.move(to: CGPoint(x: centerX - 1, y: shoulderY))
        armL.addLine(to: CGPoint(x: handX1, y: handY1))
        ctx.stroke(armL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 1, y: shoulderY))
        armR.addLine(to: CGPoint(x: handX2, y: handY2))
        ctx.stroke(armR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
    }
}

#if DEBUG
#Preview("Plyo — jump squat 3 frames") {
    HStack(spacing: 4) {
        PlyoIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PlyoIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PlyoIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
