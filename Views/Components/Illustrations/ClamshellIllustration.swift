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

            StrengthFigureKit.ground(ctx, s: s)
            let o: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // ouverture du genou

            // Tronc couché sur le côté (tête à gauche), appui sur l'avant-bras
            let shldr = p(12, 33), hip = p(28, 36), headC = p(8, 31)
            StrengthFigureKit.limb(ctx, [shldr, hip], color: bodyColor, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: bodyColor, s: s, r: 2.6)
            StrengthFigureKit.limb(ctx, [shldr, p(10, 42)], color: bodyColor, s: s) // avant-bras d'appui

            // Pieds joints (talons ensemble) — point d'ancrage commun
            let foot = p(40, 42)
            // Jambe du dessous (estompée, posée au sol)
            StrengthFigureKit.limb(ctx, [hip, p(34, 42), foot], color: faint, s: s)
            // Jambe du dessus : genou s'ouvre vers le haut, talon reste joint
            let knee = mix(p(34, 40), p(33, 28), o)
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
