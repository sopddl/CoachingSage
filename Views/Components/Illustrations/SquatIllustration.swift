// Views/Components/Illustrations/SquatIllustration.swift
// Chantier refonte dessins muscu (2026-06-07) — squat REFONDU.
//
// Pourquoi la refonte (P0 comité Sally/Maxime) :
//   - L'ancien dessin montrait TOUJOURS une barre sur les épaules → « goblet squat »
//     trompeur (goblet = haltère/KB devant la poitrine, pas une barre dans le dos).
//   - Descente quasi invisible (vue de face symétrique, delta de profondeur faible).
//
// Refonte :
//   - Vue de PROFIL : la descente (hanche qui recule + tronc qui s'incline) se lit
//     nettement entre les 3 frames, et la POSITION de la charge distingue la variante.
//   - Variante par équipement (décision produit Sophie 2026-06-07), résolue depuis
//     le nom de l'exo : poids du corps · barre nuque · goblet · fente bulgare.
//   - Défaut neutre (poids du corps) si le nom n'implique aucun équipement → jamais
//     de barre trompeuse sur un squat ambigu.
//
// Coordonnées normalisées 48×48 (ViewBox `IllustrationStyle.frameSize`).
import SwiftUI

struct SquatIllustration: View {
    let sportCode: String
    let frame: Int // 0 debout, 1 mi-course, 2 fond
    var exerciseName: String? = nil

    enum Variant {
        case bodyweight     // squat poids du corps / air squat — bras tendus devant
        case backBarbell    // squat barre nuque — barre/disque sur les trapèzes
        case goblet         // goblet squat — haltère/KB tenu devant la poitrine
        case bulgarianSplit // fente bulgare — pied arrière surélevé, haltères aux côtés
    }

    var variant: Variant { Self.resolveVariant(from: exerciseName) }

    static func resolveVariant(from name: String?) -> Variant {
        guard let lower = name?.lowercased() else { return .bodyweight }
        if lower.contains("goblet") || lower.contains("gobelet") { return .goblet }
        if lower.contains("bulgar") || lower.contains("split squat") || lower.contains("fente bulgare") {
            return .bulgarianSplit
        }
        if lower.contains("nuque") || lower.contains("back squat") || lower.contains("barre") {
            return .backBarbell
        }
        // « Squat », « air squat », « poids du corps », ou nom inconnu → neutre (pas de barre).
        return .bodyweight
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let strokeHeavy = StrokeStyle(lineWidth: IllustrationStyle.strokeWidthHeavy * s, lineCap: .round)
            let body = IllustrationStyle.silhouette(sportCode: sportCode)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
            func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }

            // Sol pointillé
            var ground = Path()
            ground.move(to: p(4, 44)); ground.addLine(to: p(44, 44))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Profondeur du squat par frame
            let d: CGFloat = frame == 0 ? 0 : (frame == 1 ? 0.5 : 1)

            // Articulations (profil, face à droite) interpolées debout → fond.
            // Debout : aligné vertical. Fond : hanche en arrière + bas, genou en avant,
            // tronc penché en avant au-dessus des genoux (assis-recule lisible).
            let ankle = p(20, 44)
            let knee  = p(lerp(20.5, 26, d), lerp(33, 36, d))
            let hip   = p(lerp(21, 18, d),   lerp(22, 33, d))
            let shldr = p(lerp(21.5, 22, d), lerp(11, 22.5, d))
            let headC = p(lerp(22, 23, d),   lerp(7, 18, d))
            let headR: CGFloat = 3 * s

            // Pied (talon ancré + pointe vers l'avant)
            var foot = Path()
            foot.move(to: p(16, 44)); foot.addLine(to: p(27, 44))
            ctx.stroke(foot, with: .color(body), style: stroke)

            // Jambe (cheville → genou → hanche)
            var leg = Path()
            leg.move(to: ankle); leg.addLine(to: knee); leg.addLine(to: hip)
            ctx.stroke(leg, with: .color(body), style: stroke)

            // Tronc (hanche → épaule)
            var trunk = Path()
            trunk.move(to: hip); trunk.addLine(to: shldr)
            ctx.stroke(trunk, with: .color(body), style: stroke)

            // Cou + tête
            var neck = Path()
            neck.move(to: shldr); neck.addLine(to: CGPoint(x: headC.x, y: headC.y + headR))
            ctx.stroke(neck, with: .color(body), style: stroke)
            ctx.stroke(Path(ellipseIn: CGRect(x: headC.x - headR, y: headC.y - headR,
                                              width: headR * 2, height: headR * 2)),
                       with: .color(body), style: stroke)

            // Direction du tronc (épaule → hanche) et sa normale « avant » (vers la droite)
            let tdx = hip.x - shldr.x, tdy = hip.y - shldr.y
            let tlen = max(0.001, hypot(tdx, tdy))
            let fwd = CGPoint(x: tdy / tlen, y: -tdx / tlen) // normale antérieure (vers l'avant, +x)

