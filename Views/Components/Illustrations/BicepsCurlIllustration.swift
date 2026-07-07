// Views/Components/Illustrations/BicepsCurlIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — biceps curl REFONDU (profil).
// Coude FIXE au corps, l'avant-bras remonte la charge (flexion pure).
// Variantes : haltères (défaut) · barre.
import SwiftUI

struct BicepsCurlIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    enum Variant { case dumbbell, barbell }
    var variant: Variant { Self.resolveVariant(from: exerciseName) }

    static func resolveVariant(from name: String?) -> Variant {
        guard let lower = name?.lowercased() else { return .dumbbell }
        if lower.contains("barre") || lower.contains("barbell") { return .barbell }
        return .dumbbell
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)
            let c: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 bras bas, 1 bras fléchi

            let ankle = p(22, 44), knee = p(22, 33), hip = p(22, 23), shldr = p(22, 13), headC = p(22, 8)
            StrengthFigureKit.limb(ctx, [p(18, 44), p(27, 44)], color: body, s: s)
            StrengthFigureKit.limb(ctx, [ankle, knee, hip, shldr], color: body, s: s)
            StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)

            // Coude fixe contre le corps, l'avant-bras monte (la main décrit un arc vers l'avant-haut)
            let elbow = p(24, 24)
            let hand = p(L(27, 28, c), L(31, 16, c))
            StrengthFigureKit.limb(ctx, [shldr, elbow, hand], color: body, s: s)

            switch variant {
            case .dumbbell:
                StrengthFigureKit.dumbbell(ctx, center: hand, s: s)
            case .barbell:
                StrengthFigureKit.barbellEndOn(ctx, center: hand, s: s, plateR: 2.8, stub: 3)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
private struct BicepsRow: View {
    let title: String; let name: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                BicepsCurlIllustration(sportCode: "strengthTraining", frame: 0, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                BicepsCurlIllustration(sportCode: "strengthTraining", frame: 1, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                BicepsCurlIllustration(sportCode: "strengthTraining", frame: 2, exerciseName: name)
            }
        }
    }
}
#Preview("Biceps curl — 2 variantes") {
    VStack(alignment: .leading, spacing: 14) {
        BicepsRow(title: "Curl haltères", name: "Curl biceps haltères")
        BicepsRow(title: "Curl barre", name: "Curl biceps barre")
    }
    .padding().background(Color.coachingBackground)
}
#endif
