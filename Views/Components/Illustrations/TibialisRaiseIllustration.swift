// Views/Components/Illustrations/TibialisRaiseIllustration.swift
// Party illustrations 2026-06-08 — lot HIIT. Tibialis raises vue de PROFIL : debout dos calé,
// les orteils montent (dorsiflexion, talon au sol) — frame 0 pied à plat → frame 2 pointe levée.
import SwiftUI

struct TibialisRaiseIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 pied à plat, 1 orteils levés

            // Mur de soutien (dos calé) à gauche
            StrengthFigureKit.limb(ctx, [p(10, 8), p(10, 42)], color: IllustrationStyle.equipment, s: s)

            // Corps debout légèrement incliné, dos vers le mur
            StrengthFigureKit.headNeck(ctx, head: p(15, 10), shoulder: p(14, 16), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(14, 16), p(18, 30)], color: body, s: s)   // tronc
            let heel = p(22, 44)
            StrengthFigureKit.limb(ctx, [p(18, 30), heel], color: body, s: s)        // jambe vers le talon

            // Pied : talon fixe ancré au sol, avant-pied (orteils) qui se lève FRANCHEMENT
            // (dorsiflexion exagérée pour la lisibilité — reproche revue « mouvement invisible »).
            let toe = p(L(34, 30, r), L(44, 31, r))
            StrengthFigureKit.limb(ctx, [heel, toe], color: body, s: s, heavy: true)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Tibialis raise") {
    HStack(spacing: 4) {
        TibialisRaiseIllustration(sportCode: "hiit", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        TibialisRaiseIllustration(sportCode: "hiit", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        TibialisRaiseIllustration(sportCode: "hiit", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
