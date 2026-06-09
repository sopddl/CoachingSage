// Views/Components/Illustrations/PullHorizontalIllustration.swift
// Chantier refonte dessins muscu (2026-06-07) — pull horizontal (row) REFONDU (profil + variantes).
// Geste clé : on tire la charge vers le ventre (coude qui recule), buste fixe.
// Variantes : rowing barre buste penché · tirage haltère 1 bras (appui banc) · tirage poulie assis.
import SwiftUI

struct PullHorizontalIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    enum Variant { case bentRow, dumbbellRow, cableRow }
    var variant: Variant { Self.resolveVariant(from: exerciseName) }

    static func resolveVariant(from name: String?) -> Variant {
        guard let lower = name?.lowercased() else { return .bentRow }
        if lower.contains("poulie") || lower.contains("cable") || lower.contains("câble") || lower.contains("assis") {
            return .cableRow
        }
        if lower.contains("haltère") || lower.contains("haltere") || lower.contains("dumbbell")
            || lower.contains("unilatéral") || lower.contains("unilateral") || lower.contains("1 bras") {
            return .dumbbellRow
        }
        return .bentRow
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            StrengthFigureKit.ground(ctx, s: s)
            let ro: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 bras tendu, 1 tiré au ventre

            switch variant {
            case .bentRow:
                // Buste penché fixe ~45°
                let ankle = p(24, 44), knee = p(22, 34), hip = p(17, 28), shldr = p(28, 22), headC = p(33, 21)
                StrengthFigureKit.limb(ctx, [p(19, 44), p(29, 44)], color: body, s: s)
                StrengthFigureKit.limb(ctx, [ankle, knee, hip], color: body, s: s)
                StrengthFigureKit.limb(ctx, [hip, shldr], color: body, s: s)
                StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)
                // bras : épaule → coude → main ; le coude recule en tirant
                let hand = p(L(28, 24, ro), L(40, 30, ro))
                let elbow = p(L(29, 31, ro), L(31, 26, ro))
                StrengthFigureKit.limb(ctx, [shldr, elbow, hand], color: body, s: s)
                StrengthFigureKit.barbellEndOn(ctx, center: hand, s: s)

            case .dumbbellRow:
                // Device-test 2026-06-09 : la tête semblait posée sur le banc et le GENOU
                // d'appui manquait. Position canonique = un GENOU + une MAIN sur le banc,
                // buste horizontal au-dessus, tête dégagée vers l'avant, l'autre bras tire.
                StrengthFigureKit.box(ctx, rect: CGRect(x: 10 * s, y: 31 * s, width: 28 * s, height: 4 * s), s: s, filled: true)
                StrengthFigureKit.limb(ctx, [p(14, 35), p(14, 44)], color: IllustrationStyle.equipment, s: s) // pied banc avant
                StrengthFigureKit.limb(ctx, [p(34, 35), p(34, 44)], color: IllustrationStyle.equipment, s: s) // pied banc arrière
                let hip = p(20, 26), shldr = p(33, 26), headC = p(38, 24)
                let knee = p(17, 31)                              // genou POSÉ sur le banc
                StrengthFigureKit.limb(ctx, [p(12, 31), knee], color: body, s: s)   // tibia sur le banc
                StrengthFigureKit.limb(ctx, [knee, hip], color: body, s: s)         // cuisse (à genoux)
                StrengthFigureKit.limb(ctx, [hip, shldr], color: body, s: s)        // dos plat horizontal
                StrengthFigureKit.limb(ctx, [hip, p(17, 36), p(18, 44)], color: body, s: s) // jambe libre au sol
                StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)
                // bras d'appui (épaule → main sur le banc), atténué
                StrengthFigureKit.limb(ctx, [shldr, p(35, 31)], color: body.opacity(0.55), s: s)
                // bras qui tire l'haltère (épaule → coude → main, le coude monte)
                let hand = p(31, L(38, 28, ro))
                let elbow = p(L(33, 31, ro), L(33, 26, ro))
                StrengthFigureKit.limb(ctx, [shldr, elbow, hand], color: body, s: s)
                StrengthFigureKit.dumbbell(ctx, center: hand, s: s)

            case .cableRow:
                // Assis, buste droit, on tire une poignée câble vers le ventre
                StrengthFigureKit.box(ctx, rect: CGRect(x: 6 * s, y: 34 * s, width: 10 * s, height: 4 * s), s: s, filled: true)
                let hip = p(12, 34), shldr = p(13, 23), headC = p(13, 18)
                let knee = p(26, 34), foot = p(30, 40)
                StrengthFigureKit.limb(ctx, [hip, knee, foot], color: body, s: s)
                StrengthFigureKit.limb(ctx, [hip, shldr], color: body, s: s)
                StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s)
                // poignée + câble : tirée de l'avant (x=38) vers le ventre (x=18)
                let handX = L(38, 18, ro)
                let hand = CGPoint(x: handX * s, y: 28 * s)
                StrengthFigureKit.limb(ctx, [CGPoint(x: 44 * s, y: 28 * s), hand], color: IllustrationStyle.groundLine, s: s) // câble
                let elbowX = L(30, 17, ro)
                StrengthFigureKit.limb(ctx, [shldr, CGPoint(x: elbowX * s, y: 26 * s), hand], color: body, s: s)
                StrengthFigureKit.dumbbell(ctx, center: hand, s: s)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
private struct PullHRow: View {
    let title: String; let name: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                PullHorizontalIllustration(sportCode: "strengthTraining", frame: 0, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                PullHorizontalIllustration(sportCode: "strengthTraining", frame: 1, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                PullHorizontalIllustration(sportCode: "strengthTraining", frame: 2, exerciseName: name)
            }
        }
    }
}
#Preview("Pull horizontal — 3 variantes") {
    VStack(alignment: .leading, spacing: 14) {
        PullHRow(title: "Rowing barre", name: "Rowing barre buste penché")
        PullHRow(title: "Tirage haltère 1 bras", name: "Tirage horizontal haltère unilatéral")
        PullHRow(title: "Tirage poulie assis", name: "Tirage horizontal poulie assis")
    }
    .padding().background(Color.coachingBackground)
}
#endif
