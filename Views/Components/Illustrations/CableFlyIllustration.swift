// Views/Components/Illustrations/CableFlyIllustration.swift
// Party illustrations 2026-06-08 — Cable fly / pec deck / écarté poulie REFONDU (trou .generic
// confirmé au dump : 4 variantes muscu sans dessin). Vue de FACE (exception assumée comme les
// élévations latérales : le geste = adduction horizontale des bras, illisible de profil).
// Les bras s'ouvrent en croix (frame 0) puis se referment devant la poitrine (frame 2).
import SwiftUI

struct CableFlyIllustration: View {
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
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 bras ouverts, 1 fermés devant

            // Corps de face
            StrengthFigureKit.headNeck(ctx, head: p(24, 9), shoulder: p(24, 15), color: body, s: s)
            StrengthFigureKit.limb(ctx, [p(24, 15), p(24, 30)], color: body, s: s)       // tronc
            StrengthFigureKit.limb(ctx, [p(24, 30), p(20, 44)], color: body, s: s)       // jambe G
            StrengthFigureKit.limb(ctx, [p(24, 30), p(28, 44)], color: body, s: s)       // jambe D
            let shoulderL = p(20, 16), shoulderR = p(28, 16)
            StrengthFigureKit.limb(ctx, [shoulderL, shoulderR], color: body, s: s)        // ligne d'épaules

            // Bras : coudes fixes mi-hauteur, mains de grand-écart (r=0) → jointes devant (r=1)
            let elbowL = p(L(10, 19, r), 20), elbowR = p(L(38, 29, r), 20)
            let handL = p(L(7, 22, r), L(20, 22, r))
            let handR = p(L(41, 26, r), L(20, 22, r))
            StrengthFigureKit.limb(ctx, [shoulderL, elbowL, handL], color: body, s: s)
            StrengthFigureKit.limb(ctx, [shoulderR, elbowR, handR], color: body, s: s)
            // Poignées de poulie (petits cercles charge)
            StrengthFigureKit.dumbbell(ctx, center: handL, s: s)
            StrengthFigureKit.dumbbell(ctx, center: handR, s: s)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
#Preview("Cable fly") {
    HStack(spacing: 4) {
        CableFlyIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        CableFlyIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        CableFlyIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding().background(Color.coachingBackground)
}
#endif
