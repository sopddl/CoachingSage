// Views/Components/Illustrations/TricepsOverheadIllustration.swift
// Revue dessins muscu 2026-06-08 — extension triceps nuque (overhead DB triceps extension).
// Debout (profil), un haltère tenu à deux mains DERRIÈRE la tête → extension des bras
// vers le haut. 3 frames (coudes pliés derrière la nuque → bras tendus en haut).
import SwiftUI

struct TricepsOverheadIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)
            let ext: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 plié nuque, 1 tendu haut

            // Corps debout (profil)
            let ankle = p(22, 44), knee = p(22, 33), hip = p(22, 23), shldr = p(22, 13), headC = p(22, 8)
            StrengthFigureKit.limb(ctx, [p(18, 44), p(27, 44)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [ankle, knee, hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Bras : coude reste HAUT près de la tête (signature triceps), avant-bras pivote
            // de derrière la nuque (plié) vers le haut (tendu). Haltère tenu à 2 mains au bout.
            let elbow = p(25, 6)                       // coude au-dessus de la tête (fixe)
            let hand = p(L(30, 26, ext), L(14, 1, ext)) // derrière-bas → haut
            StrengthFigureKit.limb(ctx, [shldr, elbow, hand], color: body, s: s)
            StrengthFigureKit.dumbbell(ctx, center: hand, s: s)

            // Flèche d'extension vers le haut
            if frame >= 1 {
                var up = Path()
                up.move(to: p(36, 18)); up.addLine(to: p(36, 8))
                up.move(to: p(36, 8)); up.addLine(to: p(33, 11))
                up.move(to: p(36, 8)); up.addLine(to: p(39, 11))
                ctx.stroke(up, with: .color(IllustrationStyle.movementArrow),
                           style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
            }
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
