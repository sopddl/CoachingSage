// Views/Components/Illustrations/HipThrustIllustration.swift
// Story 3.23 Tier 1 Jalon 2 — Hip Thrust 3 frames vue de PROFIL.
// 246 occurrences × 33 templates dans la bibliothèque V2.
//
// Grille didactique (cf `feedback_illustration_didactic_grid`) :
//   - Pieds ancrés au sol fixes (référentiel observateur).
//   - Banc / pad rectangulaire fixe en arrière-plan sur lequel reposent les épaules.
//   - Seul le bassin bouge entre les frames (épaules sur le banc, pieds au sol).
//
// Frame 0 : position basse — bassin tombant, fesses près du sol.
// Frame 1 : mi-mouvement — bassin moyennement levé.
// Frame 2 : position haute — bassin aligné épaules-genoux, contraction fessière.
//
// Réf : Stronger by Science — Hip Thrust biomechanics.
import SwiftUI

struct HipThrustIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)
            let equipment = IllustrationStyle.equipment

            // Sol pointillé en bas (ancrage)
            var ground = Path()
            ground.move(to: CGPoint(x: 2 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 46 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Banc/pad FIXE en arrière à gauche (épaules y reposent)
            let benchTopY: CGFloat = 22 * s
            let benchXStart: CGFloat = 4 * s
            let benchXEnd: CGFloat = 18 * s
            var bench = Path()
            bench.move(to: CGPoint(x: benchXStart, y: benchTopY))
            bench.addLine(to: CGPoint(x: benchXEnd, y: benchTopY))
            ctx.stroke(bench, with: .color(equipment),
                       style: StrokeStyle(lineWidth: 3 * s, lineCap: .round))
            // Pied du banc
            var benchLeg = Path()
            benchLeg.move(to: CGPoint(x: 8 * s, y: benchTopY + 1 * s))
            benchLeg.addLine(to: CGPoint(x: 8 * s, y: 46 * s))
            ctx.stroke(benchLeg, with: .color(equipment),
                       style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))

            // Pieds au sol FIXES (côté droit)
            let footX: CGFloat = 38 * s
            let footY: CGFloat = 46 * s
            // Genoux : au-dessus des pieds, hauteur fixe (fémur ~horizontal en frame 2)
            let kneeX: CGFloat = 38 * s
            let kneeY: CGFloat = 32 * s

            // Épaules FIXES sur le banc (y=banchTopY-1s)
            let shoulderX: CGFloat = 14 * s
            let shoulderY: CGFloat = benchTopY - 1 * s

            // Bassin (hanche) bouge selon frame
            // Position horizontale fixe entre épaule et genou (~milieu)
            let hipX: CGFloat = (shoulderX + kneeX) / 2
            let hipY: CGFloat
            switch frame {
            case 0: hipY = 42 * s  // bas — bassin tombant
            case 1: hipY = 36 * s  // mi
            default: hipY = 32 * s // top — aligné épaules-genoux (ligne droite)
            }

            // Tête (au bout du banc, juste derrière les épaules)
            let headSize: CGFloat = 5 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: shoulderX - 4 * s - headSize / 2, y: shoulderY - headSize / 2 - 1 * s,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc (épaules → hanche)
            var trunk = Path()
            trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
            trunk.addLine(to: CGPoint(x: hipX, y: hipY))
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Cuisses (hanche → genou)
            var thigh = Path()
            thigh.move(to: CGPoint(x: hipX, y: hipY))
            thigh.addLine(to: CGPoint(x: kneeX, y: kneeY))
            ctx.stroke(thigh, with: .color(silhouette), style: stroke)

            // Tibias (genou → pied)
            var shin = Path()
            shin.move(to: CGPoint(x: kneeX, y: kneeY))
            shin.addLine(to: CGPoint(x: footX, y: footY))
            ctx.stroke(shin, with: .color(silhouette), style: stroke)

            // Annotation : flèche orange ↑ au-dessus du bassin en frame 2 (contraction haute)
            if frame == 2 {
                let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
                var arrow = Path()
                arrow.move(to: CGPoint(x: hipX + 6 * s, y: hipY + 2 * s))
                arrow.addLine(to: CGPoint(x: hipX + 6 * s, y: hipY - 6 * s))
                arrow.move(to: CGPoint(x: hipX + 4 * s, y: hipY - 4 * s))
                arrow.addLine(to: CGPoint(x: hipX + 6 * s, y: hipY - 6 * s))
                arrow.addLine(to: CGPoint(x: hipX + 8 * s, y: hipY - 4 * s))
                ctx.stroke(arrow, with: .color(IllustrationStyle.movementArrow), style: arrowStyle)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("HipThrust — 3 frames") {
    HStack(spacing: 4) {
        HipThrustIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        HipThrustIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        HipThrustIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
