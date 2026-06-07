// Views/Components/Illustrations/HipThrustIllustration.swift
// Chantier refonte dessins muscu (2026-06-07) — hip thrust REFONDU (profil + variantes).
// Geste clé : les hanches montent (extension de hanche), épaules/pieds fixes.
// Variantes : pont fessier au sol (poids du corps) · hip thrust dos sur banc + barre.
import SwiftUI

struct HipThrustIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    enum Variant { case gluteBridge, barbellThrust }
    var variant: Variant { Self.resolveVariant(from: exerciseName) }

    static func resolveVariant(from name: String?) -> Variant {
        guard let lower = name?.lowercased() else { return .gluteBridge }
        if lower.contains("hip thrust") || lower.contains("lesté") || lower.contains("leste")
            || lower.contains("banc") || lower.contains("barre") || lower.contains("haltère") || lower.contains("haltere") {
            return .barbellThrust
        }
        return .gluteBridge
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)
            let l: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // élévation hanche

            switch variant {
            case .gluteBridge:
                let shldr = p(12, 42)
                let headC = p(7, 41)
                let hip   = p(22, L(43, 31, l))
                let knee  = p(31, 38)
                let ankle = p(31, 44)
                StrengthFigureKit.limb(ctx, [p(28, 44), p(35, 44)], color: body, s: s) // pied à plat
                StrengthFigureKit.limb(ctx, [shldr, hip, knee, ankle], color: body, s: s)
                StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s, r: 2.8)

            case .barbellThrust:
                // Banc (appui haut du dos)
                StrengthFigureKit.box(ctx, rect: CGRect(x: 5 * s, y: 32 * s, width: 12 * s, height: 12 * s), s: s, filled: true)
                let shldr = p(15, 32)
                let headC = p(11, 29)
                let hip   = p(25, L(40, 30, l))
                let knee  = p(34, 38)
                let ankle = p(34, 44)
                StrengthFigureKit.limb(ctx, [p(31, 44), p(38, 44)], color: body, s: s) // pied à plat
                StrengthFigureKit.limb(ctx, [shldr, hip, knee, ankle], color: body, s: s)
                StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s, r: 2.8)
                // barre sur les hanches (disque vu en bout)
                StrengthFigureKit.barbellEndOn(ctx, center: CGPoint(x: hip.x, y: hip.y - 3 * s), s: s)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
private struct HipThrustRow: View {
    let title: String; let name: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                HipThrustIllustration(sportCode: "strengthTraining", frame: 0, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                HipThrustIllustration(sportCode: "strengthTraining", frame: 1, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                HipThrustIllustration(sportCode: "strengthTraining", frame: 2, exerciseName: name)
            }
        }
    }
}
#Preview("Hip thrust — 2 variantes") {
    VStack(alignment: .leading, spacing: 14) {
        HipThrustRow(title: "Pont fessier au sol", name: "Pont fessier au sol au poids du corps")
        HipThrustRow(title: "Hip thrust barre", name: "Pont fessier lesté barre")
    }
    .padding().background(Color.coachingBackground)
}
#endif
