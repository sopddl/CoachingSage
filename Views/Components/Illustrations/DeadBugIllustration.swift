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

            // Sol = mat où le dos repose (ligne pleine basse, pas le sol pointillé habituel)
            StrengthFigureKit.limb(ctx, [p(6, 42), p(42, 42)], color: IllustrationStyle.groundLine, s: s)
            let ext: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // extension controlatérale

            // Dos à plat sur le sol (tête à gauche), bien posé sur le mat
            let shldr = p(16, 41), hip = p(28, 41), headC = p(11, 40)
            StrengthFigureKit.limb(ctx, [shldr, hip], color: bodyColor, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: bodyColor, s: s, r: 2.6)

            // Membres AU REPOS (estompés) pointant vers le HAUT (bras tendu vertical + genou tabletop) :
            // donne de la hauteur verticale → la posture « sur le dos, membres en l'air » se lit.
            StrengthFigureKit.limb(ctx, [shldr, p(16, 22)], color: faint, s: s)               // bras haut
            StrengthFigureKit.limb(ctx, [hip, p(28, 24), p(34, 24)], color: faint, s: s)        // genou haut (tabletop)

            // Membres ACTIFS : bras tendu vers l'arrière (au-dessus de la tête, vers le sol) +
            // jambe opposée qui se TEND (du genou-haut vers l'avant, parallèle au sol).
            let hand = mix(p(16, 22), p(5, 35), ext)
            StrengthFigureKit.limb(ctx, [shldr, hand], color: bodyColor, s: s)
            let foot = mix(p(34, 24), p(44, 37), ext)
            StrengthFigureKit.limb(ctx, [hip, mix(p(31, 30), p(39, 37), ext), foot], color: bodyColor, s: s)
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
