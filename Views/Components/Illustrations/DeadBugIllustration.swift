// Views/Components/Illustrations/DeadBugIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — dead-bug REFONDU (profil).
// Allongé sur le dos (gainage) : bras + jambe OPPOSÉE s'étendent en controlatéral,
// le bas du dos reste plaqué. Membres « au repos » estompés, membres actifs pleins.
import SwiftUI

struct DeadBugIllustration: View {
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
            let ext: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // extension controlatérale

            // Tronc allongé sur le sol (tête à gauche)
            let shldr = p(15, 40), hip = p(27, 40), headC = p(11, 39)
            StrengthFigureKit.limb(ctx, [shldr, hip], color: bodyColor, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: bodyColor, s: s, r: 2.6)

            // Membres au repos (estompés) : bras levé + genou en tabletop
            StrengthFigureKit.limb(ctx, [shldr, p(15, 30)], color: faint, s: s)
            StrengthFigureKit.limb(ctx, [hip, p(27, 30), p(33, 30)], color: faint, s: s)

            // Membres actifs : bras vers l'arrière (au-dessus tête) + jambe opposée tendue
            let hand = mix(p(15, 30), p(6, 34), ext)
            StrengthFigureKit.limb(ctx, [shldr, hand], color: bodyColor, s: s)
            let foot = mix(p(33, 30), p(43, 37), ext)
            StrengthFigureKit.limb(ctx, [hip, mix(p(31, 33), p(38, 37), ext), foot], color: bodyColor, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Dead bug") {
    HStack(spacing: 4) {
        DeadBugIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        DeadBugIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        DeadBugIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
