// Views/Components/Illustrations/PullVerticalIllustration.swift
// Chantier refonte dessins muscu (2026-06-07) — pull vertical REFONDU (profil + variantes).
// Variantes par équipement :
//   - Traction (barre fixe) : le CORPS monte vers une barre fixe (menton au-dessus).
//   - Tirage poulie haute (lat pulldown) : assis, la BARRE descend du haut vers la poitrine.
import SwiftUI

struct PullVerticalIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    enum Variant { case pullup, pulldown }
    var variant: Variant { Self.resolveVariant(from: exerciseName) }

    static func resolveVariant(from name: String?) -> Variant {
        guard let lower = name?.lowercased() else { return .pullup }
        if lower.contains("poulie") || lower.contains("pulldown") || lower.contains("tirage vertical") {
            return .pulldown
        }
        return .pullup
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            let pull: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1)

            switch variant {
            case .pullup:
                // Barre fixe horizontale en haut (sans disque)
                StrengthFigureKit.limb(ctx, [p(12, 7), p(36, 7)], color: IllustrationStyle.equipment, s: s, heavy: true)
                let hand = p(24, 7)
                // Le corps monte : épaule de y=21 (suspendu) à y=13 (menton à la barre)
                let shldr = p(24, L(21, 13, pull))
                let elbow = p(L(24, 29, pull), L(13, 11, pull))
                let hip   = p(23, shldr.y / s + 11)
                let knee  = p(20, hip.y / s + 8)
                let foot  = p(22, knee.y / s + 5)
                StrengthFigureKit.limb(ctx, [hand, elbow, shldr], color: body, s: s) // bras
                StrengthFigureKit.limb(ctx, [shldr, hip, knee, foot], color: body, s: s) // tronc + jambe repliée
                StrengthFigureKit.headNeck(ctx, head: p(27, L(15, 9, pull)), shoulder: shldr, color: body, s: s, r: 2.8)

            case .pulldown:
                // Câble depuis le haut
                let barY = L(12, 21, pull) // la barre descend vers la poitrine
                StrengthFigureKit.limb(ctx, [p(24, 3), p(24, barY)], color: IllustrationStyle.groundLine, s: s) // câble
                StrengthFigureKit.barbellSide(ctx, center: p(24, barY), halfLen: 8, s: s)
                // Coussin / assise
                StrengthFigureKit.box(ctx, rect: CGRect(x: 14 * s, y: 32 * s, width: 12 * s, height: 4 * s), s: s, filled: true)
                let hip = p(20, 32), shldr = p(22, 23), headC = p(23, 18)
                let knee = p(30, 34), foot = p(30, 42)
                StrengthFigureKit.limb(ctx, [hip, shldr], color: body, s: s)
                StrengthFigureKit.limb(ctx, [hip, knee, foot], color: body, s: s)
                StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)
                // bras : épaule → barre
                StrengthFigureKit.limb(ctx, [shldr, p(24, barY)], color: body, s: s)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
private struct PullVRow: View {
    let title: String; let name: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                PullVerticalIllustration(sportCode: "strengthTraining", frame: 0, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                PullVerticalIllustration(sportCode: "strengthTraining", frame: 1, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                PullVerticalIllustration(sportCode: "strengthTraining", frame: 2, exerciseName: name)
            }
        }
    }
}
#Preview("Pull vertical — 2 variantes") {
    VStack(alignment: .leading, spacing: 14) {
        PullVRow(title: "Traction barre fixe", name: "Traction au poids du corps")
        PullVRow(title: "Tirage poulie haute", name: "Tirage vertical poulie haute")
    }
    .padding().background(Color.coachingBackground)
}
#endif
