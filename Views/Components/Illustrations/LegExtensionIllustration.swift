// Views/Components/Illustrations/LegExtensionIllustration.swift
// Party illustrations 2026-06-08 — Leg extension machine REFONDU (trou .generic confirmé au dump).
// Vue de PROFIL, assis sur la machine : cuisse fixe horizontale, le tibia s'étend de la verticale
// basse (frame 0) à l'horizontale (frame 2). Quadriceps isolé. Pad de charge à la cheville.
import SwiftUI

struct LegExtensionIllustration: View {
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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 tibia bas, 1 tendu horizontal

            // Machine : assise + dossier
            StrengthFigureKit.box(ctx, rect: CGRect(x: 10 * s, y: 26 * s, width: 14 * s, height: 4 * s), s: s) // assise
            StrengthFigureKit.limb(ctx, [p(11, 26), p(9, 12)], color: IllustrationStyle.equipment, s: s)        // dossier

            // Corps assis de profil : dos contre dossier, cuisse horizontale
            let hip = p(13, 25)
            StrengthFigureKit.headNeck(ctx, head: p(11, 9), shoulder: p(12, 14), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(12, 14), hip], color: body, s: s)        // tronc
            let knee = p(26, 25)
            StrengthFigureKit.limb(ctx, [hip, knee], color: body, s: s)             // cuisse horizontale

            // Tibia : pivote autour du genou, vertical bas → horizontal
            let ankle = p(L(26, 42, r), L(40, 25, r))
            StrengthFigureKit.limb(ctx, [knee, ankle], color: body, s: s)
            // Pad de charge à la cheville
            StrengthFigureKit.barbellEndOn(ctx, center: ankle, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Leg extension") {
    HStack(spacing: 4) {
        LegExtensionIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LegExtensionIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LegExtensionIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
