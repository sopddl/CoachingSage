// Views/Components/Illustrations/LegPressIllustration.swift
// Party illustrations 2026-06-08 — Leg press machine REFONDU (trou .generic confirmé au dump).
// Vue de PROFIL, assis incliné dos calé : les jambes poussent le chariot lesté de la position
// fléchie (frame 0, genoux vers la poitrine) à l'extension (frame 2). Quadriceps + fessiers.
import SwiftUI

struct LegPressIllustration: View {
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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 fléchi, 1 jambes tendues

            // Dossier incliné (bas-gauche) + assise
            StrengthFigureKit.limb(ctx, [p(6, 32), p(13, 20)], color: IllustrationStyle.equipment, s: s) // dossier
            StrengthFigureKit.box(ctx, rect: CGRect(x: 8 * s, y: 32 * s, width: 8 * s, height: 3 * s), s: s) // assise

            // Corps : dos calé contre le dossier incliné
            let hip = p(13, 31)
            StrengthFigureKit.headNeck(ctx, head: p(8, 17), shoulder: p(11, 21), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(11, 21), hip], color: body, s: s) // tronc le long du dossier

            // Jambes : pied sur le chariot qui s'éloigne en diagonale haut-droite ; genou plie
            let foot = p(L(24, 41, r), L(22, 9, r))
            let knee = p(L(23, 30, r), L(15, 20, r))
            StrengthFigureKit.limb(ctx, [hip, knee, foot], color: body, s: s)

            // Chariot lesté = plaque perpendiculaire à la jambe au niveau du pied
            let plateAngle = atan2(foot.y - knee.y, foot.x - knee.x) + .pi / 2
            let dx = cos(plateAngle) * 5 * s, dy = sin(plateAngle) * 5 * s
            StrengthFigureKit.limb(ctx, [CGPoint(x: foot.x - dx, y: foot.y - dy), CGPoint(x: foot.x + dx, y: foot.y + dy)],
                                   color: IllustrationStyle.load, s: s, heavy: true)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Leg press") {
    HStack(spacing: 4) {
        LegPressIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LegPressIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LegPressIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
