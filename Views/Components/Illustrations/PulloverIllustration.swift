// Views/Components/Illustrations/PulloverIllustration.swift
// Revue dessins muscu 2026-06-08 (re-jet expert pictos) — dumbbell pullover.
// Profil, allongé sur un banc, tête à GAUCHE. Le bras + l'haltère sont dessinés sur
// les 3 frames (correction revue : avant, ils n'apparaissaient qu'à la frame 3) :
// arc autour de l'épaule de DERRIÈRE la tête (bas, étirement) → vertical → au-dessus
// de la poitrine. 1 seule flèche en arc.
import SwiftUI

struct PulloverIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

            StrengthFigureKit.ground(ctx, s: s)

            // Banc horizontal sous le tronc.
            StrengthFigureKit.box(ctx, rect: CGRect(x: 6 * s, y: 34 * s, width: 34 * s, height: 5 * s), s: s, filled: true)

            // Corps allongé sur le banc — IDENTIQUE sur les 3 frames. Tête à gauche.
            let shldr = p(24, 31), hip = p(38, 31)
            StrengthFigureKit.limb(ctx, [shldr, hip], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: p(9, 31), shoulder: shldr, color: body, s: s)
            // Jambes pliées, pieds au sol à droite.
            StrengthFigureKit.limb(ctx, [hip, p(44, 38), p(40, 44)], color: body, s: s)

            // Bras actif (épaule = pivot), DESSINÉ sur les 3 frames : arc derrière tête → poitrine.
            // frame 0 : bras relevé en diagonale nette (pas horizontal → ne se confond plus
            // avec le banc, haltère détaché du corps lu en revue). frame 2 : ramené plus bas
            // vers la poitrine (pas « drapeau vertical »).
            let hand: CGPoint = frame == 0 ? p(7, 22) : (frame == 1 ? p(22, 11) : p(33, 20))
            StrengthFigureKit.limb(ctx, [shldr, hand], color: body, s: s)
            StrengthFigureKit.dumbbell(ctx, center: hand, s: s)

            // Petite flèche courbe au-dessus du corps (sens du balayage gauche→droite),
            // courte et détachée du bras pour ne pas lire « fil emmêlé » (revue Maxime).
            var arc = Path()
            arc.move(to: p(14, 6))
            arc.addQuadCurve(to: p(30, 8), control: p(22, 1))
            arc.move(to: p(30, 8)); arc.addLine(to: p(25, 7))
            arc.move(to: p(30, 8)); arc.addLine(to: p(28, 12))
            ctx.stroke(arc, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Pullover") {
    HStack {
        PulloverIllustration(sportCode: "strengthTraining", frame: 0)
        PulloverIllustration(sportCode: "strengthTraining", frame: 1)
        PulloverIllustration(sportCode: "strengthTraining", frame: 2)
    }.padding().background(Color.coachingBackground)
}
#endif
