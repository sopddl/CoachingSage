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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 fléchi (genoux pliés), 1 jambes tendues

            // Machine : dossier INCLINÉ bas-gauche (le dos s'appuie dessus) + assise horizontale.
            StrengthFigureKit.limb(ctx, [p(7, 40), p(17, 22)], color: IllustrationStyle.equipment, s: s) // dossier incliné
            StrengthFigureKit.limb(ctx, [p(8, 40), p(20, 40)], color: IllustrationStyle.equipment, s: s) // assise au sol

            // Corps assis reclu : bassin sur l'assise, dos calé contre le dossier incliné.
            let hip = p(18, 38)
            StrengthFigureKit.headNeck(ctx, head: p(9, 20), shoulder: p(12, 24), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(12, 24), hip], color: body, s: s) // tronc le long du dossier

            // Jambes : les pieds poussent un chariot qui s'éloigne en DIAGONALE HAUT-DROITE le long
            // du rail. Fléchi (genou ramené vers la poitrine) → tendu (jambes allongées).
            let foot = p(L(28, 44, r), L(26, 14, r))
            let knee = p(L(27, 34, r), L(18, 22, r))
            StrengthFigureKit.limb(ctx, [hip, knee, foot], color: body, s: s)

            // Rail du chariot (guide visuel léger, du pied vers le haut-droite)
            StrengthFigureKit.limb(ctx, [p(20, 40), p(46, 12)], color: IllustrationStyle.equipment, s: s)

            // Chariot lesté = plaque perpendiculaire à la jambe, posée sous les pieds
            let plateAngle = atan2(foot.y - knee.y, foot.x - knee.x) + .pi / 2
            let dx = cos(plateAngle) * 6 * s, dy = sin(plateAngle) * 6 * s
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
