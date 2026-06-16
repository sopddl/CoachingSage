// Views/Components/Illustrations/SledPushIllustration.swift
// Party illustrations 2026-06-08 — lot HIIT. Sled push vue de PROFIL : buste penché vers
// l'avant, bras tendus sur le montant du traîneau lesté, jambes qui poussent (foulée frame 0→2).
import SwiftUI

struct SledPushIllustration: View {
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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1)

            // Traîneau : base au sol (droite) + montant + disque lesté
            StrengthFigureKit.box(ctx, rect: CGRect(x: 36 * s, y: 39 * s, width: 9 * s, height: 4 * s), s: s, filled: true)
            StrengthFigureKit.limb(ctx, [p(39, 39), p(39, 29)], color: IllustrationStyle.equipment, s: s, heavy: true)
            StrengthFigureKit.barbellEndOn(ctx, center: p(39, 41), s: s)

            // Corps penché, en appui bras tendus sur le montant
            let head = p(8, 19), shoulder = p(13, 22), hip = p(22, 28)
            StrengthFigureKit.headNeck(ctx, head: head, shoulder: shoulder, color: body, s: s)
            StrengthFigureKit.limb(ctx, [shoulder, hip], color: body, s: s)         // tronc penché
            StrengthFigureKit.limb(ctx, [shoulder, p(39, 29)], color: body, s: s)   // bras tendus vers le montant

            // Jambes en poussée (arrière tendue, avant fléchie) — foulée animée
            StrengthFigureKit.limb(ctx, [hip, p(L(12, 8, r), 44)], color: body, s: s)                 // jambe arrière
            StrengthFigureKit.limb(ctx, [hip, p(L(24, 27, r), L(36, 38, r)), p(L(28, 32, r), 44)], color: body, s: s) // jambe avant fléchie
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Sled push") {
    HStack(spacing: 4) {
        SledPushIllustration(sportCode: "hiit", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        SledPushIllustration(sportCode: "hiit", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        SledPushIllustration(sportCode: "hiit", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
