// Views/Components/Illustrations/YogaIllustration.swift
// Story 3.19 Jalon 2c — 10 poses yoga V1 (Sophie 2026-05-23).
// Pattern ombrelle `.yoga` → dispatch interne keyword `exerciseName` vers la
// sub-pose. Toutes statiques 1 frame + annotations alignement orange.
//
// Poses V1 :
//   - Chien tête en bas (Adho Mukha Svanasana)
//   - Guerrier I, II (Virabhadrasana I, II)
//   - Arbre (Vrksasana)
//   - Cobra (Bhujangasana)
//   - Enfant (Balasana)
//   - Pince debout (Uttanasana)
//   - Triangle (Trikonasana)
//   - Bateau (Navasana)
//   - Savasana (cadavre)
//
// Silhouette violet yoga (`Color.coachingSport(forCode: "yoga")` = `#9B6BB3`).
import SwiftUI

struct YogaIllustration: View {
    let sportCode: String
    var exerciseName: String? = nil

    var body: some View {
        Canvas { ctx, size in
            let sx = size.width / IllustrationStyle.staticFrameSize.width
            let sy = size.height / IllustrationStyle.staticFrameSize.height
            let s = min(sx, sy)
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)

            // Sol pointillé fixe (référentiel ancrage)
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 76 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            switch poseKind {
            case .downwardDog: drawDownwardDog(ctx, s: s, stroke: stroke)
            case .warrior1:    drawWarrior1(ctx, s: s, stroke: stroke)
            case .warrior2:    drawWarrior2(ctx, s: s, stroke: stroke)
            case .tree:        drawTree(ctx, s: s, stroke: stroke)
            case .cobra:       drawCobra(ctx, s: s, stroke: stroke)
            case .child:       drawChild(ctx, s: s, stroke: stroke)
            case .forwardFold: drawForwardFold(ctx, s: s, stroke: stroke)
            case .triangle:    drawTriangle(ctx, s: s, stroke: stroke)
            case .boat:        drawBoat(ctx, s: s, stroke: stroke)
            case .savasana:    drawSavasana(ctx, s: s, stroke: stroke)
            case .unknown:     drawWarrior1(ctx, s: s, stroke: stroke) // fallback safe
            }
        }
        .frame(width: IllustrationStyle.staticFrameSize.width,
               height: IllustrationStyle.staticFrameSize.height)
    }

    // MARK: - Pose detection

    private enum YogaPose {
        case downwardDog, warrior1, warrior2, tree, cobra
        case child, forwardFold, triangle, boat, savasana
        case unknown
    }

    private var poseKind: YogaPose {
        guard let lower = exerciseName?.lowercased() else { return .unknown }
        if lower.contains("chien") || lower.contains("downward") || lower.contains("adho") { return .downwardDog }
        if lower.contains("guerrier 2") || lower.contains("guerrier ii") || lower.contains("warrior 2") || lower.contains("warrior ii") || lower.contains("virabhadrasana ii") { return .warrior2 }
        if lower.contains("guerrier") || lower.contains("warrior") || lower.contains("virabhadrasana") { return .warrior1 }
        if lower.contains("arbre") || lower.contains("tree") || lower.contains("vrksasana") { return .tree }
        if lower.contains("cobra") || lower.contains("bhujangasana") { return .cobra }
        if lower.contains("enfant") || lower.contains("child") || lower.contains("balasana") { return .child }
        if lower.contains("pince") || lower.contains("forward fold") || lower.contains("uttanasana") { return .forwardFold }
        if lower.contains("triangle") || lower.contains("trikonasana") { return .triangle }
        if lower.contains("bateau") || lower.contains("boat") || lower.contains("navasana") { return .boat }
        if lower.contains("savasana") || lower.contains("cadavre") || lower.contains("relaxation") { return .savasana }
        return .unknown
    }

    private var silhouette: Color { IllustrationStyle.silhouette(sportCode: sportCode) }
    private var annotation: Color { IllustrationStyle.movementArrow }

    // MARK: - Poses (toutes en coordonnées 80×48)

    /// Chien tête en bas — corps en V inversé. Mains côté droit (28-32), pieds côté gauche (48-52), fesses pointées vers le haut.
    private func drawDownwardDog(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let handX: CGFloat = 18 * s
        let handY: CGFloat = 46 * s
        let footX: CGFloat = 62 * s
        let footY: CGFloat = 46 * s
        let hipX: CGFloat = 40 * s
        let hipY: CGFloat = 10 * s // hauteur du sommet du V

        // Bras (poignet au sol → épaule)
        let shoulderX: CGFloat = 26 * s
        let shoulderY: CGFloat = 22 * s
        var arm = Path()
        arm.move(to: CGPoint(x: handX, y: handY))
        arm.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Tête (entre les bras, légèrement projetée vers le sol)
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX - 2 * s - headSize / 2, y: shoulderY + 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc épaule → hanche (au sommet du V)
        var trunk = Path()
        trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambes hanche → pied
        var leg = Path()
        leg.move(to: CGPoint(x: hipX, y: hipY))
        leg.addLine(to: CGPoint(x: footX, y: footY))
        ctx.stroke(leg, with: .color(silhouette), style: stroke)

        // Annotation : ligne pointillée bras alignement (poignet → hanche)
        var alignment = Path()
        alignment.move(to: CGPoint(x: handX - 1 * s, y: handY - 2 * s))
        alignment.addLine(to: CGPoint(x: hipX + 1 * s, y: hipY - 3 * s))
        ctx.stroke(alignment, with: .color(annotation),
                   style: StrokeStyle(lineWidth: 1.2 * s, dash: [3 * s, 2 * s]))
    }

    /// Guerrier I — debout face caméra, fente, bras tendus vers le haut mains au ciel.
    private func drawWarrior1(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let centerX: CGFloat = 40 * s
        let headSize: CGFloat = 6 * s
        let topOfHeadY: CGFloat = 4 * s
        let shoulderY: CGFloat = topOfHeadY + headSize
        let hipY: CGFloat = 24 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: topOfHeadY,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc droit vertical
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: centerX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambe avant fléchie (pied avant sous la hanche)
        var frontLeg = Path()
        frontLeg.move(to: CGPoint(x: centerX, y: hipY))
        frontLeg.addLine(to: CGPoint(x: centerX + 8 * s, y: 34 * s))
        frontLeg.addLine(to: CGPoint(x: centerX + 10 * s, y: 46 * s))
        ctx.stroke(frontLeg, with: .color(silhouette), style: stroke)

        // Jambe arrière tendue (pied loin derrière)
        var backLeg = Path()
        backLeg.move(to: CGPoint(x: centerX, y: hipY))
        backLeg.addLine(to: CGPoint(x: centerX - 14 * s, y: 46 * s))
        ctx.stroke(backLeg, with: .color(silhouette), style: stroke)

        // Bras tendus vers le HAUT (signature guerrier I)
        var armL = Path()
        armL.move(to: CGPoint(x: centerX - 2 * s, y: shoulderY))
        armL.addLine(to: CGPoint(x: centerX - 4 * s, y: 0))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 2 * s, y: shoulderY))
        armR.addLine(to: CGPoint(x: centerX + 4 * s, y: 0))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Mains jointes au sommet (petit point)
        let handSize: CGFloat = 2 * s
        ctx.fill(
            Path(ellipseIn: CGRect(x: centerX - handSize / 2, y: 0, width: handSize, height: handSize)),
            with: .color(silhouette)
        )
    }

    /// Guerrier II — pose de face, fente, bras HORIZONTAUX écartés.
    private func drawWarrior2(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let centerX: CGFloat = 40 * s
        let headSize: CGFloat = 6 * s
        let topOfHeadY: CGFloat = 10 * s
        let shoulderY: CGFloat = topOfHeadY + headSize
        let hipY: CGFloat = 28 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: topOfHeadY,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc droit
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: centerX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Bras HORIZONTAUX écartés (signature guerrier II)
        var arms = Path()
        arms.move(to: CGPoint(x: 18 * s, y: shoulderY + 1 * s))
        arms.addLine(to: CGPoint(x: 62 * s, y: shoulderY + 1 * s))
        ctx.stroke(arms, with: .color(silhouette), style: stroke)

        // Jambe avant fléchie (genou avant)
        var frontLeg = Path()
        frontLeg.move(to: CGPoint(x: centerX, y: hipY))
        frontLeg.addLine(to: CGPoint(x: centerX + 10 * s, y: 36 * s))
        frontLeg.addLine(to: CGPoint(x: centerX + 12 * s, y: 46 * s))
        ctx.stroke(frontLeg, with: .color(silhouette), style: stroke)

        // Jambe arrière tendue
        var backLeg = Path()
        backLeg.move(to: CGPoint(x: centerX, y: hipY))
        backLeg.addLine(to: CGPoint(x: centerX - 14 * s, y: 46 * s))
        ctx.stroke(backLeg, with: .color(silhouette), style: stroke)
    }

    /// Arbre — debout équilibre sur un pied, autre pied au genou, mains jointes au ciel.
    private func drawTree(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let centerX: CGFloat = 40 * s
        let headSize: CGFloat = 6 * s
        let topOfHeadY: CGFloat = 4 * s
        let shoulderY: CGFloat = topOfHeadY + headSize
        let hipY: CGFloat = 26 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: topOfHeadY,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc droit
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: centerX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambe d'appui (verticale droite)
        var standLeg = Path()
        standLeg.move(to: CGPoint(x: centerX, y: hipY))
        standLeg.addLine(to: CGPoint(x: centerX - 1 * s, y: 46 * s))
        ctx.stroke(standLeg, with: .color(silhouette), style: stroke)

        // Jambe pliée (pied au genou de l'autre jambe — signature arbre)
        // Genou de la jambe pliée pointé sur le côté, pied collé au mollet
        var foldedLeg = Path()
        foldedLeg.move(to: CGPoint(x: centerX, y: hipY))
        foldedLeg.addLine(to: CGPoint(x: centerX + 8 * s, y: 32 * s))  // genou écarté à droite
        foldedLeg.addLine(to: CGPoint(x: centerX + 1 * s, y: 38 * s))  // pied collé à la jambe d'appui
        ctx.stroke(foldedLeg, with: .color(silhouette), style: stroke)

        // Bras tendus vers le ciel, mains jointes (en prière au-dessus de la tête)
        var armL = Path()
        armL.move(to: CGPoint(x: centerX - 2 * s, y: shoulderY))
        armL.addLine(to: CGPoint(x: centerX - 1 * s, y: 0))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 2 * s, y: shoulderY))
        armR.addLine(to: CGPoint(x: centerX + 1 * s, y: 0))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// Cobra — allongé ventre au sol, buste relevé bras tendus, tête haute.
    private func drawCobra(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue de profil. Pieds + jambes au sol (côté gauche), buste relevé (côté droit).
        let footX: CGFloat = 14 * s
        let footY: CGFloat = 44 * s
        let hipX: CGFloat = 36 * s
        let hipY: CGFloat = 44 * s
        let shoulderX: CGFloat = 56 * s
        let shoulderY: CGFloat = 30 * s
        let handX: CGFloat = 60 * s
        let handY: CGFloat = 46 * s

        // Jambes/bassin couché au sol
        var legs = Path()
        legs.move(to: CGPoint(x: footX, y: footY))
        legs.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Tronc qui se relève en arc (de la hanche vers l'épaule en montant)
        var trunk = Path()
        trunk.move(to: CGPoint(x: hipX, y: hipY))
        trunk.addQuadCurve(to: CGPoint(x: shoulderX, y: shoulderY),
                           control: CGPoint(x: 50 * s, y: 30 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête (en haut du buste relevé, regard vers le haut-avant)
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX + 2 * s - headSize / 2, y: shoulderY - headSize - 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus (épaule → main au sol)
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX, y: shoulderY))
        arm.addLine(to: CGPoint(x: handX, y: handY))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// Enfant — à genoux fesses sur talons, front au sol, bras tendus devant.
    private func drawChild(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil. Fesses + cuisses + tibias compactés au sol (côté droit), bras + tête côté gauche.
        let kneeX: CGFloat = 50 * s
        let kneeY: CGFloat = 44 * s
        let buttX: CGFloat = 56 * s
        let buttY: CGFloat = 42 * s
        let foreheadX: CGFloat = 22 * s
        let foreheadY: CGFloat = 44 * s
        let handX: CGFloat = 14 * s
        let handY: CGFloat = 46 * s

        // Tibias (genou → fesse au sol)
        var shins = Path()
        shins.move(to: CGPoint(x: kneeX, y: kneeY))
        shins.addLine(to: CGPoint(x: 60 * s, y: 46 * s))
        ctx.stroke(shins, with: .color(silhouette), style: stroke)

        // Cuisses (genou → fesse)
        var thighs = Path()
        thighs.move(to: CGPoint(x: kneeX, y: kneeY))
        thighs.addLine(to: CGPoint(x: buttX, y: buttY))
        ctx.stroke(thighs, with: .color(silhouette), style: stroke)

        // Tronc replié (fesse → front au sol — long et bas)
        var trunk = Path()
        trunk.move(to: CGPoint(x: buttX, y: buttY))
        trunk.addLine(to: CGPoint(x: foreheadX, y: foreheadY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au sol (cercle au bout du tronc)
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: foreheadX - headSize, y: foreheadY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus devant (épaule au tronc → main au sol côté gauche)
        var arm = Path()
        arm.move(to: CGPoint(x: foreheadX + 2 * s, y: foreheadY - 1 * s))
        arm.addLine(to: CGPoint(x: handX, y: handY))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// Pince debout — debout, buste plié vers les pieds, mains au sol.
    private func drawForwardFold(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let centerX: CGFloat = 40 * s
        let footX: CGFloat = centerX
        let footY: CGFloat = 46 * s
        let hipY: CGFloat = 22 * s

        // Jambes droites debout
        var legL = Path()
        legL.move(to: CGPoint(x: centerX, y: hipY))
        legL.addLine(to: CGPoint(x: footX - 2 * s, y: footY))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)

        var legR = Path()
        legR.move(to: CGPoint(x: centerX, y: hipY))
        legR.addLine(to: CGPoint(x: footX + 2 * s, y: footY))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Tronc PLIÉ vers les pieds (depuis la hanche, buste descend)
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: hipY))
        trunk.addLine(to: CGPoint(x: centerX - 2 * s, y: 38 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête (en bas, près des pieds, vue tête vers le sol)
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - 2 * s - headSize / 2, y: 38 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras pendants vers le sol (mains qui touchent les pieds)
        var arm = Path()
        arm.move(to: CGPoint(x: centerX - 3 * s, y: 40 * s))
        arm.addLine(to: CGPoint(x: centerX - 4 * s, y: 46 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// Triangle — jambes très écartées, buste lateral, main basse au sol, main haute au ciel.
    private func drawTriangle(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue de face. Jambes très écartées (V à l'envers).
        let centerX: CGFloat = 40 * s
        let footLX: CGFloat = 18 * s
        let footRX: CGFloat = 62 * s
        let hipX: CGFloat = centerX
        let hipY: CGFloat = 30 * s

        // Jambes écartées
        var legL = Path()
        legL.move(to: CGPoint(x: hipX, y: hipY))
        legL.addLine(to: CGPoint(x: footLX, y: 46 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)

        var legR = Path()
        legR.move(to: CGPoint(x: hipX, y: hipY))
        legR.addLine(to: CGPoint(x: footRX, y: 46 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Tronc incliné latéralement vers la jambe gauche (hanche → épaule à gauche-haut)
        let shoulderX: CGFloat = 24 * s
        let shoulderY: CGFloat = 18 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: hipX, y: hipY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au bout du tronc incliné
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX - 2 * s - headSize / 2, y: shoulderY - headSize - 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras VERTICAL (l'un vers le ciel, l'autre vers le sol — signature triangle)
        // Bras haut vers le ciel
        var armUp = Path()
        armUp.move(to: CGPoint(x: shoulderX, y: shoulderY))
        armUp.addLine(to: CGPoint(x: shoulderX, y: 0))
        ctx.stroke(armUp, with: .color(silhouette), style: stroke)

        // Bras bas vers le pied gauche (touche la cheville)
        var armDown = Path()
        armDown.move(to: CGPoint(x: shoulderX + 1 * s, y: shoulderY + 2 * s))
        armDown.addLine(to: CGPoint(x: footLX, y: 44 * s))
        ctx.stroke(armDown, with: .color(silhouette), style: stroke)
    }

    /// Bateau — assis sur les fesses, jambes + bras tendus en V, équilibre.
    private func drawBoat(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil. Fesses au sol, jambes tendues vers le haut-droite, bras tendus vers le haut-droite (parallèles aux jambes).
        let buttX: CGFloat = 24 * s
        let buttY: CGFloat = 42 * s
        let footX: CGFloat = 68 * s
        let footY: CGFloat = 14 * s

        // Jambes tendues vers le haut-droite
        var legs = Path()
        legs.move(to: CGPoint(x: buttX, y: buttY))
        legs.addLine(to: CGPoint(x: footX, y: footY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Tronc incliné vers l'arrière (fesses → épaule en haut-gauche)
        let shoulderX: CGFloat = 18 * s
        let shoulderY: CGFloat = 24 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: buttX, y: buttY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au bout du tronc
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX - headSize / 2 - 1 * s, y: shoulderY - headSize - 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus vers les pieds (parallèles aux jambes — signature bateau)
        var arms = Path()
        arms.move(to: CGPoint(x: shoulderX + 1 * s, y: shoulderY + 2 * s))
        arms.addLine(to: CGPoint(x: footX - 4 * s, y: 18 * s))
        ctx.stroke(arms, with: .color(silhouette), style: stroke)
    }

    /// Savasana — allongé sur le dos, bras le long du corps, pieds tombants.
    private func drawSavasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue de dessus stylisée — silhouette HORIZONTALE allongée au sol.
        let headX: CGFloat = 14 * s
        let headY: CGFloat = 42 * s
        let headSize: CGFloat = 6 * s
        let footX: CGFloat = 66 * s
        let footY: CGFloat = 42 * s

        // Tête à gauche (cercle)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Corps allongé (épaule → pied)
        var body = Path()
        body.move(to: CGPoint(x: headX + headSize / 2 + 1 * s, y: headY))
        body.addLine(to: CGPoint(x: footX, y: footY))
        ctx.stroke(body, with: .color(silhouette), style: stroke)

        // Bras le long du corps (légèrement décalés en y)
        var armL = Path()
        armL.move(to: CGPoint(x: headX + 6 * s, y: headY - 1 * s))
        armL.addLine(to: CGPoint(x: headX + 22 * s, y: headY - 2 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: headX + 6 * s, y: headY + 1 * s))
        armR.addLine(to: CGPoint(x: headX + 22 * s, y: headY + 2 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Pieds tombants (petits chevrons V sur le côté droit, suggèrent les pieds tournés vers l'extérieur)
        var feet = Path()
        feet.move(to: CGPoint(x: footX, y: footY - 3 * s))
        feet.addLine(to: CGPoint(x: footX + 4 * s, y: footY))
        feet.addLine(to: CGPoint(x: footX, y: footY + 3 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Annotation : petits Z stylisés au-dessus de la tête (relaxation)
        var z = Path()
        z.move(to: CGPoint(x: headX - 4 * s, y: 32 * s))
        z.addLine(to: CGPoint(x: headX, y: 32 * s))
        z.addLine(to: CGPoint(x: headX - 4 * s, y: 36 * s))
        z.addLine(to: CGPoint(x: headX, y: 36 * s))
        ctx.stroke(z, with: .color(annotation),
                   style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
    }
}

#if DEBUG
#Preview("Yoga — 10 poses") {
    ScrollView {
        VStack(spacing: 12) {
            ForEach([
                "Chien tête en bas", "Guerrier I", "Guerrier II",
                "Arbre", "Cobra", "Enfant",
                "Pince debout", "Triangle", "Bateau", "Savasana"
            ], id: \.self) { name in
                VStack(alignment: .leading) {
                    Text(verbatim: name).font(.caption)
                    YogaIllustration(sportCode: "yoga", exerciseName: name)
                }
            }
        }
        .padding()
        .background(Color.coachingBackground)
    }
}
#endif
