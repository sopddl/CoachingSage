// Views/Components/Illustrations/CalfRaiseIllustration.swift
// Story 3.23 Tier 1 Lot 0 — Calf raise refondu suite KO Sophie 2026-05-25.
// 228 occurrences × 23 templates.
//
// **Principe didactique** (review agent expert) :
//   - Le tibia RESTE FIXE en y. Seul le PIED pivote autour de la pointe (orteils).
//   - Sinon : la silhouette globale "monte" et l'œil interprète "personne qui saute"
//     au lieu de "talon qui décolle".
//   - Annotation : arc orange TANGENTIEL au talon (sens de rotation) + pied fantôme
//     en pointillé montrant la position basse (référentiel "le talon a quitté ça").
//   - Silhouette COMPLÈTE (tête + cou + tronc + 2 jambes + bras + pieds) pour
//     que l'œil identifie d'abord la personne debout avant le mouvement subtil.
//
// Réf : Wikipedia "Calf raises" — plantarflexion, pivot = balls of feet,
// heel raised as far as possible, knees stationary.
//
// Frame 0 : pied à plat (talon + orteils au sol).
// Frame 1 : demi-pointe (~22°).
// Frame 2 : pointe haute (~45°) + arc + pied fantôme en pointillé.
import SwiftUI

struct CalfRaiseIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)

            // Sol pointillé fixe en bas
            var ground = Path()
            ground.move(to: CGPoint(x: 2 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 46 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // === Pivot fixe = pointe du pied (orteils) ===
            let toeX: CGFloat = 24 * s
            let toeY: CGFloat = 46 * s

            // Talon : pivote en arc autour de la pointe
            let heelLength: CGFloat = 6 * s
            let heelAngle: CGFloat  // 0 = pied à plat, π/4 = pointe haute
            switch frame {
            case 0: heelAngle = 0
            case 1: heelAngle = .pi / 8       // ~22°
            default: heelAngle = .pi / 4      // ~45°
            }
            let heelX = toeX - heelLength * cos(heelAngle)
            let heelY = toeY - heelLength * sin(heelAngle)

            // Pied (talon → pointe) — trait épaissi pour signature franche
            var foot = Path()
            foot.move(to: CGPoint(x: heelX, y: heelY))
            foot.addLine(to: CGPoint(x: toeX, y: toeY))
            ctx.stroke(foot, with: .color(silhouette),
                       style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s * 1.3, lineCap: .round))

            // === Cheville FIXE — ne dépend PAS de frame ===
            let ankleX: CGFloat = 22 * s
            let ankleY: CGFloat = 43 * s

            // Tibia (cheville fixe → genou fixe)
            let kneeX: CGFloat = 22 * s
            let kneeY: CGFloat = 26 * s
            var shin = Path()
            shin.move(to: CGPoint(x: ankleX, y: ankleY))
            shin.addLine(to: CGPoint(x: kneeX, y: kneeY))
            ctx.stroke(shin, with: .color(silhouette), style: stroke)

            // Cuisse fixe (genou → hanche)
            let hipX: CGFloat = 22 * s
            let hipY: CGFloat = 16 * s
            var thigh = Path()
            thigh.move(to: CGPoint(x: kneeX, y: kneeY))
            thigh.addLine(to: CGPoint(x: hipX, y: hipY))
            ctx.stroke(thigh, with: .color(silhouette), style: stroke)

            // Tronc fixe (hanche → épaule)
            let shoulderX: CGFloat = 22 * s
            let shoulderY: CGFloat = 8 * s
            var trunk = Path()
            trunk.move(to: CGPoint(x: hipX, y: hipY))
            trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Cou (signature personnage = différencie corps et tête)
            var neck = Path()
            neck.move(to: CGPoint(x: shoulderX, y: shoulderY))
            neck.addLine(to: CGPoint(x: shoulderX, y: shoulderY - 2 * s))
            ctx.stroke(neck, with: .color(silhouette), style: stroke)

            // Tête
            let headSize: CGFloat = 5 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: shoulderX - headSize / 2,
                                        y: shoulderY - 2 * s - headSize,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Bras le long du corps (donne du corps à la silhouette pour lisibilité)
            var arm = Path()
            arm.move(to: CGPoint(x: shoulderX + 1 * s, y: shoulderY + 1 * s))
            arm.addLine(to: CGPoint(x: shoulderX + 2 * s, y: 16 * s))
            ctx.stroke(arm, with: .color(silhouette), style: stroke)

            // === Annotation frame 2 : pied fantôme + arc tangentiel ===
            if frame == 2 {
                // Pied "fantôme" position basse en pointillé léger (référentiel)
                var ghost = Path()
                ghost.move(to: CGPoint(x: toeX - heelLength, y: toeY))
                ghost.addLine(to: CGPoint(x: toeX, y: toeY))
                ctx.stroke(ghost, with: .color(IllustrationStyle.groundLine),
                           style: StrokeStyle(lineWidth: 1 * s, dash: [1.5 * s, 1.5 * s]))

                // Arc orange tangentiel autour de la pointe (rotation du talon)
                var arc = Path()
                arc.addArc(center: CGPoint(x: toeX, y: toeY), radius: heelLength * 0.85,
                           startAngle: .degrees(180), endAngle: .degrees(180 + 45), clockwise: true)
                ctx.stroke(arc, with: .color(IllustrationStyle.movementArrow),
                           style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round))

                // Pointe de flèche au bout de l'arc (sens de rotation visible)
                var arrowHead = Path()
                arrowHead.move(to: CGPoint(x: heelX - 1.5 * s, y: heelY + 0.5 * s))
                arrowHead.addLine(to: CGPoint(x: heelX, y: heelY))
                arrowHead.addLine(to: CGPoint(x: heelX - 0.5 * s, y: heelY + 1.5 * s))
                ctx.stroke(arrowHead, with: .color(IllustrationStyle.movementArrow),
                           style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round))
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
