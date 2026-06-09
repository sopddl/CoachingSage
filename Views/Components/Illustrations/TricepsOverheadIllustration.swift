// Views/Components/Illustrations/TricepsOverheadIllustration.swift
// Revue dessins muscu 2026-06-08 (v3) — extension triceps nuque, VUE DE FACE.
// Le profil (1 trait vertical) lisait « lampe/poteau » en revue → passage en vue de
// face : corps reconnaissable (2 jambes écartées, 2 bras symétriques), les deux mains
// tiennent UN haltère derrière la tête (frame 0, bas) puis tendent les bras vers le
// HAUT (frame 2). Amplitude verticale large.
import SwiftUI

struct TricepsOverheadIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

            StrengthFigureKit.ground(ctx, s: s)

            // Corps DE FACE — IDENTIQUE sur les 3 frames. Figure décalée vers le bas pour
            // laisser de la hauteur au-dessus de la tête → bras visiblement LONGS et tendus.
            let headC = p(26, 13), lShldr = p(20, 20), rShldr = p(32, 20), hip = p(26, 31)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: p(26, 19), color: body, s: s)
            StrengthFigureKit.limb(ctx, [lShldr, rShldr], color: body, s: s)        // ligne d'épaules
            StrengthFigureKit.limb(ctx, [p(26, 19), hip], color: body, s: s)        // tronc
            StrengthFigureKit.limb(ctx, [hip, p(20, 44)], color: body, s: s)        // jambe G
            StrengthFigureKit.limb(ctx, [hip, p(32, 44)], color: body, s: s)        // jambe D

            // Les 2 mains se rejoignent au centre sur l'haltère : bas derrière la tête (frame 0)
            // → tout en haut bras tendus (frame 2, ~17 px d'amplitude). Coudes serrés près de la tête.
            let hand: CGPoint = frame == 0 ? p(26, 20) : (frame == 1 ? p(26, 11) : p(26, 2))
            let lElbow = p(22, 10), rElbow = p(30, 10)
            StrengthFigureKit.limb(ctx, [lShldr, lElbow, hand], color: body, s: s)
            StrengthFigureKit.limb(ctx, [rShldr, rElbow, hand], color: body, s: s)
            StrengthFigureKit.dumbbell(ctx, center: hand, s: s)

            // Flèche montante unique, à droite (n'empiète pas sur le corps).
            var up = Path()
            up.move(to: p(40, 20)); up.addLine(to: p(40, 5))
            up.move(to: p(40, 5)); up.addLine(to: p(37, 8))
            up.move(to: p(40, 5)); up.addLine(to: p(43, 8))
            ctx.stroke(up, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Triceps overhead") {
    HStack {
        TricepsOverheadIllustration(sportCode: "strengthTraining", frame: 0)
        TricepsOverheadIllustration(sportCode: "strengthTraining", frame: 1)
        TricepsOverheadIllustration(sportCode: "strengthTraining", frame: 2)
    }.padding().background(Color.coachingBackground)
}
#endif