            switch variant {
            case .bodyweight:
                // Bras tendus devant (contrepoids air squat)
                var arm = Path()
                arm.move(to: shldr)
                arm.addLine(to: CGPoint(x: shldr.x + 10 * s, y: shldr.y + 1 * s))
                ctx.stroke(arm, with: .color(body), style: stroke)

            case .backBarbell:
                // Barre sur les trapèzes (vue de profil = disque en bout + stub de barre).
                let barC = CGPoint(x: shldr.x - 1.5 * s, y: shldr.y - 1 * s)
                var barStub = Path()
                barStub.move(to: CGPoint(x: barC.x - 4 * s, y: barC.y))
                barStub.addLine(to: CGPoint(x: barC.x + 4 * s, y: barC.y))
                ctx.stroke(barStub, with: .color(IllustrationStyle.equipment), style: strokeHeavy)
                // Disque vu en bout (cercle plein)
                let plateR: CGFloat = 3.2 * s
                ctx.fill(Path(ellipseIn: CGRect(x: barC.x - plateR, y: barC.y - plateR,
                                                width: plateR * 2, height: plateR * 2)),
                         with: .color(IllustrationStyle.load))
                // Bras qui agrippe la barre (épaule → main levée vers la barre)
                var arm = Path()
                arm.move(to: shldr)
                arm.addLine(to: CGPoint(x: barC.x + 2 * s, y: barC.y + 1.5 * s))
                ctx.stroke(arm, with: .color(body), style: stroke)

            case .goblet:
                // Haltère/KB tenu devant la poitrine, à deux mains.
                let chest = CGPoint(x: shldr.x + (hip.x - shldr.x) * 0.28,
                                    y: shldr.y + (hip.y - shldr.y) * 0.28)
                let wC = CGPoint(x: chest.x + fwd.x * 5 * s, y: chest.y + fwd.y * 5 * s)
                // Kettlebell : corps arrondi + anse
                let kbR: CGFloat = 3 * s
                ctx.fill(Path(ellipseIn: CGRect(x: wC.x - kbR, y: wC.y - kbR + 0.8 * s,
                                                width: kbR * 2, height: kbR * 2)),
                         with: .color(IllustrationStyle.load))
                var handle = Path()
                handle.addArc(center: CGPoint(x: wC.x, y: wC.y - 1 * s), radius: 1.8 * s,
                              startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
                ctx.stroke(handle, with: .color(IllustrationStyle.equipment), style: stroke)
                // Bras (épaule → poids), coudes rentrés
                var arm = Path()
                arm.move(to: shldr)
                arm.addLine(to: CGPoint(x: wC.x - 1 * s, y: wC.y - 1 * s))
                ctx.stroke(arm, with: .color(body), style: stroke)

            case .bulgarianSplit:
                // Banc/box derrière + pied arrière surélevé
                let boxTop = p(9, 36)
                var box = Path()
                box.addRect(CGRect(x: 4 * s, y: 36 * s, width: 8 * s, height: 8 * s))
                ctx.stroke(box, with: .color(IllustrationStyle.equipment), style: stroke)
                // Jambe arrière : hanche → genou arrière → pied sur le box
                var rearLeg = Path()
                rearLeg.move(to: hip)
                rearLeg.addLine(to: CGPoint(x: hip.x - 5 * s, y: hip.y + 4 * s))
                rearLeg.addLine(to: CGPoint(x: boxTop.x + 1 * s, y: boxTop.y))
                ctx.stroke(rearLeg, with: .color(body.opacity(0.55)), style: stroke)
                // Bras pendants + haltères aux mains
                let handY = shldr.y + 11 * s
                for sign in [CGFloat(-0.6), 0.6] {
                    let handX = shldr.x + sign * 1.5 * s
                    var arm = Path()
                    arm.move(to: shldr); arm.addLine(to: CGPoint(x: handX, y: handY))
                    ctx.stroke(arm, with: .color(body), style: stroke)
                    let dw: CGFloat = 4 * s, dh: CGFloat = 2.4 * s
                    ctx.fill(Path(roundedRect: CGRect(x: handX - dw / 2, y: handY - dh / 2,
                                                      width: dw, height: dh), cornerRadius: 0.6 * s),
                             with: .color(IllustrationStyle.load))
                }
            }
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }
}

#if DEBUG
private struct SquatVariantRow: View {
    let title: String
    let name: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 4) {
                SquatIllustration(sportCode: "strengthTraining", frame: 0, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                SquatIllustration(sportCode: "strengthTraining", frame: 1, exerciseName: name)
                Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
                SquatIllustration(sportCode: "strengthTraining", frame: 2, exerciseName: name)
            }
        }
    }
}

#Preview("Squat — 4 variantes") {
    VStack(alignment: .leading, spacing: 14) {
        SquatVariantRow(title: "Poids du corps", name: "Squat au poids du corps")
        SquatVariantRow(title: "Barre nuque", name: "Squat barre nuque")
        SquatVariantRow(title: "Goblet", name: "Squat gobelet")
        SquatVariantRow(title: "Fente bulgare", name: "Fente bulgare haltères")
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
