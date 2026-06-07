// Views/Components/Illustrations/ClamshellIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — clamshell REFONDU.
// Allongé sur le côté, genoux fléchis empilés, pieds joints : le genou du DESSUS s'ouvre
// vers le haut (rotation hanche, moyen fessier). Jambe du dessous estompée.
import SwiftUI

struct ClamshellIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let bodyColor = IllustrationStyle.silhouette(sportCode: sportCode)
            let faint = bodyColor.opacity(0.4)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func mix(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
                CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
            }

            // Sol où le corps repose sur le côté (ligne pleine basse)
            StrengthFigureKit.limb(ctx, [p(4, 43), p(44, 43)], color: IllustrationStyle.groundLine, s: s)
            let o: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // ouverture du genou

            // Tronc couché sur le côté (tête à gauche), figure agrandie + remontée
            let shldr = p(13, 25), hip = p(31, 33), headC = p(8, 21)
            StrengthFigureKit.limb(ctx, [shldr, hip], color: bodyColor, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: bodyColor, s: s, r: 3)
            StrengthFigureKit.limb(ctx, [shldr, p(8, 34), p(8, 43)], color: bodyColor, s: s) // bras d'appui au sol

            // Pieds joints (talons ensemble) au sol = pivot ; genoux fléchis devant
            let foot = p(43, 43)
            // Jambe du DESSOUS (estompée, posée au sol) : genou en avant-bas
            StrengthFigureKit.limb(ctx, [hip, p(41, 40), foot], color: faint, s: s)
            // Jambe du DESSUS : le genou s'ouvre TRÈS franchement vers le HAUT (talon reste joint)
            let knee = mix(p(41, 39), p(35, 17), o)
            StrengthFigureKit.limb(ctx, [hip, knee, foot], color: bodyColor, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Clamshell") {
    HStack(spacing: 4) {
        ClamshellIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        ClamshellIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        ClamshellIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
