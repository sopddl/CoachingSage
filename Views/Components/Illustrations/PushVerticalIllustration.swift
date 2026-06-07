// Views/Components/Illustrations/PushVerticalIllustration.swift
// Chantier refonte dessins muscu (2026-06-07) — overhead press REFONDU (profil + variantes).
// Geste clé : la charge part des épaules et monte au-dessus de la tête (bras tendus).
// Variantes : développé militaire barre · développé haltères (Arnold).
import SwiftUI

struct PushVerticalIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    enum Variant { case barbell, dumbbell }
    var variant: Variant { Self.resolveVariant(from: exerciseName) }

    static func resolveVariant(from name: String?) -> Variant {
        guard let lower = name?.lowercased() else { return .barbell }
        if lower.contains("haltère") || lower.contains("haltere") || lower.contains("dumbbell") || lower.contains("arnold") {
            return .dumbbell
        }
        return .barbell
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)
            let pr: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 racké épaules, 1 lockout

            // Corps debout fixe (profil)
            let ankle = p(22, 44), knee = p(22, 33), hip = p(22, 23), shldr = p(22, 13), headC = p(22, 8)
            StrengthFigureKit.limb(ctx, [p(18, 44), p(27, 44)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [ankle, knee, hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Main : épaule (racké, devant la tête) → au-dessus de la tête
            let hand = p(L(26, 23, pr), L(13, 3, pr))
            let elbow = p(L(27, 24, pr), L(18, 8, pr))
            StrengthFigureKit.limb(ctx, [shldr, elbow, hand], color: body, s: s)

            switch variant {
            case .barbell:
                StrengthFigureKit.barbellEndOn(ctx, center: hand, s: s)
            case .dumbbell:
                StrengthFigureKit.dumbbell(ctx, center: hand, s: s)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
private struct PushVRow: View {
    let title: String; let name: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                PushVerticalIllustration(sportCode: "strengthTraining", frame: 0, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                PushVerticalIllustration(sportCode: "strengthTraining", frame: 1, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                PushVerticalIllustration(sportCode: "strengthTraining", frame: 2, exerciseName: name)
            }
        }
    }
}
#Preview("Push vertical — 2 variantes") {
    VStack(alignment: .leading, spacing: 14) {
        PushVRow(title: "Développé militaire barre", name: "Développé militaire barre")
        PushVRow(title: "Développé haltères", name: "Développé Arnold assis haltères")
    }
    .padding().background(Color.coachingBackground)
}
#endif
