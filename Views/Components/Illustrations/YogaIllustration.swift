// Views/Components/Illustrations/YogaIllustration.swift
// Story 3.19 Jalon 2c — 10 poses yoga V1 (Sophie 2026-05-23).
// Story 3.23 Tier 1 Jalon 1 — ajout Dirgha pranayama + Cat-cow (+ variante
// avant-bras) suite test simu Sophie 2026-05-24 (3 KO confirmés).
// Pattern ombrelle `.yoga` → dispatch interne keyword `exerciseName` vers la
// sub-pose. Toutes statiques 1 frame + annotations alignement orange.
//
// Poses V1 (Story 3.19) :
//   - Chien tête en bas (Adho Mukha Svanasana)
//   - Guerrier I, II (Virabhadrasana I, II)
//   - Arbre (Vrksasana)
//   - Cobra (Bhujangasana)
//   - Enfant (Balasana)
//   - Pince debout (Uttanasana)
//   - Triangle (Trikonasana)
//   - Bateau (Navasana)
//   - Savasana (cadavre)
// Poses ajoutées Story 3.23 Tier 1 Jalon 1 :
//   - Dirgha pranayama (respiration 3-parties allongée + 3 cercles)
//   - Cat-cow (Marjaryasana-Bitilasana) — 4 pattes profil + flèches ↕
//   - Cat-cow variante avant-bras
// Poses ajoutées Story 3.23 Tier 1 Jalon 3 (haute fréquence inventaire agent) :
//   - Sarvangasana / Chandelle (88 occ × 4 tpl)
//   - Setu Bandha / Pont fessier (69 occ × 4 tpl)
//   - Ujjayi / Pranayama souffle océan assise (75 occ × 4 tpl)
//   - Surya Namaskar A / Salutation soleil A (97 occ × 3 tpl) — 3 mini-silhouettes
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
            case .downwardDog:     drawDownwardDog(ctx, s: s, stroke: stroke)
            case .warrior1:        drawWarrior1(ctx, s: s, stroke: stroke)
            case .warrior2:        drawWarrior2(ctx, s: s, stroke: stroke)
            case .tree:            drawTree(ctx, s: s, stroke: stroke)
            case .cobra:           drawCobra(ctx, s: s, stroke: stroke)
            case .child:           drawChild(ctx, s: s, stroke: stroke)
            case .forwardFold:     drawForwardFold(ctx, s: s, stroke: stroke)
            case .triangle:        drawTriangle(ctx, s: s, stroke: stroke)
            case .boat:            drawBoat(ctx, s: s, stroke: stroke)
            case .savasana:        drawSavasana(ctx, s: s, stroke: stroke)
            case .dirgha:          drawDirgha(ctx, s: s, stroke: stroke)
            case .catCow:          drawCatCow(ctx, s: s, stroke: stroke, forearms: false)
            case .catCowForearms:  drawCatCow(ctx, s: s, stroke: stroke, forearms: true)
            case .sarvangasana:    drawSarvangasana(ctx, s: s, stroke: stroke)
            case .setuBandha:      drawSetuBandha(ctx, s: s, stroke: stroke)
            case .ujjayi:          drawUjjayi(ctx, s: s, stroke: stroke)
            case .suryaNamaskarA:  drawSuryaNamaskarA(ctx, s: s, stroke: stroke)
            case .unknown:         drawWarrior1(ctx, s: s, stroke: stroke) // fallback safe
            }
        }
        .frame(width: IllustrationStyle.staticFrameSize.width,
               height: IllustrationStyle.staticFrameSize.height)
    }

    // MARK: - Pose detection

    private enum YogaPose {
        case downwardDog, warrior1, warrior2, tree, cobra
        case child, forwardFold, triangle, boat, savasana
        // Story 3.23 Tier 1 Jalon 1
        case dirgha, catCow, catCowForearms
        // Story 3.23 Tier 1 Jalon 3
        case sarvangasana, setuBandha, ujjayi, suryaNamaskarA
        case unknown
    }

    private var poseKind: YogaPose {
        guard let lower = exerciseName?.lowercased() else { return .unknown }
        // Cat-cow variante avant-bras AVANT cat-cow (ordering matters : "avant-bras"
        // doit matcher avant le simple "cat"/"cow").
        if (lower.contains("avant-bras") || lower.contains("avant bras") || lower.contains("forearm"))
            && (lower.contains("cat") || lower.contains("cow") || lower.contains("chat") || lower.contains("vache")
                || lower.contains("marjaryasana") || lower.contains("bitilasana")) {
            return .catCowForearms
        }
        if lower.contains("cat-cow") || lower.contains("cat cow") || lower.contains("chat-vache") || lower.contains("chat vache")
            || lower.contains("marjaryasana") || lower.contains("bitilasana") {
            return .catCow
        }
        // Story 3.23 Tier 1 Jalon 3 — Ujjayi (souffle océan assise)
        if lower.contains("ujjayi") || lower.contains("souffle océan") || lower.contains("souffle ocean")
            || lower.contains("ocean breath") {
            return .ujjayi
        }
        // Dirgha pranayama (respiration 3-parties). Ordre : Ujjayi avant Dirgha
        // (sinon "pranayama" générique tomberait sur Dirgha pour Ujjayi).
        if lower.contains("dirgha") || lower.contains("respiration 3") || lower.contains("respiration trois")
            || lower.contains("trois temps") || lower.contains("three part")
            || lower.contains("pranayama") {
            return .dirgha
        }
        // Story 3.23 Tier 1 Jalon 3 — Sarvangasana (chandelle/shoulderstand)
        if lower.contains("sarvangasana") || lower.contains("chandelle") || lower.contains("shoulderstand")
            || lower.contains("shoulder stand") {
            return .sarvangasana
        }
        // Setu Bandha (pont fessier) — distinguer du "pont fessier" strength
        // (hip thrust). Le sport yoga + le nom Setu/bridge yoga différencie.
        if lower.contains("setu bandha") || lower.contains("setu-bandha")
            || (lower.contains("pont") && (lower.contains("yoga") || lower.contains("setu")))
            || lower.contains("bridge pose") {
            return .setuBandha
        }
        // Surya Namaskar A (salutation soleil)
        if lower.contains("surya namaskar") || lower.contains("salutation soleil")
            || lower.contains("salutation au soleil") || lower.contains("sun salutation") {
            return .suryaNamaskarA
        }
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

    // MARK: - Story 3.23 Tier 1 Jalon 1 — Dirgha + Cat-cow

    /// Dirgha pranayama — respiration 3-parties allongée sur le dos.
    /// Silhouette allongée (canon savasana). 3 demi-cercles d'expansion alignés
    /// sur le tronc dans l'ordre d'inspiration : 1 (ventre, côté pieds) →
    /// 2 (thorax, milieu) → 3 (clavicules, côté tête). Tailles croissantes
    /// suggèrent l'amplitude de chaque phase.
    /// Réf : Iyengar "Light on Pranayama" (3-part breath / dirgha pranayama).
    private func drawDirgha(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Silhouette allongée vue de dessus, tête à gauche (canon savasana adapté)
        let headX: CGFloat = 12 * s
        let headY: CGFloat = 32 * s
        let headSize: CGFloat = 5 * s
        let shoulderX: CGFloat = 18 * s
        let trunkEndX: CGFloat = 52 * s   // fin du tronc côté hanches
        let footX: CGFloat = 68 * s
        let trunkY: CGFloat = 32 * s      // axe horizontal du corps

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Corps tronc + jambes (épaule → pied)
        var bodyLine = Path()
        bodyLine.move(to: CGPoint(x: shoulderX, y: trunkY))
        bodyLine.addLine(to: CGPoint(x: footX, y: trunkY))
        ctx.stroke(bodyLine, with: .color(silhouette), style: stroke)

        // Bras le long du corps (visibles, parallèles au tronc)
        var armL = Path()
        armL.move(to: CGPoint(x: shoulderX + 1 * s, y: trunkY - 2 * s))
        armL.addLine(to: CGPoint(x: 38 * s, y: trunkY - 2 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: shoulderX + 1 * s, y: trunkY + 2 * s))
        armR.addLine(to: CGPoint(x: 38 * s, y: trunkY + 2 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Petits pieds en V au bout (signature pieds tombants)
        var feet = Path()
        feet.move(to: CGPoint(x: footX, y: trunkY - 3 * s))
        feet.addLine(to: CGPoint(x: footX + 4 * s, y: trunkY))
        feet.addLine(to: CGPoint(x: footX, y: trunkY + 3 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // 3 demi-cercles d'expansion respiratoire sur le tronc.
        // Ordre temporel de l'inspiration : 1 (ventre, côté droit/pieds) →
        // 2 (thorax, milieu) → 3 (clavicules, côté gauche/tête).
        // Position : SOUS la ligne du corps (le ventre/torse se gonflent vers le bas
        // visuellement, comme si on était vu du dessus avec gonflement vers le haut
        // de l'image — ici en demi-cercle qui s'ouvre vers le haut, attaché au corps).
        let arcStyle = StrokeStyle(lineWidth: 1.5 * s, lineCap: .round, lineJoin: .round)

        // Phase 1 — ventre (le plus proche des hanches/pieds, taille moyenne)
        var arc1 = Path()
        arc1.addArc(center: CGPoint(x: 46 * s, y: trunkY), radius: 4 * s,
                    startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
        ctx.stroke(arc1, with: .color(annotation), style: arcStyle)

        // Phase 2 — thorax (milieu du tronc, taille moyenne)
        var arc2 = Path()
        arc2.addArc(center: CGPoint(x: 34 * s, y: trunkY), radius: 4 * s,
                    startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
        ctx.stroke(arc2, with: .color(annotation), style: arcStyle)

        // Phase 3 — clavicules (le plus proche des épaules/tête, taille moyenne)
        var arc3 = Path()
        arc3.addArc(center: CGPoint(x: 22 * s, y: trunkY), radius: 4 * s,
                    startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
        ctx.stroke(arc3, with: .color(annotation), style: arcStyle)

        // Petites flèches indiquant l'ordre d'inspiration (1 → 2 → 3, droite vers gauche)
        let arrowStyle = StrokeStyle(lineWidth: 1.0 * s, lineCap: .round, lineJoin: .round)
        var orderArrow = Path()
        // Flèche horizontale au-dessus des arcs, pointant vers la tête (= vers la phase 3)
        orderArrow.move(to: CGPoint(x: 48 * s, y: 22 * s))
        orderArrow.addLine(to: CGPoint(x: 20 * s, y: 22 * s))
        orderArrow.move(to: CGPoint(x: 22 * s, y: 20 * s))
        orderArrow.addLine(to: CGPoint(x: 20 * s, y: 22 * s))
        orderArrow.addLine(to: CGPoint(x: 22 * s, y: 24 * s))
        ctx.stroke(orderArrow, with: .color(annotation), style: arrowStyle)
    }

    /// Cat-cow (Marjaryasana-Bitilasana) — 2 mini-silhouettes 4-pattes profil
    /// côte à côte : Cat (dos rond, tête baissée) à gauche, Cow (dos creux,
    /// tête relevée) à droite, séparées par une flèche ↔ alternance orange.
    ///
    /// **Référence anatomique** (Wikipedia Marjariasana + canon yoga) :
    /// - Cat = flexion vertébrale : dos arrondi en arc CONVEXE vers le ciel,
    ///   bassin en rétroversion (queue rentrée), tête baissée menton-poitrine.
    /// - Cow = extension vertébrale : dos creux en arc CONCAVE (ventre tombe),
    ///   bassin en antéversion (ischions hauts), tête relevée regard haut.
    /// - Position commune : mains sous les épaules, genoux sous les hanches,
    ///   verticalité bras + cuisses.
    ///
    /// `forearms == true` : variante avec avant-bras au sol au lieu des mains
    /// (= bras pliés à 90°, coude sous l'épaule, avant-bras horizontal au sol).
    private func drawCatCow(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, forearms: Bool) {
        // Cat à gauche (zone x [4-36], centre cx=20), Cow à droite (zone x [44-76], centre cx=60)
        drawCatPhase(ctx, s: s, stroke: stroke, originCx: 20, forearms: forearms)
        drawCowPhase(ctx, s: s, stroke: stroke, originCx: 60, forearms: forearms)

        // Flèche ↔ centrale (annotation alternance entre Cat et Cow)
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var arrow = Path()
        // Trait horizontal au milieu
        arrow.move(to: CGPoint(x: 36 * s, y: 24 * s))
        arrow.addLine(to: CGPoint(x: 44 * s, y: 24 * s))
        // Chevron gauche (pointe vers Cat)
        arrow.move(to: CGPoint(x: 38 * s, y: 22 * s))
        arrow.addLine(to: CGPoint(x: 36 * s, y: 24 * s))
        arrow.addLine(to: CGPoint(x: 38 * s, y: 26 * s))
        // Chevron droit (pointe vers Cow)
        arrow.move(to: CGPoint(x: 42 * s, y: 22 * s))
        arrow.addLine(to: CGPoint(x: 44 * s, y: 24 * s))
        arrow.addLine(to: CGPoint(x: 42 * s, y: 26 * s))
        ctx.stroke(arrow, with: .color(annotation), style: arrowStyle)
    }

    /// Cat phase — dos rond CONVEXE, tête baissée. Centre `originCx` (4-36 ou 44-76).
    private func drawCatPhase(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originCx: CGFloat, forearms: Bool) {
        // Articulations clés (coordonnées canvas 80×48)
        let handX: CGFloat = (originCx - 10) * s   // ex Cat: 10
        let kneeX: CGFloat = (originCx + 8) * s    // ex Cat: 28
        let shoulderX: CGFloat = (originCx - 8) * s // ex Cat: 12
        let hipX: CGFloat = (originCx + 6) * s     // ex Cat: 26
        let shoulderY: CGFloat = 30 * s
        let hipY: CGFloat = 30 * s

        // Bras / avant-bras
        if forearms {
            // Avant-bras au sol : coude sous l'épaule, main devant
            let elbowX: CGFloat = shoulderX
            var armUpper = Path()
            armUpper.move(to: CGPoint(x: shoulderX, y: shoulderY))
            armUpper.addLine(to: CGPoint(x: elbowX, y: 46 * s))
            ctx.stroke(armUpper, with: .color(silhouette), style: stroke)
            var forearmPath = Path()
            forearmPath.move(to: CGPoint(x: elbowX, y: 46 * s))
            forearmPath.addLine(to: CGPoint(x: handX, y: 46 * s))
            ctx.stroke(forearmPath, with: .color(silhouette), style: stroke)
        } else {
            // Mains au sol (bras quasi-verticaux)
            var arm = Path()
            arm.move(to: CGPoint(x: handX, y: 46 * s))
            arm.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
            ctx.stroke(arm, with: .color(silhouette), style: stroke)
        }

        // Cuisses (genou au sol → hanche)
        var thigh = Path()
        thigh.move(to: CGPoint(x: kneeX, y: 46 * s))
        thigh.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(thigh, with: .color(silhouette), style: stroke)

        // Dos CONVEXE (bombé vers le HAUT) — addQuadCurve avec control point au-dessus
        let backControlX: CGFloat = (originCx - 1) * s  // milieu épaule-hanche
        let backControlY: CGFloat = 22 * s              // au-dessus de la ligne épaule-hanche
        var back = Path()
        back.move(to: CGPoint(x: shoulderX, y: shoulderY))
        back.addQuadCurve(to: CGPoint(x: hipX, y: hipY),
                          control: CGPoint(x: backControlX, y: backControlY))
        ctx.stroke(back, with: .color(silhouette), style: stroke)

        // Cou descend en bas-gauche (tête baissée, menton-poitrine)
        let neckEndX: CGFloat = (originCx - 12) * s  // ex Cat: 8
        let neckEndY: CGFloat = 35 * s
        var neck = Path()
        neck.move(to: CGPoint(x: shoulderX, y: shoulderY))
        neck.addLine(to: CGPoint(x: neckEndX, y: neckEndY))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Tête baissée (cercle sous le cou)
        let headSize: CGFloat = 4 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: neckEndX - headSize / 2 - 1 * s, y: neckEndY + 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Orteils repliés derrière les genoux
        var toes = Path()
        toes.move(to: CGPoint(x: kneeX, y: 46 * s))
        toes.addLine(to: CGPoint(x: kneeX + 4 * s, y: 46 * s))
        ctx.stroke(toes, with: .color(silhouette), style: stroke)
    }

    /// Cow phase — dos creux CONCAVE, tête relevée. Centre `originCx`.
    private func drawCowPhase(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originCx: CGFloat, forearms: Bool) {
        let handX: CGFloat = (originCx - 10) * s
        let kneeX: CGFloat = (originCx + 8) * s
        let shoulderX: CGFloat = (originCx - 8) * s
        let hipX: CGFloat = (originCx + 6) * s
        let shoulderY: CGFloat = 30 * s
        let hipY: CGFloat = 30 * s

        // Bras / avant-bras (idem Cat)
        if forearms {
            let elbowX: CGFloat = shoulderX
            var armUpper = Path()
            armUpper.move(to: CGPoint(x: shoulderX, y: shoulderY))
            armUpper.addLine(to: CGPoint(x: elbowX, y: 46 * s))
            ctx.stroke(armUpper, with: .color(silhouette), style: stroke)
            var forearmPath = Path()
            forearmPath.move(to: CGPoint(x: elbowX, y: 46 * s))
            forearmPath.addLine(to: CGPoint(x: handX, y: 46 * s))
            ctx.stroke(forearmPath, with: .color(silhouette), style: stroke)
        } else {
            var arm = Path()
            arm.move(to: CGPoint(x: handX, y: 46 * s))
            arm.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
            ctx.stroke(arm, with: .color(silhouette), style: stroke)
        }

        // Cuisses
        var thigh = Path()
        thigh.move(to: CGPoint(x: kneeX, y: 46 * s))
        thigh.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(thigh, with: .color(silhouette), style: stroke)

        // Dos CONCAVE (creusé vers le BAS) — control point en-dessous de la ligne
        let backControlX: CGFloat = (originCx - 1) * s
        let backControlY: CGFloat = 38 * s  // sous la ligne épaule-hanche (qui est à y=30)
        var back = Path()
        back.move(to: CGPoint(x: shoulderX, y: shoulderY))
        back.addQuadCurve(to: CGPoint(x: hipX, y: hipY),
                          control: CGPoint(x: backControlX, y: backControlY))
        ctx.stroke(back, with: .color(silhouette), style: stroke)

        // Cou remonte en haut-gauche (tête relevée, regard vers le haut)
        let neckEndX: CGFloat = (originCx - 12) * s
        let neckEndY: CGFloat = 24 * s
        var neck = Path()
        neck.move(to: CGPoint(x: shoulderX, y: shoulderY))
        neck.addLine(to: CGPoint(x: neckEndX, y: neckEndY))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Tête relevée (cercle au-dessus du cou)
        let headSize: CGFloat = 4 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: neckEndX - headSize / 2 - 1 * s, y: neckEndY - headSize - 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Orteils repliés derrière les genoux
        var toes = Path()
        toes.move(to: CGPoint(x: kneeX, y: 46 * s))
        toes.addLine(to: CGPoint(x: kneeX + 4 * s, y: 46 * s))
        ctx.stroke(toes, with: .color(silhouette), style: stroke)
    }

    // MARK: - Story 3.23 Tier 1 Jalon 3 — 4 poses haute fréquence

    /// Sarvangasana (Chandelle / Shoulderstand) — corps inversé en V :
    /// tête et nuque au sol côté gauche, dos vertical, jambes vers le haut.
    /// Réf : Yoga Journal Salamba Sarvangasana.
    private func drawSarvangasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Tête et épaules au sol (à gauche, allongée). Le sol pointillé existant
        // est suffisant : la tête est posée dessus.
        let headX: CGFloat = 18 * s
        let headY: CGFloat = 44 * s  // un peu au-dessus du sol y=46
        let headSize: CGFloat = 5 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Épaules au sol (côté droit de la tête)
        let shoulderX: CGFloat = headX + 8 * s  // 26
        let shoulderY: CGFloat = 44 * s

        // Dos vertical : épaule → hanche (vers le haut)
        let hipX: CGFloat = shoulderX + 2 * s  // 28
        let hipY: CGFloat = 22 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambes verticales : hanche → pieds (vers le haut)
        let feetX: CGFloat = hipX
        let feetY: CGFloat = 4 * s
        var legs = Path()
        legs.move(to: CGPoint(x: hipX, y: hipY))
        legs.addLine(to: CGPoint(x: feetX, y: feetY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Petits orteils horizontaux pour signature
        var toes = Path()
        toes.move(to: CGPoint(x: feetX - 2 * s, y: feetY))
        toes.addLine(to: CGPoint(x: feetX + 2 * s, y: feetY))
        ctx.stroke(toes, with: .color(silhouette), style: stroke)

        // Bras qui soutiennent le bas du dos (épaule → coude au sol → main au tronc)
        var supportArm = Path()
        supportArm.move(to: CGPoint(x: shoulderX, y: shoulderY))
        supportArm.addLine(to: CGPoint(x: shoulderX + 4 * s, y: 44 * s))  // coude au sol
        supportArm.addLine(to: CGPoint(x: shoulderX + 6 * s, y: 32 * s))  // main qui touche le dos
        ctx.stroke(supportArm, with: .color(silhouette), style: stroke)
    }

    /// Setu Bandha (Pont fessier yoga) — allongée sur le dos, genoux pliés,
    /// pieds au sol, bassin levé. Distinct du Hip Thrust strength (pas de banc).
    /// Réf : Yoga Journal Bridge Pose.
    private func drawSetuBandha(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Tête au sol côté gauche
        let headX: CGFloat = 12 * s
        let headY: CGFloat = 42 * s
        let headSize: CGFloat = 5 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Épaules au sol (droite de la tête)
        let shoulderX: CGFloat = 20 * s
        let shoulderY: CGFloat = 42 * s

        // Pieds au sol côté droit
        let footX: CGFloat = 60 * s
        let footY: CGFloat = 46 * s

        // Genoux levés au-dessus des pieds
        let kneeX: CGFloat = footX - 2 * s
        let kneeY: CGFloat = 30 * s

        // Bassin (hanche) levé en pont, position haute
        let hipX: CGFloat = 42 * s
        let hipY: CGFloat = 26 * s  // haut = pont fait

        // Tronc (épaule → hanche en montant)
        var trunk = Path()
        trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Cuisses (hanche → genou) — quasi horizontales
        var thigh = Path()
        thigh.move(to: CGPoint(x: hipX, y: hipY))
        thigh.addLine(to: CGPoint(x: kneeX, y: kneeY))
        ctx.stroke(thigh, with: .color(silhouette), style: stroke)

        // Tibias (genou → pied)
        var shin = Path()
        shin.move(to: CGPoint(x: kneeX, y: kneeY))
        shin.addLine(to: CGPoint(x: footX, y: footY))
        ctx.stroke(shin, with: .color(silhouette), style: stroke)

        // Bras le long du corps au sol (épaule → main au sol)
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX + 2 * s, y: shoulderY + 1 * s))
        arm.addLine(to: CGPoint(x: shoulderX + 14 * s, y: 46 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Annotation : flèche ↑ au-dessus du bassin (contraction)
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var arrow = Path()
        arrow.move(to: CGPoint(x: hipX, y: hipY + 2 * s))
        arrow.addLine(to: CGPoint(x: hipX, y: hipY - 6 * s))
        arrow.move(to: CGPoint(x: hipX - 2 * s, y: hipY - 4 * s))
        arrow.addLine(to: CGPoint(x: hipX, y: hipY - 6 * s))
        arrow.addLine(to: CGPoint(x: hipX + 2 * s, y: hipY - 4 * s))
        ctx.stroke(arrow, with: .color(annotation), style: arrowStyle)
    }

    /// Ujjayi (souffle océan) — assise jambes croisées, annotation cercle
    /// souffle autour du cou/gorge (zone de contraction du souffle océan).
    /// Réf : Yoga Journal Ujjayi.
    private func drawUjjayi(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue face (silhouette assise vue de devant)
        let centerX: CGFloat = 40 * s
        let hipY: CGFloat = 38 * s

        // Tête (face)
        let headSize: CGFloat = 6 * s
        let headY: CGFloat = 14 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc (épaule → hanche)
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: headY + headSize / 2))
        trunk.addLine(to: CGPoint(x: centerX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Bras croisés sur les genoux (vue face : 2 bras horizontaux qui posent
        // sur les cuisses puis remontent vers les paumes)
        var armL = Path()
        armL.move(to: CGPoint(x: centerX - 1 * s, y: 22 * s))  // épaule gauche
        armL.addLine(to: CGPoint(x: centerX - 12 * s, y: 36 * s))  // main posée
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 1 * s, y: 22 * s))
        armR.addLine(to: CGPoint(x: centerX + 12 * s, y: 36 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Jambes croisées (Sukhasana) — 2 V de chaque côté
        var legL = Path()
        legL.move(to: CGPoint(x: centerX, y: hipY))
        legL.addLine(to: CGPoint(x: centerX - 14 * s, y: 44 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: centerX, y: hipY))
        legR.addLine(to: CGPoint(x: centerX + 14 * s, y: 44 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Pieds croisés au centre (petite ligne horizontale)
        var feet = Path()
        feet.move(to: CGPoint(x: centerX - 8 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: centerX + 8 * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Annotation : cercle souffle autour de la gorge (signature Ujjayi)
        let breathCircleY: CGFloat = 20 * s
        let breathRadius: CGFloat = 5 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - breathRadius, y: breathCircleY - breathRadius,
                                    width: breathRadius * 2, height: breathRadius * 2)),
            with: .color(annotation),
            style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, dash: [2 * s, 1.5 * s])
        )
        // Flèche d'entrée souffle (côté gauche du cercle)
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var inhale = Path()
        inhale.move(to: CGPoint(x: centerX - 12 * s, y: breathCircleY))
        inhale.addLine(to: CGPoint(x: centerX - 6 * s, y: breathCircleY))
        inhale.move(to: CGPoint(x: centerX - 8 * s, y: breathCircleY - 1.5 * s))
        inhale.addLine(to: CGPoint(x: centerX - 6 * s, y: breathCircleY))
        inhale.addLine(to: CGPoint(x: centerX - 8 * s, y: breathCircleY + 1.5 * s))
        ctx.stroke(inhale, with: .color(annotation), style: arrowStyle)
    }

    /// Surya Namaskar A — 3 mini-silhouettes côte à côte représentant
    /// l'essence du flow : Tadasana → Uttanasana → Chaturanga.
    /// Forme condensée car séquence 12 postures non visualisable en 1 frame.
    /// Réf : Yoga Journal Sun Salutation A.
    private func drawSuryaNamaskarA(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // 3 zones côte à côte : x=[2-26] | [28-52] | [54-78]
        // 1. Tadasana (debout)
        drawMiniTadasana(ctx, s: s, stroke: stroke, originX: 4)
        // 2. Uttanasana (plié avant)
        drawMiniUttanasana(ctx, s: s, stroke: stroke, originX: 28)
        // 3. Chaturanga (plank bas)
        drawMiniChaturanga(ctx, s: s, stroke: stroke, originX: 52)

        // 2 flèches entre les mini-poses (référentiel : la séquence se déroule)
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var arrow1 = Path()
        arrow1.move(to: CGPoint(x: 25 * s, y: 24 * s))
        arrow1.addLine(to: CGPoint(x: 28 * s, y: 24 * s))
        arrow1.move(to: CGPoint(x: 26.5 * s, y: 22.5 * s))
        arrow1.addLine(to: CGPoint(x: 28 * s, y: 24 * s))
        arrow1.addLine(to: CGPoint(x: 26.5 * s, y: 25.5 * s))
        ctx.stroke(arrow1, with: .color(annotation), style: arrowStyle)

        var arrow2 = Path()
        arrow2.move(to: CGPoint(x: 50 * s, y: 24 * s))
        arrow2.addLine(to: CGPoint(x: 53 * s, y: 24 * s))
        arrow2.move(to: CGPoint(x: 51.5 * s, y: 22.5 * s))
        arrow2.addLine(to: CGPoint(x: 53 * s, y: 24 * s))
        arrow2.addLine(to: CGPoint(x: 51.5 * s, y: 25.5 * s))
        ctx.stroke(arrow2, with: .color(annotation), style: arrowStyle)
    }

    private func drawMiniTadasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let cx: CGFloat = (originX + 12) * s
        // Tête
        let headSize: CGFloat = 4 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 10 * s, width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
        // Corps debout (cou → pieds)
        var body = Path()
        body.move(to: CGPoint(x: cx, y: 14 * s))
        body.addLine(to: CGPoint(x: cx, y: 44 * s))
        ctx.stroke(body, with: .color(silhouette), style: stroke)
        // Bras le long du corps
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 1 * s, y: 18 * s))
        armL.addLine(to: CGPoint(x: cx - 4 * s, y: 32 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 1 * s, y: 18 * s))
        armR.addLine(to: CGPoint(x: cx + 4 * s, y: 32 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    private func drawMiniUttanasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let cx: CGFloat = (originX + 12) * s
        // Pieds au sol au centre
        let footY: CGFloat = 44 * s
        // Tête en bas (proche des pieds), corps plié vers le sol
        let headSize: CGFloat = 4 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 36 * s, width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
        // Jambes droites (pied → hanche en haut)
        var legs = Path()
        legs.move(to: CGPoint(x: cx, y: footY))
        legs.addLine(to: CGPoint(x: cx, y: 18 * s))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)
        // Tronc plié (hanche → tête en bas)
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 18 * s))
        trunk.addLine(to: CGPoint(x: cx, y: 36 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)
        // Bras pendants vers le sol
        var arm = Path()
        arm.move(to: CGPoint(x: cx - 1 * s, y: 22 * s))
        arm.addLine(to: CGPoint(x: cx - 3 * s, y: 42 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    private func drawMiniChaturanga(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let cy: CGFloat = 32 * s
        // Corps horizontal (plank bas)
        // Tête côté droit
        let headSize: CGFloat = 4 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: (originX + 22) * s - headSize / 2, y: cy - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
        // Tronc horizontal
        var trunk = Path()
        trunk.move(to: CGPoint(x: (originX + 20) * s, y: cy))
        trunk.addLine(to: CGPoint(x: (originX + 8) * s, y: cy))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)
        // Jambes (tronc → talon côté gauche)
        var legs = Path()
        legs.move(to: CGPoint(x: (originX + 8) * s, y: cy))
        legs.addLine(to: CGPoint(x: (originX + 2) * s, y: 36 * s))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)
        // Bras au sol sous les épaules (coude plié, signature chaturanga)
        var arm = Path()
        arm.move(to: CGPoint(x: (originX + 20) * s, y: cy + 1 * s))
        arm.addLine(to: CGPoint(x: (originX + 18) * s, y: 40 * s))
        arm.addLine(to: CGPoint(x: (originX + 20) * s, y: 44 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
        // Pieds (petits orteils au sol)
        var feet = Path()
        feet.move(to: CGPoint(x: (originX + 2) * s, y: 36 * s))
        feet.addLine(to: CGPoint(x: (originX + 1) * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)
    }
}

#if DEBUG
#Preview("Yoga — 17 poses") {
    ScrollView {
        VStack(spacing: 12) {
            ForEach([
                "Chien tête en bas", "Guerrier I", "Guerrier II",
                "Arbre", "Cobra", "Enfant",
                "Pince debout", "Triangle", "Bateau", "Savasana",
                // Story 3.23 Tier 1 Jalon 1
                "Dirgha pranayama", "Cat-cow", "Cat-cow sur les avant-bras",
                // Story 3.23 Tier 1 Jalon 3
                "Sarvangasana (Chandelle)", "Setu Bandha (Pont yoga)",
                "Ujjayi (souffle océan)", "Surya Namaskar A"
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
