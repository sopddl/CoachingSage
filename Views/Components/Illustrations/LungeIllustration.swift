// Views/Components/Illustrations/LungeIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — fente REFONDUE (profil + variantes).
// Split-stance fixe (pieds avant/arrière posés), la HANCHE descend, genou arrière vers le sol.
// Variantes : poids du corps (mains aux hanches) · haltères (aux côtés).
import SwiftUI

struct LungeIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    enum Variant { case bodyweight, dumbbell }
    var variant: Variant { Self.resolveVariant(from: exerciseName) }

    static func resolveVariant(from name: String?) -> Variant {
        guard let lower = name?.lowercased() else { return .bodyweight }
        if lower.contains("haltère") || lower.contains("haltere") || lower.contains("dumbbell") || lower.contains("barre") {
            return .dumbbell
        }
        return .bodyweight
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)
            let d: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // profondeur de fente

            let frontFoot = p(31, 44)
            let rearFoot  = p(12, 44)
            let hip   = p(22, L(24, 31, d))
            let frontKnee = p(29, L(33, 36, d))
            let rearKnee  = p(16, L(35, 42, d))
            let shldr = p(22, hip.y / s - 11)
            let headC = p(22, shldr.y / s - 5)

            StrengthFigureKit.limb(ctx, [rearFoot, p(15, 44)], color: body, s: s)   // pied arrière
            StrengthFigureKit.limb(ctx, [p(28, 44), frontFoot], color: body, s: s)  // pied avant
            StrengthFigureKit.limb(ctx, [frontFoot, frontKnee, hip], color: body, s: s) // jambe avant
            StrengthFigureKit.limb(ctx, [rearFoot, rearKnee, hip], color: body, s: s)   // jambe arrière
            StrengthFigureKit.limb(ctx, [hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            switch variant {
            case .bodyweight:
                // mains aux hanches
                StrengthFigureKit.limb(ctx, [shldr, p(25, hip.y / s - 1)], color: body, s: s)
            case .dumbbell:
                let hand = CGPoint(x: shldr.x + 3 * s, y: shldr.y + 11 * s)
                StrengthFigureKit.limb(ctx, [shldr, hand], color: body, s: s)
                StrengthFigureKit.dumbbell(ctx, center: hand, s: s)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
private struct LungeRow: View {
    let title: String; let name: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                LungeIllustration(sportCode: "strengthTraining", frame: 0, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                LungeIllustration(sportCode: "strengthTraining", frame: 1, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                LungeIllustration(sportCode: "strengthTraining", frame: 2, exerciseName: name)
            }
        }
    }
}
#Preview("Fente — 2 variantes") {
    VStack(alignment: .leading, spacing: 14) {
        LungeRow(title: "Fente poids du corps", name: "Fente avant")
        LungeRow(title: "Fente haltères", name: "Fente avant haltères")
    }
    .padding().background(Color.coachingBackground)
}
#endif
