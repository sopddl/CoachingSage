// Views/Components/Illustrations/TricepsPushdownIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — triceps pushdown REFONDU (profil).
// Coude FIXE au corps, l'avant-bras pousse la poignée vers le BAS (extension du coude). Câble en haut.
import SwiftUI

struct TricepsPushdownIllustration: View {
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
            let e: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 avant-bras haut, 1 tendu bas

            let ankle = p(22, 44), knee = p(22, 34), hip = p(22, 25), shldr = p(22, 15), headC = p(22, 10)
            StrengthFigureKit.limb(ctx, [p(18, 44), p(27, 44)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [ankle, knee, hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Coude COLLÉ au corps (fixe), l'avant-bras passe de plié (haut) à tendu (bas) : extension nette
            // Main qui part à hauteur de poitrine (PAS près de la tête → évite l'effet « gratte la nuque »)
            let elbow = p(23, 25)
            let hand = p(L(25, 27, e), L(22, 33, e))
            // Câble du haut vers la main
            StrengthFigureKit.limb(ctx, [p(27, 4), hand], color: IllustrationStyle.groundLine, s: s)
            StrengthFigureKit.limb(ctx, [shldr, elbow, hand], color: body, s: s)
            // Poignée (petite barre horizontale)
            StrengthFigureKit.limb(ctx, [CGPoint(x: hand.x - 3 * s, y: hand.y), CGPoint(x: hand.x + 3 * s, y: hand.y)],
                                   color: IllustrationStyle.equipment, s: s, heavy: true)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Triceps pushdown") {
    HStack(spacing: 4) {
        TricepsPushdownIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        TricepsPushdownIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        TricepsPushdownIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
