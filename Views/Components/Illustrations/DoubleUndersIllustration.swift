// Views/Components/Illustrations/DoubleUndersIllustration.swift
// Party illustrations 2026-06-08 — lot HIIT. Double-unders (corde à sauter) vue de FACE :
// petit saut, la corde passe sous les pieds (frame 0) → sur les côtés → au-dessus (frame 2).
import SwiftUI

struct DoubleUndersIllustration: View {
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
            // Saut net : au sol (frame 0, corde sous les pieds) → en l'air (frame 2, corde au-dessus).
            // L'écart pieds↔sol pointillé rend le « saut » visible (reproche revue : pieds plantés).
            let hop = L(2, -7, r)

            StrengthFigureKit.headNeck(ctx, head: p(24, 9 + hop), shoulder: p(24, 15 + hop), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 15 + hop), p(24, 28 + hop)], color: body, s: s) // tronc
            // Bras le long du corps, avant-bras vers l'extérieur, mains qui tiennent les poignées
            let handL = p(15, 26 + hop), handR = p(33, 26 + hop)
            StrengthFigureKit.limb(ctx, [p(24, 17 + hop), p(20, 24 + hop), handL], color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 17 + hop), p(28, 24 + hop), handR], color: body, s: s)
            // Jambes : tendues+jointes en l'air (frame 2), légèrement fléchies à la réception (frame 0)
            let hip = p(24, 28 + hop)
            let footY = L(43, 38, r) + hop
            StrengthFigureKit.limb(ctx, [hip, p(L(21, 23, r), footY)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [hip, p(L(27, 25, r), footY)], color: body, s: s)

            // Corde à sauter : grande boucle qui passe SOUS les pieds (frame 0) → remonte sur les
            // côtés (frame 1) → AU-DESSUS de la tête (frame 2). Boucle fermée = lecture « corde ».
            let ctrlY = L(52, -4, r)          // bas (sous pieds) → haut (overhead)
            let sideX = L(6, 18, r)           // largeur de la boucle : large en bas, resserrée en haut
            var rope = Path()
            rope.move(to: handL)
            rope.addQuadCurve(to: handR, control: p(24, ctrlY))                      // brin qui balaie
            rope.move(to: handL)
            rope.addQuadCurve(to: handR, control: p(24, L(20, 24, r) + hop))          // brin proche du corps
            // arcs latéraux reliant les mains au brin qui balaie (donne la boucle ovale)
            var loop = Path()
            loop.move(to: handL)
            loop.addQuadCurve(to: p(24, ctrlY), control: p(handL.x - sideX, (handL.y + ctrlY) / 2))
            loop.addQuadCurve(to: handR, control: p(handR.x + sideX, (handR.y + ctrlY) / 2))
            ctx.stroke(rope, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthThin * s, lineCap: .round))
            ctx.stroke(loop, with: .color(IllustrationStyle.equipment),
                       style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidthThin * s, lineCap: .round))
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Double-unders") {
    HStack(spacing: 4) {
        DoubleUndersIllustration(sportCode: "hiit", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        DoubleUndersIllustration(sportCode: "hiit", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        DoubleUndersIllustration(sportCode: "hiit", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
