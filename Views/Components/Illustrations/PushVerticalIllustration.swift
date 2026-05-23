// Views/Components/Illustrations/PushVerticalIllustration.swift
// Story 3.19 Jalon 2a — overhead press / shoulder press 3 frames.
// Grille didactique : corps FIXE pieds au sol, haltères qui MONTENT au-dessus
// de la tête. Référentiel observateur.
//
// Frame 0 : haltères aux épaules (position basse) — coudes pliés, mains au niveau des oreilles
// Frame 1 : haltères mi-hauteur — coudes mi-pliés
// Frame 2 : haltères au-dessus de la tête — bras tendus
import SwiftUI

struct PushVerticalIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)

            // Sol pointillé fixe en bas
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 44 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Corps FIXE (debout pieds au sol, tête en bas du cadre supérieur)
            let centerX: CGFloat = 24 * s
            let headSize: CGFloat = 6 * s
            let topOfHeadY: CGFloat = 14 * s
            let shoulderY: CGFloat = topOfHeadY + headSize // 20s
            let hipY: CGFloat = 30 * s
            let kneeY: CGFloat = 38 * s
            let ankleY: CGFloat = 46 * s

            // Tête
            ctx.stroke(
                Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: topOfHeadY,
                                        width: headSize, height: headSize)),
                with: .color(IllustrationStyle.silhouette(sportCode: sportCode)),
                style: stroke
            )

            // Tronc
            var trunk = Path()
            trunk.move(to: CGPoint(x: centerX, y: shoulderY))
            trunk.addLine(to: CGPoint(x: centerX, y: hipY))
            ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Jambes droites
            var legL = Path()
            legL.move(to: CGPoint(x: centerX, y: hipY))
            legL.addLine(to: CGPoint(x: centerX - 3 * s, y: kneeY))
            legL.addLine(to: CGPoint(x: centerX - 4 * s, y: ankleY))
            ctx.stroke(legL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            var legR = Path()
            legR.move(to: CGPoint(x: centerX, y: hipY))
            legR.addLine(to: CGPoint(x: centerX + 3 * s, y: kneeY))
            legR.addLine(to: CGPoint(x: centerX + 4 * s, y: ankleY))
            ctx.stroke(legR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Hauteur des HALTÈRES selon frame (descend / monte au-dessus de la tête)
            // Frame 0 : haltères aux épaules (y = shoulderY = 20s)
            // Frame 1 : mi-hauteur (y = 14s)
            // Frame 2 : au-dessus tête bras tendus (y = 4s)
            let dumbbellY: CGFloat
            switch frame {
            case 0: dumbbellY = shoulderY - 1 * s // au niveau épaules
            case 1: dumbbellY = topOfHeadY - 2 * s // au niveau tête
            default: dumbbellY = 4 * s // bras tendus au-dessus
            }

            // Positions latérales des haltères (un de chaque côté du centre)
            let dumbbellLX: CGFloat = centerX - 9 * s
            let dumbbellRX: CGFloat = centerX + 9 * s

            // Bras gauche (épaule → coude → main avec haltère)
            // Le coude est plié quand haltère bas, tendu quand haltère haut
            let armReach: CGFloat = shoulderY - dumbbellY // positive si haltère au-dessus épaule
            let elbowOutset: CGFloat = max(0, (16 * s - armReach)) * 0.5
            let elbowLY: CGFloat = (shoulderY + dumbbellY) / 2
            let elbowRY: CGFloat = elbowLY
            let elbowLX: CGFloat = dumbbellLX - elbowOutset
            let elbowRX: CGFloat = dumbbellRX + elbowOutset

            var armL = Path()
            armL.move(to: CGPoint(x: centerX - 1 * s, y: shoulderY))
            armL.addLine(to: CGPoint(x: elbowLX, y: elbowLY))
            armL.addLine(to: CGPoint(x: dumbbellLX, y: dumbbellY))
            ctx.stroke(armL, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            var armR = Path()
            armR.move(to: CGPoint(x: centerX + 1 * s, y: shoulderY))
            armR.addLine(to: CGPoint(x: elbowRX, y: elbowRY))
            armR.addLine(to: CGPoint(x: dumbbellRX, y: dumbbellY))
            ctx.stroke(armR, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Haltères dessinées comme rectangles or
            let dumbbellW: CGFloat = 4 * s
            let dumbbellH: CGFloat = 2.5 * s
            ctx.fill(
                Path(roundedRect: CGRect(x: dumbbellLX - dumbbellW / 2, y: dumbbellY - dumbbellH / 2,
                                          width: dumbbellW, height: dumbbellH), cornerRadius: 0.5 * s),
                with: .color(IllustrationStyle.load)
            )
            ctx.fill(
                Path(roundedRect: CGRect(x: dumbbellRX - dumbbellW / 2, y: dumbbellY - dumbbellH / 2,
                                          width: dumbbellW, height: dumbbellH), cornerRadius: 0.5 * s),
                with: .color(IllustrationStyle.load)
            )
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("PushVertical — overhead 3 frames") {
    HStack(spacing: 4) {
        PushVerticalIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PushVerticalIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PushVerticalIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
