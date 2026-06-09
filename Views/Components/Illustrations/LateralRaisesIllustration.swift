// Views/Components/Illustrations/LateralRaisesIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — élévations latérales REFONDUES.
// Vue de FACE (exception assumée : le geste = abduction des bras sur les côtés, illisible
// de profil). Les haltères montent des cuisses jusqu'à hauteur d'épaules (forme en T).
import SwiftUI

struct LateralRaisesIllustration: View {
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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 bras bas, 1 bras à l'horizontale

            // Corps de face
            StrengthFigureKit.headNeck(ctx, head: p(24, 9), shoulder: p(24, 15), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 15), p(24, 30)], color: body, s: s)       // tronc
            StrengthFigureKit.limb(ctx, [p(24, 30), p(19, 44)], color: body, s: s)       // jambe G
            StrengthFigureKit.limb(ctx, [p(24, 30), p(29, 44)], color: body, s: s)       // jambe D
            let shoulderL = p(20, 15), shoulderR = p(28, 15)
            StrengthFigureKit.limb(ctx, [shoulderL, shoulderR], color: body, s: s)        // ligne d'épaules

            // Bras qui s'élèvent symétriquement
            let handL = p(L(16, 9, r), L(28, 15, r))
            let handR = p(L(32, 39, r), L(28, 15, r))
            StrengthFigureKit.limb(ctx, [shoulderL, handL], color: body, s: s)
            StrengthFigureKit.limb(ctx, [shoulderR, handR], color: body, s: s)
            StrengthFigureKit.dumbbell(ctx, center: handL, s: s)
            StrengthFigureKit.dumbbell(ctx, center: handR, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Élévations latérales") {
    HStack(spacing: 4) {
        LateralRaisesIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LateralRaisesIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        LateralRaisesIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
