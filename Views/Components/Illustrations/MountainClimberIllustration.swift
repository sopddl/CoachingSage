// Views/Components/Illustrations/MountainClimberIllustration.swift
// Party illustrations 2026-06-08 — lot HIIT. Mountain climbers vue de PROFIL : position de
// gainage type planche (mains au sol), un genou monte vers la poitrine (frame 0 tendu → frame 2 ramené).
import SwiftUI

struct MountainClimberIllustration: View {
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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 jambe tendue arrière, 1 genou ramené sous la poitrine

            // Planche HAUTE (gainage) vue de profil, face à gauche : bras tendu vertical au sol,
            // tronc quasi horizontal (épaule ≈ hanche), pas de pike. Le genou avant est ramené
            // nettement sous le torse vers les mains (key gesture du mountain climber).
            let hand = p(13, 42), shoulder = p(15, 32), hip = p(34, 31)
            StrengthFigureKit.headNeck(ctx, head: p(9, 31), shoulder: shoulder, color: body, s: s)
            StrengthFigureKit.limb(ctx, [hand, shoulder], color: body, s: s)   // bras tendu vertical au sol
            StrengthFigureKit.limb(ctx, [shoulder, hip], color: body, s: s)    // tronc horizontal

            // Jambe arrière tendue loin derrière (statique) — aligne tronc + jambe = planche
            StrengthFigureKit.limb(ctx, [hip, p(47, 42)], color: body, s: s)
            // Jambe avant : genou ramené franchement sous la poitrine vers les mains
            let knee = p(L(40, 22, r), L(36, 39, r))
            let foot = p(L(48, 26, r), L(42, 43, r))
            StrengthFigureKit.limb(ctx, [hip, knee, foot], color: body, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Mountain climber") {
    HStack(spacing: 4) {
        MountainClimberIllustration(sportCode: "hiit", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        MountainClimberIllustration(sportCode: "hiit", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        MountainClimberIllustration(sportCode: "hiit", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
