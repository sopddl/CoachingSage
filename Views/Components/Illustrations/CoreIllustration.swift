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

        // Side plank vu de face : corps en diagonale du coin haut-droit
        // (tête) au coin bas-gauche (pieds empilés). UN SEUL avant-bras d'appui
        // côté gauche (sous la tête) descend vers le sol.
        let headX: CGFloat = 60 * s
        let headY: CGFloat = 10 * s
        let hipX: CGFloat = 38 * s
        let hipY: CGFloat = 24 * s
        let feetX: CGFloat = 16 * s
        let feetY: CGFloat = 38 * s

        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(IllustrationStyle.silhouette(sportCode: sportCode)),
            style: stroke
        )

        // Tronc tête → hanche (diagonale haut-droite → milieu)
        var trunk = Path()
        let headBottomX = headX - headSize / 2 * cos(.pi / 4) * 0.5
        let headBottomY = headY + headSize / 2 * sin(.pi / 4) * 0.5 + 1 * s
        trunk.move(to: CGPoint(x: headBottomX, y: headBottomY))
        trunk.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // Jambes hanche → pieds (diagonale milieu → bas-gauche)
        var legs = Path()
        legs.move(to: CGPoint(x: hipX, y: hipY))
        legs.addLine(to: CGPoint(x: feetX, y: feetY))
        ctx.stroke(legs, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // Pieds empilés (petite ligne perpendiculaire au sol)
        var feet = Path()
        feet.move(to: CGPoint(x: feetX, y: feetY))
        feet.addLine(to: CGPoint(x: feetX - 5 * s, y: feetY + 2 * s))
        ctx.stroke(feet, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // SEUL avant-bras d'appui (bras du bas) — part de l'épaule à mi-tronc vers sol
        let shoulderT: CGFloat = 0.18 // 18% du tronc en partant de la tête
        let shoulderX = headBottomX + (hipX - headBottomX) * shoulderT
        let shoulderY = headBottomY + (hipY - headBottomY) * shoulderT
        // Coude descend vers le sol côté gauche
        let elbowX = shoulderX - 6 * s
        let elbowY = 36 * s
        let handX = elbowX + 6 * s
        let handY = 38 * s

        var forearm = Path()
        forearm.move(to: CGPoint(x: shoulderX, y: shoulderY))
        forearm.addLine(to: CGPoint(x: elbowX, y: elbowY))
        forearm.addLine(to: CGPoint(x: handX, y: handY))
        ctx.stroke(forearm, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // Bras LIBRE tendu vers le CIEL (signature side plank). Revue 2026-06-08 (round 2) :
        // Sally « flèche + rotation = bruit » → retirées. Bras simple, long, bien vertical,
        // partant de l'épaule HAUTE (sous la tête) — sans cercle qui ressemble à une rotation.
        let armTop = CGPoint(x: shoulderX + 2 * s, y: 5 * s)
        var freeArm = Path()
        freeArm.move(to: CGPoint(x: shoulderX, y: shoulderY))
        freeArm.addLine(to: armTop)
        ctx.stroke(freeArm, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
        // Main au bout : court trait perpendiculaire (≠ cercle qui lit « rotation »)
        var hand = Path()
        hand.move(to: CGPoint(x: armTop.x - 2 * s, y: armTop.y))
        hand.addLine(to: CGPoint(x: armTop.x + 2 * s, y: armTop.y))
        ctx.stroke(hand, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

        // Ligne d'alignement pointillée tête → pieds (en diagonale)
        var alignment = Path()
        alignment.move(to: CGPoint(x: headX + 2 * s, y: headY - 2 * s))
        alignment.addLine(to: CGPoint(x: feetX - 2 * s, y: feetY + 4 * s))
        ctx.stroke(alignment, with: .color(IllustrationStyle.movementArrow),
                   style: StrokeStyle(lineWidth: 1.2 * s, dash: [3 * s, 2 * s]))
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
