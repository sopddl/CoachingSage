// Views/Components/Illustrations/ForearmPlankIllustration.swift
// Story 3.23 Lot 3 — forearm plank (low plank) statique 1 frame, viewbox 80×48.
// Distinct de CoreIllustration.frontal (high-plank paumes au sol bras tendus).
// Source : https://en.wikipedia.org/wiki/Plank_(exercise)
// Signature : corps horizontal strict + appui sur AVANT-BRAS coudés à 90° au sol.
import SwiftUI

struct ForearmPlankIllustration: View {
    let sportCode: String
    var size: CGFloat = IllustrationStyle.staticFrameSize.height // revue 2026-06-08 : scale (cf yoga)

    var body: some View {
        Canvas { ctx, size in
            let sx = size.width / IllustrationStyle.staticFrameSize.width
            let sy = size.height / IllustrationStyle.staticFrameSize.height
            let s = min(sx, sy)
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)

            // Sol pointillé
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 44 * s))
            ground.addLine(to: CGPoint(x: 76 * s, y: 44 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Revue 2026-06-08 (round 2) : aligné sur la géométrie de CoreIllustration.frontal
            // validée Sally+Maxime — corps BAS HORIZONTAL (gainé), tête ATTACHÉE au bout, appuis
            // COURTS (avant l'ancien : tête détachée + tronc haut = « table »).
            let bodyY: CGFloat = 32 * s
            let shoulder = CGPoint(x: 24 * s, y: bodyY)   // épaule (gauche, sous la tête)
            let heel = CGPoint(x: 64 * s, y: bodyY)        // talons (droite)

            // Tête (à gauche, devant l'épaule, regard vers le sol)
            let headSize: CGFloat = 6 * s
            let headC = CGPoint(x: 17 * s, y: bodyY - 1 * s)
            ctx.stroke(Path(ellipseIn: CGRect(x: headC.x - headSize / 2, y: headC.y - headSize / 2,
                                              width: headSize, height: headSize)),
                       with: .color(silhouette), style: stroke)

            // Corps + jambes : tête → épaule → talons, HORIZONTAL (gainé)
            var line = Path()
            line.move(to: CGPoint(x: headC.x + headSize / 2, y: bodyY))
            line.addLine(to: shoulder)
            line.addLine(to: heel)
            ctx.stroke(line, with: .color(silhouette), style: stroke)

            // Avant-bras d'appui COURT sous l'épaule (coude au sol → main vers l'avant)
            var forearm = Path()
            forearm.move(to: shoulder)
            forearm.addLine(to: CGPoint(x: shoulder.x, y: 40 * s))
            forearm.addLine(to: CGPoint(x: shoulder.x + 7 * s, y: 40 * s))
            ctx.stroke(forearm, with: .color(silhouette), style: stroke)

            // Orteils en appui COURT (talon → pointe au sol)
            var toes = Path()
            toes.move(to: heel)
            toes.addLine(to: CGPoint(x: heel.x + 3 * s, y: 40 * s))
            ctx.stroke(toes, with: .color(silhouette), style: stroke)

            // Ligne d'alignement pointillée le long du corps (gainage droit)
            var alignment = Path()
            alignment.move(to: CGPoint(x: shoulder.x - 2 * s, y: bodyY - 4 * s))
            alignment.addLine(to: CGPoint(x: heel.x, y: bodyY - 4 * s))
            ctx.stroke(alignment, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, dash: [3 * s, 2 * s]))
        }
        .frame(width: size * (IllustrationStyle.staticFrameSize.width / IllustrationStyle.staticFrameSize.height),
               height: size)
    }
}

#if DEBUG
#Preview("Forearm plank — low plank") {
    ForearmPlankIllustration(sportCode: "strengthTraining")
        .padding()
        .background(Color.coachingBackground)
}
#endif
