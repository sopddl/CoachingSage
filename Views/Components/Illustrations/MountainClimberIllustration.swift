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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 jambe tendue, 1 genou à la poitrine

            // Planche : mains au sol (gauche), corps en diagonale, hanche en haut
            let hand = p(9, 42), shoulder = p(16, 31), hip = p(30, 25)
            StrengthFigureKit.headNeck(ctx, head: p(12, 33), shoulder: shoulder, color: body, s: s)
            StrengthFigureKit.limb(ctx, [hand, shoulder], color: body, s: s)   // bras tendu au sol
            StrengthFigureKit.limb(ctx, [shoulder, hip], color: body, s: s)    // tronc

            // Jambe arrière tendue vers le sol (droite)
            StrengthFigureKit.limb(ctx, [hip, p(44, 41)], color: body, s: s)
            // Jambe avant : genou monte vers la poitrine
            let knee = p(L(36, 24, r), L(33, 27, r))
            let foot = p(L(43, 27, r), L(40, 35, r))
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
