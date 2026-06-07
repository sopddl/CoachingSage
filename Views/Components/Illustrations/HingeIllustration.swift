// Views/Components/Illustrations/HingeIllustration.swift
// Chantier refonte dessins muscu (2026-06-07) — hinge REFONDU (profil + variantes).
// Le mouvement vient de la HANCHE : bassin recule, dos reste plat, charge longe les jambes.
// Variantes par équipement : soulevé de terre barre · RDL barre · RDL haltères.
import SwiftUI

struct HingeIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    enum Variant { case deadlift, barbellRDL, dumbbellRDL }

    var variant: Variant { Self.resolveVariant(from: exerciseName) }

    static func resolveVariant(from name: String?) -> Variant {
        guard let lower = name?.lowercased() else { return .deadlift }
        if lower.contains("haltère") || lower.contains("haltere") || lower.contains("dumbbell") {
            return .dumbbellRDL
        }
        if lower.contains("roumain") || lower.contains("romanian") || lower.contains("rdl") {
            return .barbellRDL
        }
        return .deadlift
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)

            let h: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1)
            // Deadlift = plus de flexion de genou ; RDL = jambes quasi tendues.
            let kneeBottomX: CGFloat = variant == .deadlift ? 25 : 22

            let ankle = p(22, 44)
            let knee  = p(L(22, kneeBottomX, h), L(32, 34, h))
            let hip   = p(L(22, 15, h),         L(21, 27, h))
            let shldr = p(L(22, 29, h),         L(10, 24, h))
            let headC = p(L(22, 34, h),         L(6, 23, h))

            // Pied
            StrengthFigureKit.limb(ctx, [p(17, 44), p(27, 44)], color: body, s: s)
            // Jambe + tronc + tête
            StrengthFigureKit.limb(ctx, [ankle, knee, hip], color: body, s: s)
            StrengthFigureKit.limb(ctx, [hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Bras pendants (gravité) depuis l'épaule
            let hand = CGPoint(x: shldr.x - 1 * s, y: shldr.y + 13 * s)
            StrengthFigureKit.limb(ctx, [shldr, hand], color: body, s: s)

            switch variant {
            case .deadlift, .barbellRDL:
                StrengthFigureKit.barbellEndOn(ctx, center: hand, s: s)
            case .dumbbellRDL:
                StrengthFigureKit.dumbbell(ctx, center: hand, s: s)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
private struct HingeRow: View {
    let title: String; let name: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                HingeIllustration(sportCode: "strengthTraining", frame: 0, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                HingeIllustration(sportCode: "strengthTraining", frame: 1, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                HingeIllustration(sportCode: "strengthTraining", frame: 2, exerciseName: name)
            }
        }
    }
}
#Preview("Hinge — 3 variantes") {
    VStack(alignment: .leading, spacing: 14) {
        HingeRow(title: "Soulevé de terre barre", name: "Soulevé de terre barre")
        HingeRow(title: "RDL barre", name: "Soulevé de terre roumain barre")
        HingeRow(title: "RDL haltères", name: "Soulevé de terre roumain haltères")
    }
    .padding().background(Color.coachingBackground)
}
#endif
