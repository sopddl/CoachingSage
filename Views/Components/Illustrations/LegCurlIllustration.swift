// Views/Components/Illustrations/LegCurlIllustration.swift
// Party illustrations 2026-06-08 — Leg curl couché machine REFONDU (trou .generic confirmé au dump).
// Vue de PROFIL, allongé sur le ventre : corps fixe horizontal, le tibia se fléchit de la position
// tendue (frame 0) vers les fessiers (frame 2). Ischio-jambiers isolés. Pad de charge à la cheville.
import SwiftUI

struct LegCurlIllustration: View {
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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 jambe tendue, 1 talon fléchi

            // Banc machine (corps posé dessus)
            StrengthFigureKit.box(ctx, rect: CGRect(x: 8 * s, y: 26 * s, width: 28 * s, height: 4 * s), s: s, filled: true)

            // Corps allongé sur le ventre, de profil : tête à gauche, hanche à droite
            StrengthFigureKit.headNeck(ctx, head: p(8, 22), shoulder: p(13, 25), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(13, 25), p(30, 25)], color: body, s: s)   // tronc allongé
            let knee = p(36, 25)
            StrengthFigureKit.limb(ctx, [p(30, 25), knee], color: body, s: s)         // cuisse

            // Tibia : pivote autour du genou, tendu horizontal → fléchi vers le haut (fessiers)
            let ankle = p(L(45, 33, r), L(25, 11, r))
            StrengthFigureKit.limb(ctx, [knee, ankle], color: body, s: s)
            StrengthFigureKit.barbellEndOn(ctx, center: ankle, s: s) // pad de charge cheville
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Leg curl") {
    HStack(spacing: 4) {
        LegCurlIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LegCurlIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LegCurlIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
