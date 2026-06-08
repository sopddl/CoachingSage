// Views/Components/Illustrations/CoreIllustration.swift
// Story 3.19 — plank statique 1 frame + annotations.
// Variantes :
//   - `.frontal` (default) : plank classique vue de profil, 2 avant-bras au sol,
//     ligne d'alignement épaules-bassin-talons.
//   - `.lateral` : side plank vue de face, 1 SEUL avant-bras au sol côté gauche,
//     corps en diagonale, autre bras tendu vers le haut.
import SwiftUI

struct CoreIllustration: View {
    enum Variant {
        case frontal
        case lateral
    }

    let sportCode: String
    var variant: Variant = .frontal
    /// Revue dessins 2026-06-08 (Sally/Maxime) : les dessins au sol étaient figés à
    /// `staticFrameSize` (≈80×48) → riquiqui/illisibles à côté des triplets debout. On
    /// honore désormais une `size` (comme le POC yoga D4) pour remplir le cadre.
    var size: CGFloat = IllustrationStyle.staticFrameSize.height

    var body: some View {
        Canvas { ctx, size in
            let sx = size.width / IllustrationStyle.staticFrameSize.width
            let sy = size.height / IllustrationStyle.staticFrameSize.height
            let s = min(sx, sy)
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)

            switch variant {
            case .frontal: drawFrontal(ctx: ctx, s: s, stroke: stroke)
            case .lateral: drawLateral(ctx: ctx, s: s, stroke: stroke)
            }
        }
        .frame(width: size * (IllustrationStyle.staticFrameSize.width / IllustrationStyle.staticFrameSize.height),
               height: size)
    }

    // MARK: - Frontal plank

    private func drawFrontal(ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let body = IllustrationStyle.silhouette(sportCode: sportCode)
        // Sol
        var ground = Path()
        ground.move(to: CGPoint(x: 4 * s, y: 42 * s))
        ground.addLine(to: CGPoint(x: 76 * s, y: 42 * s))
        ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                   style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

        // Revue Sophie/Sally/Maxime 2026-06-08 (round 2) : la planche doit être BASSE et
        // HORIZONTALE (gainée), proche du sol → appuis COURTS (pas de « jambe pliée » ni de
        // « rampe »). Corps épaule→bassin→talons à plat (même hauteur), juste au-dessus du sol.
        let bodyY: CGFloat = 32 * s
        let shoulder = CGPoint(x: 52 * s, y: bodyY)
        let heel = CGPoint(x: 16 * s, y: bodyY)

        // Tête (devant l'épaule, regard vers le sol-avant)
        let headSize: CGFloat = 6 * s
        let headC = CGPoint(x: 60 * s, y: bodyY - 1 * s)
        ctx.stroke(Path(ellipseIn: CGRect(x: headC.x - headSize / 2, y: headC.y - headSize / 2,
                                          width: headSize, height: headSize)),
                   with: .color(body), style: stroke)

        // Corps + jambes : épaule → talons, HORIZONTAL (gainé)
        var line = Path()
        line.move(to: CGPoint(x: headC.x - headSize / 2, y: bodyY))
        line.addLine(to: shoulder)
        line.addLine(to: heel)
        ctx.stroke(line, with: .color(body), style: stroke)

        // Avant-bras d'appui COURT sous l'épaule (coude au sol → main vers l'avant)
        var forearm = Path()
        forearm.move(to: shoulder)
        forearm.addLine(to: CGPoint(x: shoulder.x, y: 40 * s))
        forearm.addLine(to: CGPoint(x: shoulder.x + 7 * s, y: 40 * s))
        ctx.stroke(forearm, with: .color(body), style: stroke)

        // Orteils en appui COURT (talon → pointe au sol)
        var toes = Path()
        toes.move(to: heel)
        toes.addLine(to: CGPoint(x: heel.x - 3 * s, y: 40 * s))
        ctx.stroke(toes, with: .color(body), style: stroke)

        // Ligne d'alignement pointillée le long du corps (gainage droit)
        var alignment = Path()
        alignment.move(to: CGPoint(x: shoulder.x + 2 * s, y: bodyY - 4 * s))
        alignment.addLine(to: CGPoint(x: heel.x, y: bodyY - 4 * s))
        ctx.stroke(alignment, with: .color(IllustrationStyle.movementArrow),
                   style: StrokeStyle(lineWidth: 1.2 * s, dash: [3 * s, 2 * s]))
    }

    // MARK: - Side plank (latéral)

    private func drawLateral(ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Sol
        var ground = Path()
        ground.move(to: CGPoint(x: 4 * s, y: 42 * s))
        ground.addLine(to: CGPoint(x: 76 * s, y: 42 * s))
        ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                   style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

        // Revue experte pictos 2026-06-08 : VUE DE FACE (pas profil) — lève l'ambiguïté
        // « debout penché ». Cues clés : avant-bras d'appui À PLAT au sol (≠ pompe verticale),
        // pieds empilés au sol à droite, bras libre VERTICAL isolé vers le ciel.
        let body = IllustrationStyle.silhouette(sportCode: sportCode)
        let shoulder = CGPoint(x: 17 * s, y: 29 * s)
        let hip = CGPoint(x: 48 * s, y: 37 * s)
        let feet = CGPoint(x: 62 * s, y: 42 * s)

        // Corps oblique rigide : épaule → hanche → pieds empilés au sol
        var bodyLine = Path()
        bodyLine.move(to: shoulder)
        bodyLine.addLine(to: hip)
        bodyLine.addLine(to: feet)
        ctx.stroke(bodyLine, with: .color(body), style: stroke)
        // Pieds empilés (petit talon au sol)
        var foot = Path()
        foot.move(to: feet)
        foot.addLine(to: CGPoint(x: feet.x + 4 * s, y: 42 * s))
        ctx.stroke(foot, with: .color(body), style: stroke)

        // Tête (au-dessus, derrière l'épaule haute)
        let headSize: CGFloat = 6 * s
        let headC = CGPoint(x: 11 * s, y: 22 * s)
        ctx.stroke(Path(ellipseIn: CGRect(x: headC.x - headSize / 2, y: headC.y - headSize / 2,
                                          width: headSize, height: headSize)),
                   with: .color(body), style: stroke)
        var neck = Path()
        neck.move(to: shoulder)
        neck.addLine(to: CGPoint(x: headC.x + 1 * s, y: headC.y + 3 * s))
        ctx.stroke(neck, with: .color(body), style: stroke)

        // AVANT-BRAS d'appui À PLAT AU SOL (le cue « je suis sur le côté ») :
        // humérus épaule → coude au sol, puis avant-bras HORIZONTAL le long du sol.
        var supportArm = Path()
        supportArm.move(to: shoulder)
        supportArm.addLine(to: CGPoint(x: 14 * s, y: 42 * s))   // humérus → coude au sol
        supportArm.addLine(to: CGPoint(x: 27 * s, y: 42 * s))   // avant-bras à plat
        ctx.stroke(supportArm, with: .color(body), style: stroke)
        // Main au bout (cercle) — désambigue main vs pied
        let handSize: CGFloat = 3.2 * s
        ctx.stroke(Path(ellipseIn: CGRect(x: 27 * s - handSize / 2, y: 42 * s - handSize / 2,
                                          width: handSize, height: handSize)),
                   with: .color(body), style: stroke)

        // BRAS LIBRE vertical franc vers le ciel (isolé de la tête)
        let armTop = CGPoint(x: 20 * s, y: 7 * s)
        var freeArm = Path()
        freeArm.move(to: shoulder)
        freeArm.addLine(to: armTop)
        ctx.stroke(freeArm, with: .color(body), style: stroke)
        var topHand = Path()
        topHand.move(to: CGPoint(x: armTop.x - 2 * s, y: armTop.y))
        topHand.addLine(to: CGPoint(x: armTop.x + 2 * s, y: armTop.y))
        ctx.stroke(topHand, with: .color(body), style: stroke)
        // Flèche « lève le bras » à droite du bras libre
        var up = Path()
        up.move(to: CGPoint(x: 29 * s, y: 17 * s)); up.addLine(to: CGPoint(x: 29 * s, y: 10 * s))
        up.move(to: CGPoint(x: 29 * s, y: 10 * s)); up.addLine(to: CGPoint(x: 27 * s, y: 13 * s))
        up.move(to: CGPoint(x: 29 * s, y: 10 * s)); up.addLine(to: CGPoint(x: 31 * s, y: 13 * s))
        ctx.stroke(up, with: .color(IllustrationStyle.movementArrow),
                   style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
    }
}

#if DEBUG
#Preview("Core — frontal vs latéral") {
    VStack(spacing: 16) {
        CoreIllustration(sportCode: "strengthTraining", variant: .frontal)
        CoreIllustration(sportCode: "strengthTraining", variant: .lateral)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
