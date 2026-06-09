// Views/Components/Illustrations/TurkishGetUpIllustration.swift
// Party illustrations 2026-06-08 — lot HIIT. Turkish get-up (kettlebell) vue de PROFIL, en
// STORYBOARD 3 postures distinctes : allongé bras tendu vers le plafond (frame 0) → appui sur
// la main, buste relevé (frame 1) → demi-agenouillé / debout, charge au-dessus (frame 2).
// Le bras tenant la charge reste VERTICAL tout du long (clé technique).
import SwiftUI

struct TurkishGetUpIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

            StrengthFigureKit.ground(ctx, s: s)

            switch frame {
            case 0: // Allongé sur le dos, bras tendu vertical vers le plafond, un genou plié
                let shoulder = p(18, 41), hand = p(18, 24)
                StrengthFigureKit.limb(ctx, [p(10, 41), shoulder], color: body, s: s)   // buste au sol
                StrengthFigureKit.headNeck(ctx, head: p(8, 40), shoulder: shoulder, color: body, s: s)
                StrengthFigureKit.limb(ctx, [shoulder, hand], color: body, s: s)         // bras vertical
                StrengthFigureKit.limb(ctx, [p(24, 41), p(31, 35), p(33, 42)], color: body, s: s) // genou plié
                StrengthFigureKit.limb(ctx, [p(24, 41), p(42, 43)], color: body, s: s)  // jambe tendue
                StrengthFigureKit.kettlebell(ctx, center: p(18, 21), s: s)
            case 1: // Appui sur la main libre, buste relevé en diagonale, bras toujours vertical
                let shoulder = p(22, 29), hand = p(22, 14)
                StrengthFigureKit.limb(ctx, [p(11, 42), p(16, 36), shoulder], color: body, s: s) // main au sol → buste
                StrengthFigureKit.headNeck(ctx, head: p(20, 24), shoulder: shoulder, color: body, s: s)
                StrengthFigureKit.limb(ctx, [shoulder, hand], color: body, s: s)         // bras vertical
                StrengthFigureKit.limb(ctx, [p(24, 33), p(31, 36), p(33, 44)], color: body, s: s) // genou plié pied au sol
                StrengthFigureKit.limb(ctx, [p(24, 33), p(40, 44)], color: body, s: s)  // jambe étendue
                StrengthFigureKit.kettlebell(ctx, center: p(22, 11), s: s)
            default: // Demi-agenouillé, torse vertical, charge au-dessus de la tête
                let shoulder = p(24, 18), hand = p(24, 7)
                StrengthFigureKit.limb(ctx, [p(24, 32), shoulder], color: body, s: s)    // tronc droit
                StrengthFigureKit.headNeck(ctx, head: p(24, 14), shoulder: shoulder, color: body, s: s)
                StrengthFigureKit.limb(ctx, [shoulder, hand], color: body, s: s)         // bras vertical overhead
                StrengthFigureKit.limb(ctx, [p(24, 32), p(31, 38), p(31, 44)], color: body, s: s) // jambe avant fléchie
                StrengthFigureKit.limb(ctx, [p(24, 32), p(18, 40), p(15, 44)], color: body, s: s) // genou arrière au sol
                StrengthFigureKit.kettlebell(ctx, center: p(24, 4), s: s)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Turkish get-up") {
    HStack(spacing: 4) {
        TurkishGetUpIllustration(sportCode: "hiit", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        TurkishGetUpIllustration(sportCode: "hiit", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        TurkishGetUpIllustration(sportCode: "hiit", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
