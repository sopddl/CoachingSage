// Views/Components/Illustrations/PushHorizontalIllustration.swift
// Chantier refonte dessins muscu (2026-06-07) — push horizontal REFONDU (profil + variantes).
// Geste clé : on pousse la charge à l'horizontale (coudes qui fléchissent puis tendent).
// Variantes : pompe (poids du corps) · développé couché barre · développé haltères · dips.
import SwiftUI

struct PushHorizontalIllustration: View {
    let sportCode: String
    let frame: Int
    var exerciseName: String? = nil

    enum Variant { case pushup, inclinePushup, benchBarbell, benchDumbbell, dips }
    var variant: Variant { Self.resolveVariant(from: exerciseName) }

    static func resolveVariant(from name: String?) -> Variant {
        guard let lower = name?.lowercased() else { return .pushup }
        if lower.contains("dips") { return .dips }
        // Device-test 2026-06-09 : « Pompes inclinées mains sur chaise » tombait sur
        // .pushup (pieds au sol, chaise invisible). On capte la pompe inclinée
        // (mains surélevées) — gaté sur pompe/push pour NE PAS voler « Développé
        // incliné haltères » (qui reste un bench press, capté plus bas).
        if lower.contains("inclin") && (lower.contains("pompe") || lower.contains("push")) {
            return .inclinePushup
        }
        // Revue images muscu 2026-06-08 (bug Sophie) : l'abréviation « DB » (Incline DB
        // bench press) n'était pas détectée → tombait sur la barre. On capte db/incline db.
        if lower.contains("haltère") || lower.contains("haltere") || lower.contains("dumbbell")
            || lower.contains("db bench") || lower.contains("db press") || lower.contains(" db ") {
            return .benchDumbbell
        }
        if lower.contains("couché") || lower.contains("couche") || lower.contains("bench") || lower.contains("développé couché") {
            return .benchBarbell
        }
        return .pushup
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func L(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { StrengthFigureKit.lerp(a, b, t) }

            let pd: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1) // 0 haut/tendu, 1 bas/fléchi

            switch variant {
            case .pushup:
                StrengthFigureKit.ground(ctx, s: s)
                let toe = p(9, 44)
                let hand = p(34, 44)
                let shldr = p(31, L(28, 38, pd))
                let hip = CGPoint(x: toe.x + (shldr.x - toe.x) * 0.55, y: toe.y + (shldr.y - toe.y) * 0.55)
                let headC = CGPoint(x: shldr.x + 4 * s, y: shldr.y - 1 * s)
                StrengthFigureKit.limb(ctx, [toe, hip, shldr], color: body, s: s) // corps gainé
                StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s, r: 2.8)
                let elbow = p(L(33, 36, pd), L(36, 41, pd))
                StrengthFigureKit.limb(ctx, [shldr, elbow, hand], color: body, s: s)

            case .inclinePushup:
                // Pompe inclinée : pieds au sol (bas/arrière), mains posées sur l'ASSISE
                // d'une chaise (haut/avant) → torse relevé, version plus facile.
                StrengthFigureKit.ground(ctx, s: s)
                let seatY: CGFloat = 28
                // Chaise : assise + 2 pieds visibles (sinon « on ne voit pas la chaise »).
                StrengthFigureKit.box(ctx, rect: CGRect(x: 30 * s, y: seatY * s, width: 13 * s, height: 3 * s), s: s, filled: true)
                StrengthFigureKit.limb(ctx, [p(32, seatY + 3), p(32, 44)], color: IllustrationStyle.equipment, s: s)
                StrengthFigureKit.limb(ctx, [p(41, seatY + 3), p(41, 44)], color: IllustrationStyle.equipment, s: s)
                let toe2 = p(8, 44)
                let hand2 = p(35, seatY)                       // mains sur l'assise
                let shldr2 = p(30, L(21, 26, pd))              // épaule descend vers les mains en bas
                let hip2 = CGPoint(x: toe2.x + (shldr2.x - toe2.x) * 0.5, y: toe2.y + (shldr2.y - toe2.y) * 0.5)
                let headC2 = CGPoint(x: shldr2.x + 4 * s, y: shldr2.y - 1 * s)
                StrengthFigureKit.limb(ctx, [toe2, hip2, shldr2], color: body, s: s) // corps gainé incliné
                StrengthFigureKit.headNeck(ctx, head: headC2, shoulder: shldr2, color: body, s: s, r: 2.8)
                let elbow2 = p(L(33, 35, pd), L(24, 27, pd))
                StrengthFigureKit.limb(ctx, [shldr2, elbow2, hand2], color: body, s: s)

            case .benchBarbell, .benchDumbbell:
                StrengthFigureKit.ground(ctx, s: s)
                // Banc
                StrengthFigureKit.box(ctx, rect: CGRect(x: 10 * s, y: 30 * s, width: 26 * s, height: 5 * s), s: s, filled: true)
                let hip = p(16, 28), shldr = p(30, 28), headC = p(35, 28)
                StrengthFigureKit.limb(ctx, [hip, shldr], color: body, s: s)         // dos sur le banc
                StrengthFigureKit.limb(ctx, [hip, p(13, 36), p(15, 44)], color: body, s: s) // jambe au sol
                StrengthFigureKit.headNeck(ctx, head: headC, shoulder: shldr, color: body, s: s, r: 2.8)
                // Press vertical : poitrine (bas) → bras tendus (haut)
                let hand = p(28, L(16, 26, pd))
                let elbow = p(L(30, 33, pd), L(22, 27, pd))
                StrengthFigureKit.limb(ctx, [shldr, elbow, hand], color: body, s: s)
                if variant == .benchBarbell {
                    StrengthFigureKit.barbellSide(ctx, center: hand, halfLen: 7, s: s)
                } else {
                    StrengthFigureKit.dumbbell(ctx, center: hand, s: s)
                }

            case .dips:
                // Barres parallèles (vues de côté : 2 segments aux mains)
                StrengthFigureKit.limb(ctx, [p(14, 22), p(21, 22)], color: IllustrationStyle.equipment, s: s, heavy: true)
                StrengthFigureKit.limb(ctx, [p(27, 22), p(34, 22)], color: IllustrationStyle.equipment, s: s, heavy: true)
                let hand = p(25, 22)
                let shldr = p(24, L(25, 31, pd))
                let hip = p(23, shldr.y / s + 10)
                let knee = p(20, hip.y / s + 6)
                let foot = p(18, knee.y / s - 2)
                let elbow = p(L(27, 30, pd), L(23, 27, pd))
                StrengthFigureKit.limb(ctx, [hand, elbow, shldr], color: body, s: s)   // bras
                StrengthFigureKit.limb(ctx, [shldr, hip, knee, foot], color: body, s: s) // tronc + jambes repliées
                StrengthFigureKit.headNeck(ctx, head: CGPoint(x: 26 * s, y: shldr.y - 5 * s), shoulder: shldr, color: body, s: s, r: 2.8)
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
private struct PushHRow: View {
    let title: String; let name: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                PushHorizontalIllustration(sportCode: "strengthTraining", frame: 0, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                PushHorizontalIllustration(sportCode: "strengthTraining", frame: 1, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                PushHorizontalIllustration(sportCode: "strengthTraining", frame: 2, exerciseName: name)
            }
        }
    }
}
#Preview("Push horizontal — 4 variantes") {
    VStack(alignment: .leading, spacing: 12) {
        PushHRow(title: "Pompe", name: "Pompes complètes")
        PushHRow(title: "Pompe inclinée sur chaise", name: "Pompes inclinées mains sur chaise")
        PushHRow(title: "Développé couché barre", name: "Développé couché barre")
        PushHRow(title: "Développé haltères", name: "Développé incliné haltères")
        PushHRow(title: "Dips", name: "Dips lestés")
    }
    .padding().background(Color.coachingBackground)
}
#endif
