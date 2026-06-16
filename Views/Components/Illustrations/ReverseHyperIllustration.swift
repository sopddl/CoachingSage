// Views/Components/Illustrations/ReverseHyperIllustration.swift
// Party illustrations 2026-06-08 — Reverse hyperextension banc REFONDU (trou .generic confirmé au dump).
// Vue de PROFIL : buste posé à plat sur un banc haut, hanche au bord ; les jambes tendues montent
// de la verticale basse (frame 0) à l'horizontale (frame 2). Renforcement lombaires + fessiers.
import SwiftUI

struct ReverseHyperIllustration: View {
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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 jambes basses, 1 horizontales

            // Banc haut (buste posé dessus)
            StrengthFigureKit.box(ctx, rect: CGRect(x: 6 * s, y: 22 * s, width: 22 * s, height: 5 * s), s: s, filled: true)
            // Pied de banc
            StrengthFigureKit.limb(ctx, [p(10, 27), p(10, 40)], color: IllustrationStyle.equipment, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 27), p(24, 40)], color: IllustrationStyle.equipment, s: s)

            // Buste à plat sur le banc : tête + mains agrippent le bord avant (gauche)
            StrengthFigureKit.headNeck(ctx, head: p(7, 18), shoulder: p(11, 21), color: body, s: s)
            let hip = p(28, 21)
            StrengthFigureKit.limb(ctx, [p(11, 21), hip], color: body, s: s)   // tronc à plat
            StrengthFigureKit.limb(ctx, [p(11, 21), p(9, 27)], color: body, s: s) // bras qui tient le bord

            // Jambes tendues (ensemble) pivotant à la hanche : verticales bas → horizontales
            let foot = p(L(30, 45, r), L(40, 19, r))
            StrengthFigureKit.limb(ctx, [hip, foot], color: body, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Reverse hyper") {
    HStack(spacing: 4) {
        ReverseHyperIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        ReverseHyperIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        ReverseHyperIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
