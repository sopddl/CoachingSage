// Views/Components/Illustrations/PlyoIllustration.swift
// Chantier refonte dessins muscu — lot 2 (2026-06-07) — pliométrie REFONDUE (profil + variantes).
// Variantes (mouvements distincts, pas une simple interpolation) :
//   - burpee : sol/planche → groupé → saut bras en l'air (corrige « burpee = petit saut »).
//   - jumpSquat : squat → extension → envol bras en l'air.
//   - boxJump : groupé → envol → réception sur le box.
import SwiftUI

struct PlyoIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    enum Variant { case burpee, jumpSquat, boxJump }
    var variant: Variant { Self.resolveVariant(from: exerciseName) }

    static func resolveVariant(from name: String?) -> Variant {
        guard let lower = name?.lowercased() else { return .jumpSquat }
        if lower.contains("burpee") { return .burpee }
        if lower.contains("box") || lower.contains("boîte") || lower.contains("boite") { return .boxJump }
        return .jumpSquat
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

            StrengthFigureKit.ground(ctx, s: s)

            // Petites marques « air » sous les pieds quand le sujet décolle.
            func airTicks(_ x: CGFloat) {
                for dx in [CGFloat(-3), 0, 3] {
                    StrengthFigureKit.limb(ctx, [p(x + dx, 41), p(x + dx, 43)],
                                           color: IllustrationStyle.movementArrow, s: s)
                }
            }

            switch variant {
            case .burpee:
                switch frame {
                case 0: // planche au sol
                    StrengthFigureKit.limb(ctx, [p(9, 40), p(20, 39), p(30, 38)], color: body, s: s) // corps gainé
                    StrengthFigureKit.limb(ctx, [p(30, 38), p(33, 44)], color: body, s: s) // bras au sol
                    StrengthFigureKit.headNeck(ctx, head: p(34, 36), shoulder: p(30, 38), color: body, s: s, r: 2.6)
                case 1: // groupé (pieds ramenés)
                    StrengthFigureKit.limb(ctx, [p(28, 44), p(26, 36), p(22, 34)], color: body, s: s) // jambe repliée
                    StrengthFigureKit.limb(ctx, [p(22, 34), p(24, 28)], color: body, s: s) // tronc
                    StrengthFigureKit.limb(ctx, [p(24, 28), p(30, 33)], color: body, s: s) // bras vers sol
                    StrengthFigureKit.headNeck(ctx, head: p(25, 24), shoulder: p(24, 28), color: body, s: s, r: 2.6)
                default: // saut bras en l'air
                    airTicks(24)
                    StrengthFigureKit.limb(ctx, [p(24, 40), p(24, 18)], color: body, s: s) // corps tendu
                    StrengthFigureKit.limb(ctx, [p(24, 22), p(20, 8)], color: body, s: s)  // bras levés
                    StrengthFigureKit.limb(ctx, [p(24, 22), p(28, 8)], color: body, s: s)
                    StrengthFigureKit.headNeck(ctx, head: p(24, 13), shoulder: p(24, 18), color: body, s: s, r: 2.8)
                }

            case .jumpSquat:
                switch frame {
                case 0: // squat bas, bras en arrière (armé)
                    StrengthFigureKit.limb(ctx, [p(20, 44), p(26, 37), p(18, 33)], color: body, s: s)
                    StrengthFigureKit.limb(ctx, [p(18, 33), p(23, 25)], color: body, s: s)
                    StrengthFigureKit.limb(ctx, [p(23, 25), p(16, 28)], color: body, s: s) // bras arrière
                    StrengthFigureKit.headNeck(ctx, head: p(26, 22), shoulder: p(23, 25), color: body, s: s, r: 2.8)
                case 1: // extension debout, bras qui montent
                    StrengthFigureKit.limb(ctx, [p(22, 44), p(23, 33), p(24, 22)], color: body, s: s)
                    StrengthFigureKit.limb(ctx, [p(24, 22), p(28, 14)], color: body, s: s)
                    StrengthFigureKit.headNeck(ctx, head: p(24, 17), shoulder: p(24, 22), color: body, s: s)
                default: // envol bras en l'air
                    airTicks(24)
                    StrengthFigureKit.limb(ctx, [p(24, 40), p(24, 18)], color: body, s: s)
                    StrengthFigureKit.limb(ctx, [p(24, 22), p(20, 8)], color: body, s: s)
                    StrengthFigureKit.limb(ctx, [p(24, 22), p(28, 8)], color: body, s: s)
                    StrengthFigureKit.headNeck(ctx, head: p(24, 13), shoulder: p(24, 18), color: body, s: s, r: 2.8)
                }

            case .boxJump:
                // Box à droite
                StrengthFigureKit.box(ctx, rect: CGRect(x: 30 * s, y: 30 * s, width: 14 * s, height: 14 * s), s: s, filled: true)
                switch frame {
                case 0: // groupé avant le box
                    StrengthFigureKit.limb(ctx, [p(12, 44), p(16, 37), p(11, 33)], color: body, s: s)
                    StrengthFigureKit.limb(ctx, [p(11, 33), p(15, 25)], color: body, s: s)
                    StrengthFigureKit.limb(ctx, [p(15, 25), p(9, 27)], color: body, s: s)
                    StrengthFigureKit.headNeck(ctx, head: p(18, 22), shoulder: p(15, 25), color: body, s: s, r: 2.8)
                case 1: // envol vers le box
                    airTicks(20)
                    StrengthFigureKit.limb(ctx, [p(18, 38), p(22, 26)], color: body, s: s)
                    StrengthFigureKit.limb(ctx, [p(22, 26), p(27, 22)], color: body, s: s) // bras avant
                    StrengthFigureKit.headNeck(ctx, head: p(24, 22), shoulder: p(22, 26), color: body, s: s, r: 2.8)
                default: // réception sur le box
                    StrengthFigureKit.limb(ctx, [p(37, 30), p(35, 24), p(38, 20)], color: body, s: s)
                    StrengthFigureKit.headNeck(ctx, head: p(39, 16), shoulder: p(38, 20), color: body, s: s, r: 2.8)
                }
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
private struct PlyoRow: View {
    let title: String; let name: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                PlyoIllustration(sportCode: "strengthTraining", frame: 0, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                PlyoIllustration(sportCode: "strengthTraining", frame: 1, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                PlyoIllustration(sportCode: "strengthTraining", frame: 2, exerciseName: name)
            }
        }
    }
}
#Preview("Plyo — 3 variantes") {
    VStack(alignment: .leading, spacing: 14) {
        PlyoRow(title: "Burpee", name: "Burpee")
        PlyoRow(title: "Jump squat", name: "Jump squat")
        PlyoRow(title: "Box jump", name: "Box jump")
    }
    .padding().background(Color.coachingBackground)
}
#endif
