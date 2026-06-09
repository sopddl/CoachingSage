// Views/Components/Illustrations/CalfRaiseIllustration.swift
// Chantier refonte dessins muscu (2026-06-07) — calf raise REFONDU (profil + variantes).
// Geste clé : le talon se lève, on monte sur la pointe (le corps s'élève).
// Variantes : mollets debout · mollets assis (soléaire, genou fléchi + charge sur la cuisse).
import SwiftUI

struct CalfRaiseIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    enum Variant { case standing, seated }
    var variant: Variant { Self.resolveVariant(from: exerciseName) }

    static func resolveVariant(from name: String?) -> Variant {
        guard let lower = name?.lowercased() else { return .standing }
        if lower.contains("assis") || lower.contains("seated") || lower.contains("soléaire") || lower.contains("soleaire") {
            return .seated
        }
        return .standing
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)
            let r: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // élévation talon

            switch variant {
            case .standing:
                let up = 5 * r * s // le corps monte
                let ball = p(28, 44)
                let heel = p(19, L(44, 38, r))
                let ankle = CGPoint(x: 24 * s, y: 40 * s - up)
                let knee  = CGPoint(x: 24 * s, y: 29 * s - up)
                let hip   = CGPoint(x: 24 * s, y: 19 * s - up)
                let shldr = CGPoint(x: 24 * s, y: 9 * s - up)
                let headC = CGPoint(x: 24 * s, y: 5 * s - up)
                StrengthFigureKit.limb(ctx, [heel, ball], color: body, s: s)        // pied
                StrengthFigureKit.limb(ctx, [ankle, ball], color: body, s: s)       // cheville→pointe
                StrengthFigureKit.limb(ctx, [ankle, knee, hip, shldr], color: body, s: s)
                StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)
                // bras le long du corps
                StrengthFigureKit.limb(ctx, [shldr, CGPoint(x: shldr.x + 4 * s, y: shldr.y + 11 * s)], color: body, s: s)

            case .seated:
                // Banc
                StrengthFigureKit.box(ctx, rect: CGRect(x: 6 * s, y: 30 * s, width: 11 * s, height: 14 * s), s: s, filled: true)
                let hip   = p(13, 30)
                let knee  = p(30, 30)
                let ankle = p(30, 40)
                let ball  = p(34, 44)
                let heel  = p(26, L(44, 39, r))
                let shldr = p(13, 20)
                let headC = p(13, 15)
                StrengthFigureKit.limb(ctx, [hip, knee, ankle], color: body, s: s)  // cuisse + tibia
                StrengthFigureKit.limb(ctx, [heel, ball], color: body, s: s)
                StrengthFigureKit.limb(ctx, [ankle, ball], color: body, s: s)
                StrengthFigureKit.limb(ctx, [hip, shldr], color: body, s: s)
                StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)
                // charge posée sur la cuisse (près du genou)
                StrengthFigureKit.barbellEndOn(ctx, center: p(26, 27), s: s, plateR: 2.8, stub: 3)
                // mains qui tiennent la charge
                StrengthFigureKit.limb(ctx, [shldr, p(26, 25)], color: body, s: s)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
private struct CalfRow: View {
    let title: String; let name: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                CalfRaiseIllustration(sportCode: "strengthTraining", frame: 0, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                CalfRaiseIllustration(sportCode: "strengthTraining", frame: 1, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                CalfRaiseIllustration(sportCode: "strengthTraining", frame: 2, exerciseName: name)
            }
        }
    }
}
#Preview("Calf — 2 variantes") {
    VStack(alignment: .leading, spacing: 14) {
        CalfRow(title: "Mollets debout", name: "Mollets debout")
        CalfRow(title: "Mollets assis", name: "Mollets assis")
    }
    .padding().background(Color.coachingBackground)
}
#endif
