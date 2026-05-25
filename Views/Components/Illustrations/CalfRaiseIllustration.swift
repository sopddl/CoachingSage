// Views/Components/Illustrations/CalfRaiseIllustration.swift
// Story 3.23 Tier 1 Jalon 2 — Calf raise 3 frames vue de PROFIL.
// 228 occurrences × 23 templates dans la bibliothèque V2.
//
// Grille didactique (cf `feedback_illustration_didactic_grid`) :
//   - Corps debout fixe (silhouette ne bouge pas en hauteur globale).
//   - SEULS les talons décollent du sol entre frames (référentiel = pieds).
//   - Sol pointillé sous les orteils en tout temps.
//
// Frame 0 : pieds plats au sol (talons en bas).
// Frame 1 : demi-pointe (talons légèrement levés).
// Frame 2 : pointe haute (talons en haut, fléchissement complet mollets).
//
// Réf : Wikipedia "Calf raise".
import SwiftUI

struct CalfRaiseIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)

            // Sol pointillé fixe en bas (ancrage référentiel)
            var ground = Path()
            ground.move(to: CGPoint(x: 2 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 46 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Orteils FIXES au sol (pivot fixe — référentiel observateur)
            let toeX: CGFloat = 26 * s
            let toeY: CGFloat = 46 * s

            // Talon : se décolle selon frame
            let heelY: CGFloat
            switch frame {
            case 0: heelY = 46 * s   // au sol
            case 1: heelY = 42 * s   // demi-pointe
            default: heelY = 38 * s  // pointe haute
            }
            let heelX: CGFloat = toeX - 6 * s

            // Pied (talon → orteil) — segment qui s'incline progressivement
            var foot = Path()
            foot.move(to: CGPoint(x: heelX, y: heelY))
            foot.addLine(to: CGPoint(x: toeX, y: toeY))
            ctx.stroke(foot, with: .color(silhouette), style: stroke)

            // Tibia : du talon vers le genou (FIXE en y, monte un peu si pointe)
            // Ankle = au-dessus du talon, monte avec heelY
            let ankleX: CGFloat = heelX
            let ankleY: CGFloat = heelY - 1 * s
            let kneeX: CGFloat = ankleX + 2 * s
            let kneeY: CGFloat = 26 * s
            var shin = Path()
            shin.move(to: CGPoint(x: ankleX, y: ankleY))
            shin.addLine(to: CGPoint(x: kneeX, y: kneeY))
            ctx.stroke(shin, with: .color(silhouette), style: stroke)

            // Cuisses (genou → hanche) — fixe
            let hipX: CGFloat = kneeX + 1 * s
            let hipY: CGFloat = 16 * s
            var thigh = Path()
            thigh.move(to: CGPoint(x: kneeX, y: kneeY))
            thigh.addLine(to: CGPoint(x: hipX, y: hipY))
            ctx.stroke(thigh, with: .color(silhouette), style: stroke)

            // Tronc (hanche → épaule) — fixe
            let shoulderX: CGFloat = hipX
            let shoulderY: CGFloat = 8 * s
            var trunk = Path()
            trunk.move(to: CGPoint(x: hipX, y: hipY))
            trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Tête (au-dessus des épaules) — fixe
            let headSize: CGFloat = 5 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: shoulderX - headSize / 2, y: shoulderY - headSize - 1 * s,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Bras le long du corps (épaule → main) — fixe
            var arm = Path()
            arm.move(to: CGPoint(x: shoulderX + 1 * s, y: shoulderY + 1 * s))
            arm.addLine(to: CGPoint(x: shoulderX + 3 * s, y: 22 * s))
            ctx.stroke(arm, with: .color(silhouette), style: stroke)

            // Annotation : flèche orange ↑ depuis le talon en frame 2 (contraction haute)
            if frame == 2 {
                let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
                var arrow = Path()
                arrow.move(to: CGPoint(x: heelX - 4 * s, y: 46 * s))
                arrow.addLine(to: CGPoint(x: heelX - 4 * s, y: heelY))
                arrow.move(to: CGPoint(x: heelX - 6 * s, y: heelY + 2 * s))
                arrow.addLine(to: CGPoint(x: heelX - 4 * s, y: heelY))
                arrow.addLine(to: CGPoint(x: heelX - 2 * s, y: heelY + 2 * s))
                ctx.stroke(arrow, with: .color(IllustrationStyle.movementArrow), style: arrowStyle)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("CalfRaise — 3 frames") {
    HStack(spacing: 4) {
        CalfRaiseIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        CalfRaiseIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        CalfRaiseIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
