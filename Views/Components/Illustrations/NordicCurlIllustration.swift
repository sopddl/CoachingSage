// Views/Components/Illustrations/NordicCurlIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — nordic curl REFONDU (profil).
// À genoux, chevilles bloquées, le corps reste DROIT (genou→tête) et descend vers l'avant
// (excentrique ischio). Les mains rattrapent près du sol.
import SwiftUI

struct NordicCurlIllustration: View {
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
            let d: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1)

            let knee = p(20, 40)
            // Tibias vers l'arrière + chevilles bloquées (ancrage)
            StrengthFigureKit.limb(ctx, [knee, p(13, 44)], color: body, s: s)
            StrengthFigureKit.box(ctx, rect: CGRect(x: 10 * s, y: 41 * s, width: 6 * s, height: 3 * s), s: s) // ancrage chevilles

            // Corps droit depuis le genou, bascule vers l'avant
            let a = L(10, 78, d) * .pi / 180 // angle depuis la verticale
            let dir = CGPoint(x: sin(a), y: -cos(a))
            let hip = CGPoint(x: knee.x + dir.x * 4 * s, y: knee.y + dir.y * 4 * s)
            let shldr = CGPoint(x: knee.x + dir.x * 15 * s, y: knee.y + dir.y * 15 * s)
            let headC = CGPoint(x: knee.x + dir.x * 19 * s, y: knee.y + dir.y * 19 * s)
            StrengthFigureKit.limb(ctx, [knee, hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Bras : le long du corps debout → tendus vers le sol au plus bas
            let hand = CGPoint(x: shldr.x + L(2, 6, d) * s, y: shldr.y + L(8, 6, d) * s)
            StrengthFigureKit.limb(ctx, [shldr, hand], color: body, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Nordic curl") {
    HStack(spacing: 4) {
        NordicCurlIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        NordicCurlIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        NordicCurlIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
