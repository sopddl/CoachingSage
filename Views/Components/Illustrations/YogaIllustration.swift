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
            // Story 3.23 Lot 2
            case .padangusthasana:     drawPadangusthasana(ctx, s: s, stroke: stroke)
            case .suryaNamaskarB:      drawSuryaNamaskarB(ctx, s: s, stroke: stroke)
            case .baddhaKonasana:      drawBaddhaKonasana(ctx, s: s, stroke: stroke)
            case .paschimottanasana:   drawPaschimottanasana(ctx, s: s, stroke: stroke)
            case .suptaBaddhaKonasana: drawSuptaBaddhaKonasana(ctx, s: s, stroke: stroke)
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
        // Story 3.23 Lot 2 (haute fréquence)
        case padangusthasana, suryaNamaskarB, baddhaKonasana, paschimottanasana, suptaBaddhaKonasana
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
        // Story 3.23 Lot 2 — Surya Namaskar B (avec Utkatasana) AVANT A
        // (sinon "surya namaskar" matche A en priorité).
        if lower.contains("surya namaskar b") || lower.contains("salutation soleil b")
            || lower.contains("sun salutation b") {
            return .suryaNamaskarB
        }
        // Surya Namaskar A (salutation soleil)
        if lower.contains("surya namaskar") || lower.contains("salutation soleil")
            || lower.contains("salutation au soleil") || lower.contains("sun salutation") {
            return .suryaNamaskarA
        }
        // Story 3.23 Lot 2 — Supta Baddha Konasana (papillon allongé) AVANT
        // Baddha Konasana (sinon "baddha" matche cordonnier assis).
        if lower.contains("supta baddha") || lower.contains("supta-baddha")
            || lower.contains("papillon allongé") || lower.contains("papillon allonge")
            || lower.contains("reclining bound angle") || lower.contains("reclining cobbler") {
            return .suptaBaddhaKonasana
        }
        // Story 3.23 Lot 2 — Baddha Konasana (cordonnier / cobbler assis)
        if lower.contains("baddha konasana") || lower.contains("baddha-konasana")
            || lower.contains("cordonnier") || lower.contains("cobbler")
            || lower.contains("bound angle") || lower.contains("papillon") {
            return .baddhaKonasana
        }
        // Story 3.23 Lot 2 — Paschimottanasana (flexion avant assise)
        if lower.contains("paschimottanasana") || lower.contains("flexion avant assise")
            || lower.contains("seated forward bend") || lower.contains("pince assise") {
            return .paschimottanasana
        }
        // Story 3.23 Lot 2 — Padangusthasana (flexion grand orteil debout)
        // Doit matcher AVANT Uttanasana car les 2 poses sont proches (Pince debout).
        if lower.contains("padangusthasana") || lower.contains("grand orteil")
            || lower.contains("big toe pose") || lower.contains("gros orteil") {
            return .padangusthasana
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
    /// Arbre (Vrksasana) — refonte Story 3.23 Lot 1 (2026-05-25).
    /// Source : https://en.wikipedia.org/wiki/Vrikshasana
    /// Signature : genou TRÈS écarté + pied collé cuisse intérieure + mains
    /// jointes en losange au-dessus de la tête (coudes écartés).
    private func drawTree(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let centerX: CGFloat = 24 * s
        let headSize: CGFloat = 6 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: 8 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc (épaules → hanche)
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: 14 * s))
        trunk.addLine(to: CGPoint(x: centerX, y: 26 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambe d'appui (verticale, pied à plat au sol)
        var standLeg = Path()
        standLeg.move(to: CGPoint(x: centerX, y: 26 * s))
        standLeg.addLine(to: CGPoint(x: centerX - 2 * s, y: 36 * s))
        standLeg.addLine(to: CGPoint(x: centerX - 2 * s, y: 46 * s))
        ctx.stroke(standLeg, with: .color(silhouette), style: stroke)

        // Jambe pliée signature : genou très écarté + pied revient et S'APPUIE
        // sur la cuisse intérieure (petit marqueur horizontal explicite au contact).
        var foldedLeg = Path()
        foldedLeg.move(to: CGPoint(x: centerX, y: 26 * s))
        foldedLeg.addLine(to: CGPoint(x: centerX + 11 * s, y: 30 * s))
        foldedLeg.addLine(to: CGPoint(x: centerX - 1 * s, y: 36 * s))
        ctx.stroke(foldedLeg, with: .color(silhouette), style: stroke)

        // Marqueur pied posé sur cuisse intérieure (segment horizontal au contact)
        var footMark = Path()
        footMark.move(to: CGPoint(x: centerX - 3 * s, y: 36 * s))
        footMark.addLine(to: CGPoint(x: centerX, y: 36 * s))
        ctx.stroke(footMark, with: .color(silhouette), style: stroke)

        // Bras gauche en losange large (coude bien écarté pour visibilité)
        var armL = Path()
        armL.move(to: CGPoint(x: centerX - 2 * s, y: 14 * s))
        armL.addLine(to: CGPoint(x: centerX - 7 * s, y: 8 * s))
        armL.addLine(to: CGPoint(x: centerX - 1 * s, y: 1 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        // Bras droit en losange large
        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 2 * s, y: 14 * s))
        armR.addLine(to: CGPoint(x: centerX + 7 * s, y: 8 * s))
        armR.addLine(to: CGPoint(x: centerX + 1 * s, y: 1 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Marqueur mains jointes (petit segment horizontal au sommet du losange)
        var palms = Path()
        palms.move(to: CGPoint(x: centerX - 2 * s, y: 1 * s))
        palms.addLine(to: CGPoint(x: centerX + 2 * s, y: 1 * s))
        ctx.stroke(palms, with: .color(silhouette), style: stroke)
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

    /// Enfant (Balasana) — refonte Story 3.23 Lot 1 v4 (2026-05-25).
    /// Source : https://en.wikipedia.org/wiki/Balasana
    /// Signature : silhouette agenouillée nettement visible (cuisses verticales
    /// repliées sur les talons + fessiers surélevés en arc + dos arrondi
    /// large + front au sol + bras tendus devant le long du sol).
    /// Refonte v4 : élévation fessiers + dos plus arrondi + bras DEVANT bien
    /// séparés du corps.
    private func drawChild(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil, personnage face à gauche. Tibias+fesses côté droit, front+bras côté gauche.

        // Pied/talon (sous les fesses, côté droit) — segment au sol
        let footX: CGFloat = 50 * s
        let footY: CGFloat = 46 * s
        var footMark = Path()
        footMark.move(to: CGPoint(x: footX - 2 * s, y: footY))
        footMark.addLine(to: CGPoint(x: footX + 2 * s, y: footY))
        ctx.stroke(footMark, with: .color(silhouette), style: stroke)

        // Tibia plié au sol (talon vers genou — quasi horizontal)
        var shin = Path()
        shin.move(to: CGPoint(x: footX, y: footY))
        shin.addLine(to: CGPoint(x: 38 * s, y: 44 * s))
        ctx.stroke(shin, with: .color(silhouette), style: stroke)

        // Genou (segment vertical court)
        var knee = Path()
        knee.move(to: CGPoint(x: 38 * s, y: 44 * s))
        knee.addLine(to: CGPoint(x: 40 * s, y: 38 * s))
        ctx.stroke(knee, with: .color(silhouette), style: stroke)

        // Fesse SURÉLEVÉE (bosse haute signature)
        let buttX: CGFloat = 42 * s
        let buttY: CGFloat = 34 * s
        var thigh = Path()
        thigh.move(to: CGPoint(x: 40 * s, y: 38 * s))
        thigh.addLine(to: CGPoint(x: buttX, y: buttY))
        ctx.stroke(thigh, with: .color(silhouette), style: stroke)

        // Tronc replié en arc DOS ARRONDI bien visible (quadCurve avec bosse haute)
        let shoulderX: CGFloat = 18 * s
        let shoulderY: CGFloat = 40 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: buttX, y: buttY))
        trunk.addQuadCurve(to: CGPoint(x: shoulderX, y: shoulderY),
                           control: CGPoint(x: 30 * s, y: 26 * s))   // bosse dos haute
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au sol (front touche le sol par le bas)
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 12 * s - headSize / 2, y: 42 * s - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus DEVANT le long du sol (épaule → main loin devant, écarté
        // du corps pour différenciation visuelle vs tronc arc)
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX - 2 * s, y: shoulderY + 1 * s))   // épaule
        arm.addLine(to: CGPoint(x: 12 * s, y: 45 * s))                       // coude au sol
        arm.addLine(to: CGPoint(x: 4 * s, y: 45 * s))                        // main tendue loin
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

    /// Bateau (Navasana) — refonte Story 3.23 Lot 1 (2026-05-25).
    /// Source : https://en.wikipedia.org/wiki/Navasana
    /// Signature : V franc avec sommet aux fesses (pivot bas-centre), jambes
    /// montent à droite, tronc monte à gauche, bras horizontaux séparés des jambes.
    private func drawBoat(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil, fesses pivot au sol au centre. Coords contraintes au viewbox 48×48.

        // Fesses pivot (point bas du V, au sol)
        let buttX: CGFloat = 24 * s
        let buttY: CGFloat = 42 * s

        // Jambes tendues vers le haut-droite (montée à ~55°)
        let feetX: CGFloat = 44 * s
        let feetY: CGFloat = 12 * s
        var legs = Path()
        legs.move(to: CGPoint(x: buttX, y: buttY))
        legs.addLine(to: CGPoint(x: feetX, y: feetY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Petit marqueur pied perpendiculaire à la jambe (signature cheville)
        var footMark = Path()
        footMark.move(to: CGPoint(x: feetX, y: feetY))
        footMark.addLine(to: CGPoint(x: 46 * s, y: 14 * s))
        ctx.stroke(footMark, with: .color(silhouette), style: stroke)

        // Tronc incliné vers le haut-gauche (montée symétrique ~55°)
        let shoulderX: CGFloat = 8 * s
        let shoulderY: CGFloat = 14 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: buttX, y: buttY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au bout du tronc (en haut-gauche)
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 6 * s - headSize / 2, y: 10 * s - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus quasi-horizontaux pointant vers les chevilles
        // (épaule au tronc → main qui rejoint l'aire des pieds, gap vertical
        // avec les jambes pour ne pas se confondre)
        var arms = Path()
        arms.move(to: CGPoint(x: 10 * s, y: 16 * s))
        arms.addLine(to: CGPoint(x: 38 * s, y: 14 * s))
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

    /// Dirgha pranayama — REFONDU P0 (review agent 2026-05-25) :
    /// silhouette debout VUE DE FACE avec 3 zones d'expansion respiratoire
    /// empilées verticalement (clavicules en haut, thorax au milieu, ventre en bas).
    /// Tailles croissantes du haut vers le bas symbolisent l'amplitude d'expansion
    /// (le ventre est la plus grande zone diaphragmatique).
    /// **Différenciation Ujjayi** : Dirgha = debout face avec 3 zones torse,
    /// Ujjayi = assise jambes croisées avec cercle souffle à la gorge.
    /// Réf : Iyengar "Light on Pranayama" — 3-part breath, conscience verticale
    /// des zones abdomen/thorax/clavicule.
    private func drawDirgha(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let cx: CGFloat = 40 * s
        let headSize: CGFloat = 6 * s

        // Tête (centrée)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 6 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
        // Cou
        var neck = Path()
        neck.move(to: CGPoint(x: cx, y: 12 * s))
        neck.addLine(to: CGPoint(x: cx, y: 14 * s))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Épaules (largeur du torse en haut)
        var shoulders = Path()
        shoulders.move(to: CGPoint(x: 32 * s, y: 14 * s))
        shoulders.addLine(to: CGPoint(x: 48 * s, y: 14 * s))
        ctx.stroke(shoulders, with: .color(silhouette), style: stroke)

        // Tronc — trapèze fermé (épaules larges, hanches plus étroites)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 32 * s, y: 14 * s))
        trunk.addLine(to: CGPoint(x: 35 * s, y: 38 * s))   // hanche gauche
        trunk.addLine(to: CGPoint(x: 45 * s, y: 38 * s))   // hanche droite
        trunk.addLine(to: CGPoint(x: 48 * s, y: 14 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // 2 bras le long du corps
        var armL = Path()
        armL.move(to: CGPoint(x: 32 * s, y: 14 * s))
        armL.addLine(to: CGPoint(x: 28 * s, y: 32 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: 48 * s, y: 14 * s))
        armR.addLine(to: CGPoint(x: 52 * s, y: 32 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // 2 jambes (légère séparation au sol)
        var legL = Path()
        legL.move(to: CGPoint(x: 35 * s, y: 38 * s))
        legL.addLine(to: CGPoint(x: 33 * s, y: 46 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: 45 * s, y: 38 * s))
        legR.addLine(to: CGPoint(x: 47 * s, y: 46 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Pieds
        var feet = Path()
        feet.move(to: CGPoint(x: 30 * s, y: 46 * s))
        feet.addLine(to: CGPoint(x: 36 * s, y: 46 * s))
        feet.move(to: CGPoint(x: 44 * s, y: 46 * s))
        feet.addLine(to: CGPoint(x: 50 * s, y: 46 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // === 3 zones d'expansion respiratoire EMPILÉES VERTICALEMENT ===
        // Ellipses horizontales de tailles CROISSANTES du haut vers le bas
        // (symbolise : clavicules = petite expansion, ventre = grosse expansion).
        let zoneStroke = StrokeStyle(lineWidth: 1.3 * s, lineCap: .round)

        // Zone 1 — Clavicules (en haut, petite ellipse)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 4 * s, y: 18 * s - 1 * s,
                                    width: 8 * s, height: 2 * s)),
            with: .color(annotation), style: zoneStroke
        )
        // Zone 2 — Thorax (milieu, moyenne ellipse)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 6 * s, y: 25 * s - 1 * s,
                                    width: 12 * s, height: 2 * s)),
            with: .color(annotation), style: zoneStroke
        )
        // Zone 3 — Ventre (en bas, grande ellipse)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 8 * s, y: 33 * s - 1 * s,
                                    width: 16 * s, height: 2 * s)),
            with: .color(annotation), style: zoneStroke
        )

        // Flèche d'inspiration ↓ à droite (l'air descend dans les poumons)
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var inhaleArrow = Path()
        inhaleArrow.move(to: CGPoint(x: 60 * s, y: 16 * s))
        inhaleArrow.addLine(to: CGPoint(x: 60 * s, y: 34 * s))
        inhaleArrow.move(to: CGPoint(x: 58 * s, y: 32 * s))
        inhaleArrow.addLine(to: CGPoint(x: 60 * s, y: 34 * s))
        inhaleArrow.addLine(to: CGPoint(x: 62 * s, y: 32 * s))
        ctx.stroke(inhaleArrow, with: .color(annotation), style: arrowStyle)
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
            // **REFONDU P0** — différenciation Cat-cow standard vs avant-bras :
            // avant-bras long et bien visible au sol + cercle accentuant le coude.
            // Avant-bras au sol : coude sous l'épaule, main devant.
            let elbowX: CGFloat = shoulderX
            var armUpper = Path()
            armUpper.move(to: CGPoint(x: shoulderX, y: shoulderY))
            armUpper.addLine(to: CGPoint(x: elbowX, y: 46 * s))
            ctx.stroke(armUpper, with: .color(silhouette), style: stroke)
            // Avant-bras au sol (trait épaissi pour signature)
            var forearmPath = Path()
            forearmPath.move(to: CGPoint(x: elbowX, y: 46 * s))
            forearmPath.addLine(to: CGPoint(x: handX, y: 46 * s))
            ctx.stroke(forearmPath, with: .color(silhouette),
                       style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s * 1.3, lineCap: .round))
            // Cercle accentuant le coude (signature variante avant-bras)
            let elbowSize: CGFloat = 2.5 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: elbowX - elbowSize / 2, y: 46 * s - elbowSize,
                                        width: elbowSize, height: elbowSize)),
                with: .color(silhouette), style: stroke
            )
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

        // Bras / avant-bras (idem Cat — même signature avant-bras avec cercle coude)
        if forearms {
            let elbowX: CGFloat = shoulderX
            var armUpper = Path()
            armUpper.move(to: CGPoint(x: shoulderX, y: shoulderY))
            armUpper.addLine(to: CGPoint(x: elbowX, y: 46 * s))
            ctx.stroke(armUpper, with: .color(silhouette), style: stroke)
            // Avant-bras au sol (épaissi)
            var forearmPath = Path()
            forearmPath.move(to: CGPoint(x: elbowX, y: 46 * s))
            forearmPath.addLine(to: CGPoint(x: handX, y: 46 * s))
            ctx.stroke(forearmPath, with: .color(silhouette),
                       style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s * 1.3, lineCap: .round))
            // Cercle coude
            let elbowSize: CGFloat = 2.5 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: elbowX - elbowSize / 2, y: 46 * s - elbowSize,
                                        width: elbowSize, height: elbowSize)),
                with: .color(silhouette), style: stroke
            )
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

    /// Sarvangasana (Chandelle / Shoulderstand) — refondu (review agent expert).
    /// **Signature inversion** : 2 flèches orange ↑ pieds + ↓ tête (sinon
    /// la pose ressemble à un "?", surtout pour novice qui ne connaît pas).
    /// Bras de support en V propre (épaule → coude au sol → main qui remonte
    /// sur le bas du dos), pas un Z parasite.
    /// Réf : Wikipedia Sarvangasana — "legs straightened to a vertical position,
    /// back supported by hands".
    private func drawSarvangasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 5 * s
        let headX: CGFloat = 14 * s
        let headY: CGFloat = 43 * s  // tête sur le sol

        // Tête (posée sur le sol pointillé)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Cou + épaule (épaules sur le sol, juste à droite de la tête)
        let shoulderX: CGFloat = 22 * s
        let shoulderY: CGFloat = 43 * s
        var neck = Path()
        neck.move(to: CGPoint(x: headX + headSize / 2, y: headY))
        neck.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Dos PARFAITEMENT vertical (signature chandelle)
        let hipX: CGFloat = shoulderX
        let hipY: CGFloat = 24 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambes verticales (hanche → pieds vers le haut)
        let feetX: CGFloat = hipX
        let feetY: CGFloat = 6 * s
        var legs = Path()
        legs.move(to: CGPoint(x: hipX, y: hipY))
        legs.addLine(to: CGPoint(x: feetX, y: feetY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Orteils horizontaux (signature pieds en haut)
        var toes = Path()
        toes.move(to: CGPoint(x: feetX - 3 * s, y: feetY))
        toes.addLine(to: CGPoint(x: feetX + 3 * s, y: feetY))
        ctx.stroke(toes, with: .color(silhouette), style: stroke)

        // Bras de support : V propre (épaule → coude au sol → main remontant sur le dos)
        var supportArm = Path()
        supportArm.move(to: CGPoint(x: shoulderX, y: shoulderY))
        supportArm.addLine(to: CGPoint(x: shoulderX + 5 * s, y: 44 * s))   // coude sur le sol
        supportArm.addLine(to: CGPoint(x: shoulderX + 1.5 * s, y: 34 * s)) // main remonte sur le bas du dos
        ctx.stroke(supportArm, with: .color(silhouette), style: stroke)

        // **Annotation INVERSION** : flèche orange ↑ aux pieds (signal "tête en bas")
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var feetArrow = Path()
        feetArrow.move(to: CGPoint(x: feetX + 6 * s, y: feetY + 6 * s))
        feetArrow.addLine(to: CGPoint(x: feetX + 6 * s, y: feetY))
        feetArrow.move(to: CGPoint(x: feetX + 4 * s, y: feetY + 2 * s))
        feetArrow.addLine(to: CGPoint(x: feetX + 6 * s, y: feetY))
        feetArrow.addLine(to: CGPoint(x: feetX + 8 * s, y: feetY + 2 * s))
        ctx.stroke(feetArrow, with: .color(annotation), style: arrowStyle)
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

        // Épaules au sol (droite de la tête) — sur le sol pointillé (y=44)
        let shoulderX: CGFloat = 20 * s
        let shoulderY: CGFloat = 44 * s

        // Pieds au sol côté droit
        let footX: CGFloat = 60 * s
        let footY: CGFloat = 46 * s

        // Genoux levés au-dessus des pieds
        let kneeX: CGFloat = footX - 2 * s
        let kneeY: CGFloat = 30 * s

        // Bassin (hanche) levé en pont — refonte review agent : plus haut pour
        // arc franc visible (était 26, mou) → 20.
        let hipX: CGFloat = 42 * s
        let hipY: CGFloat = 20 * s

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

        // Bras pliés posés sur les genoux (refonte review agent — signature
        // méditation Sukhasana, pas une croix). Épaule → coude descendant +
        // avant-bras horizontal posé sur le genou.
        var armL = Path()
        armL.move(to: CGPoint(x: centerX - 1 * s, y: 22 * s))    // épaule gauche
        armL.addLine(to: CGPoint(x: centerX - 8 * s, y: 32 * s)) // coude (au-dessus du genou gauche)
        armL.addLine(to: CGPoint(x: centerX - 4 * s, y: 36 * s)) // main au repos sur le genou
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 1 * s, y: 22 * s))
        armR.addLine(to: CGPoint(x: centerX + 8 * s, y: 32 * s))
        armR.addLine(to: CGPoint(x: centerX + 4 * s, y: 36 * s))
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

    /// drawMiniTadasana — silhouette debout COMPLÈTE refondue (review agent expert) :
    /// tête + cou + tronc + 2 jambes distinctes + 2 bras + 2 pieds horizontaux.
    /// Réf : Wikipedia Tadasana (Mountain Pose) — pieds joints/parallèles,
    /// bras le long du corps, posture neutre.
    private func drawMiniTadasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let cx: CGFloat = (originX + 12) * s
        let headSize: CGFloat = 4 * s

        // Tête + cou
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 8 * s, width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
        var neck = Path()
        neck.move(to: CGPoint(x: cx, y: 12 * s))
        neck.addLine(to: CGPoint(x: cx, y: 14 * s))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Tronc
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 14 * s))
        trunk.addLine(to: CGPoint(x: cx, y: 28 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // 2 jambes distinctes (V léger pour signature)
        var legL = Path()
        legL.move(to: CGPoint(x: cx, y: 28 * s))
        legL.addLine(to: CGPoint(x: cx - 1.5 * s, y: 44 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: cx, y: 28 * s))
        legR.addLine(to: CGPoint(x: cx + 1.5 * s, y: 44 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // 2 pieds horizontaux (signature pieds au sol — "pieds parallèles" Tadasana)
        var feet = Path()
        feet.move(to: CGPoint(x: cx - 3 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: cx - 0.5 * s, y: 44 * s))
        feet.move(to: CGPoint(x: cx + 0.5 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: cx + 3 * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // 2 bras le long du corps (signature posture neutre)
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 1 * s, y: 15 * s))
        armL.addLine(to: CGPoint(x: cx - 3 * s, y: 28 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 1 * s, y: 15 * s))
        armR.addLine(to: CGPoint(x: cx + 3 * s, y: 28 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// drawMiniUttanasana — pliée en deux refondue (review agent expert) :
    /// jambes verticales + tronc HORIZONTAL plongeant vers les pieds + tête près
    /// du sol + bras pendants. Anciennement le tronc et les jambes étaient
    /// superposés sur le même axe vertical (illisible).
    /// Réf : Wikipedia Uttanasana — flexion avant debout, mains vers les pieds.
    private func drawMiniUttanasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let cx: CGFloat = (originX + 12) * s
        let footY: CGFloat = 44 * s
        let hipY: CGFloat = 22 * s   // hanche en haut = pliure de la pose
        let headSize: CGFloat = 4 * s

        // Jambes verticales (pieds au sol → hanche en haut)
        var legs = Path()
        legs.move(to: CGPoint(x: cx, y: footY))
        legs.addLine(to: CGPoint(x: cx, y: hipY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Pieds horizontaux
        var feet = Path()
        feet.move(to: CGPoint(x: cx - 3 * s, y: footY))
        feet.addLine(to: CGPoint(x: cx + 3 * s, y: footY))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Tronc PLIÉ vers l'avant (hanche → épaule à l'horizontale vers la gauche)
        let shoulderX = cx - 6 * s
        let shoulderY: CGFloat = hipY + 4 * s  // tronc plonge vers le sol
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: hipY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête PRÈS DES PIEDS (au-dessus du sol, devant les tibias)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX - headSize - 1 * s, y: shoulderY + 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras pendants vers le sol depuis l'épaule
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX, y: shoulderY + 1 * s))
        arm.addLine(to: CGPoint(x: shoulderX, y: footY - 2 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// drawMiniChaturanga — planche basse refondue (review agent expert) :
    /// corps HORIZONTAL proche du sol (y=36), coudes pliés ~90° sous les épaules,
    /// pieds au sol côté droit. Anciennement les jambes plongeaient vers le sol
    /// (ressemblait à un chien tête en bas).
    /// Réf : Wikipedia Chaturanga Dandasana — planche basse, coudes près du corps.
    private func drawMiniChaturanga(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let bodyY: CGFloat = 36 * s   // corps proche du sol
        let footY: CGFloat = 38 * s
        let groundY: CGFloat = 44 * s
        let headSize: CGFloat = 4 * s

        // Tête côté gauche (regard vers le sol)
        let headCx = (originX + 4) * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headCx - headSize / 2, y: bodyY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc HORIZONTAL (épaule côté gauche → hanche côté droit)
        let shoulderX = (originX + 6) * s
        let hipX = (originX + 16) * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: shoulderX, y: bodyY))
        trunk.addLine(to: CGPoint(x: hipX, y: bodyY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambes (hanche → pied légèrement plus bas = pieds au sol)
        var legs = Path()
        legs.move(to: CGPoint(x: hipX, y: bodyY))
        legs.addLine(to: CGPoint(x: (originX + 22) * s, y: footY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Petits orteils (signature pieds au sol)
        var toes = Path()
        toes.move(to: CGPoint(x: (originX + 22) * s, y: footY))
        toes.addLine(to: CGPoint(x: (originX + 23) * s, y: groundY))
        ctx.stroke(toes, with: .color(silhouette), style: stroke)

        // Bras pliés à 90° sous les épaules (signature chaturanga)
        // épaule → coude (au sol) → main (au sol)
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX, y: bodyY + 1 * s))
        arm.addLine(to: CGPoint(x: shoulderX + 2 * s, y: groundY - 1 * s))
        arm.addLine(to: CGPoint(x: shoulderX, y: groundY))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    // MARK: - Story 3.23 Lot 2 (haute fréquence)

    /// Padangusthasana (flexion gros orteil debout) — refonte Story 3.23 Lot 2 v2.
    /// Source : https://en.wikipedia.org/wiki/Padangusthasana
    /// Signature : pli hanche net en L inversé (tronc HORIZONTAL plié, jambes
    /// verticales) + bras DESCENDANT VERTICAL séparés du corps avec mains aux orteils.
    /// Vue profil personnage face à droite (regard vers les pieds).
    private func drawPadangusthasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil. Pieds à droite, tronc plié vers la droite.
        let footX: CGFloat = 50 * s
        let footY: CGFloat = 44 * s
        let hipX: CGFloat = footX   // hanche à l'aplomb du pied (jambes verticales)
        let hipY: CGFloat = 22 * s
        let headSize: CGFloat = 6 * s

        // Pieds joints (segment horizontal au sol)
        var feet = Path()
        feet.move(to: CGPoint(x: footX - 4 * s, y: footY))
        feet.addLine(to: CGPoint(x: footX + 4 * s, y: footY))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Jambes verticales tendues (cheville → hanche)
        var legs = Path()
        legs.move(to: CGPoint(x: footX, y: footY))
        legs.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Tronc HORIZONTAL plié (hanche → épaule vers la gauche)
        // Forme un L inversé bien visible avec les jambes verticales.
        let shoulderX: CGFloat = 30 * s
        let shoulderY: CGFloat = 22 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: hipX, y: hipY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au bout du tronc (regard vers le bas)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX - headSize, y: shoulderY + 2 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus VERTICAL vers les pieds (épaule → main au pied)
        // Bien séparés du tronc pour visibilité.
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX + 4 * s, y: shoulderY + 2 * s))
        arm.addLine(to: CGPoint(x: shoulderX + 6 * s, y: 32 * s))   // coude vertical
        arm.addLine(to: CGPoint(x: hipX - 4 * s, y: footY - 2 * s)) // main au pied
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Marqueur crochet main-orteil (mini cercle signature agrippement)
        let graspSize: CGFloat = 3 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: hipX - 5.5 * s, y: footY - 3.5 * s,
                                    width: graspSize, height: graspSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Surya Namaskar B — 3 mini-poses : Tadasana → Utkatasana (chaise) → Virabhadrasana I.
    /// Source : https://en.wikipedia.org/wiki/Surya_Namaskar
    /// Signature B vs A : la chaise (Utkatasana) au centre — pas dans Surya A.
    private func drawSuryaNamaskarB(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // 3 zones côte à côte : x=[2-26] | [28-52] | [54-78] — convention Surya A.
        drawMiniTadasana(ctx, s: s, stroke: stroke, originX: 4)
        drawMiniUtkatasana(ctx, s: s, stroke: stroke, originX: 28)
        drawMiniWarrior1Mini(ctx, s: s, stroke: stroke, originX: 52)

        // 2 flèches ÉPAISSIES + remontées pour signal progression visible à
        // small size (review novice Story 3.23 Lot 1+2+3).
        let arrowStyle = StrokeStyle(lineWidth: 2 * s, lineCap: .round, lineJoin: .round)
        var arrow1 = Path()
        arrow1.move(to: CGPoint(x: 24 * s, y: 16 * s))
        arrow1.addLine(to: CGPoint(x: 28 * s, y: 16 * s))
        arrow1.move(to: CGPoint(x: 26 * s, y: 14 * s))
        arrow1.addLine(to: CGPoint(x: 28 * s, y: 16 * s))
        arrow1.addLine(to: CGPoint(x: 26 * s, y: 18 * s))
        ctx.stroke(arrow1, with: .color(annotation), style: arrowStyle)

        var arrow2 = Path()
        arrow2.move(to: CGPoint(x: 49 * s, y: 16 * s))
        arrow2.addLine(to: CGPoint(x: 53 * s, y: 16 * s))
        arrow2.move(to: CGPoint(x: 51 * s, y: 14 * s))
        arrow2.addLine(to: CGPoint(x: 53 * s, y: 16 * s))
        arrow2.addLine(to: CGPoint(x: 51 * s, y: 18 * s))
        ctx.stroke(arrow2, with: .color(annotation), style: arrowStyle)
    }

    /// drawMiniUtkatasana — chaise (genoux pliés ~45°, hanche reculée, bras au-dessus).
    private func drawMiniUtkatasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let cx: CGFloat = (originX + 12) * s
        let headSize: CGFloat = 4 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 10 * s, width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc penché légèrement avant (hanche reculée à gauche, épaule devant)
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx - 2 * s, y: 32 * s))     // hanche reculée
        trunk.addLine(to: CGPoint(x: cx, y: 14 * s))            // épaule centre
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambe (hanche reculée → genou plié vers l'avant → pied au sol)
        var leg = Path()
        leg.move(to: CGPoint(x: cx - 2 * s, y: 32 * s))
        leg.addLine(to: CGPoint(x: cx + 2 * s, y: 38 * s))     // genou plié vers l'avant
        leg.addLine(to: CGPoint(x: cx, y: 44 * s))               // pied au sol
        ctx.stroke(leg, with: .color(silhouette), style: stroke)

        // Pied horizontal
        var feet = Path()
        feet.move(to: CGPoint(x: cx - 2 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: cx + 2 * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Bras tendus HAUT au-dessus (signature chaise)
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 1 * s, y: 14 * s))
        armL.addLine(to: CGPoint(x: cx - 2 * s, y: 4 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 1 * s, y: 14 * s))
        armR.addLine(to: CGPoint(x: cx + 2 * s, y: 4 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// drawMiniWarrior1Mini — guerrier I (fente avant + bras tendus haut).
    private func drawMiniWarrior1Mini(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let cx: CGFloat = (originX + 12) * s
        let headSize: CGFloat = 4 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 10 * s, width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc droit vertical (hanche → épaule)
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 28 * s))
        trunk.addLine(to: CGPoint(x: cx, y: 14 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambe avant (pied droit avancé, genou plié au-dessus)
        var frontLeg = Path()
        frontLeg.move(to: CGPoint(x: cx, y: 28 * s))
        frontLeg.addLine(to: CGPoint(x: cx + 2 * s, y: 36 * s))
        frontLeg.addLine(to: CGPoint(x: cx + 2 * s, y: 44 * s))
        ctx.stroke(frontLeg, with: .color(silhouette), style: stroke)

        // Jambe arrière (tendue, pied reculé à gauche)
        var backLeg = Path()
        backLeg.move(to: CGPoint(x: cx, y: 28 * s))
        backLeg.addLine(to: CGPoint(x: cx - 5 * s, y: 44 * s))
        ctx.stroke(backLeg, with: .color(silhouette), style: stroke)

        // Pied arrière horizontal
        var backFoot = Path()
        backFoot.move(to: CGPoint(x: cx - 7 * s, y: 44 * s))
        backFoot.addLine(to: CGPoint(x: cx - 4 * s, y: 44 * s))
        ctx.stroke(backFoot, with: .color(silhouette), style: stroke)

        // Bras tendus haut (signature warrior I)
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 1 * s, y: 14 * s))
        armL.addLine(to: CGPoint(x: cx - 1 * s, y: 4 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 1 * s, y: 14 * s))
        armR.addLine(to: CGPoint(x: cx + 1 * s, y: 4 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// Baddha Konasana (cordonnier assis) — refonte Story 3.23 Lot 2 v2.
    /// Source : https://en.wikipedia.org/wiki/Baddha_Konasana
    /// Signature : vue de FACE + tronc DROIT vertical bien visible au-dessus
    /// d'un large losange de jambes (genoux très écartés + pieds joints centre).
    /// Refonte v2 : tête plus grosse + tronc allongé + losange élargi pour
    /// rendre "personne assise au sol" évident vs "diamant flottant".
    private func drawBaddhaKonasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue de FACE, centrée dans viewbox 80×48. Cx=40.
        let cx: CGFloat = 40 * s
        let headSize: CGFloat = 7 * s

        // Tête (légèrement plus grosse pour signal "personne")
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 8 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Cou (court segment vertical)
        var neck = Path()
        neck.move(to: CGPoint(x: cx, y: 15 * s))
        neck.addLine(to: CGPoint(x: cx, y: 18 * s))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Épaules (largeur signale "personne vue de face")
        var shoulders = Path()
        shoulders.move(to: CGPoint(x: cx - 6 * s, y: 18 * s))
        shoulders.addLine(to: CGPoint(x: cx + 6 * s, y: 18 * s))
        ctx.stroke(shoulders, with: .color(silhouette), style: stroke)

        // Tronc droit vertical bien allongé (épaule → bassin)
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 18 * s))
        trunk.addLine(to: CGPoint(x: cx, y: 36 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Hanches larges (signale base assise)
        var hips = Path()
        hips.move(to: CGPoint(x: cx - 6 * s, y: 36 * s))
        hips.addLine(to: CGPoint(x: cx + 6 * s, y: 36 * s))
        ctx.stroke(hips, with: .color(silhouette), style: stroke)

        // Pieds joints au centre (segment vertical court signature)
        var feet = Path()
        feet.move(to: CGPoint(x: cx - 1 * s, y: 40 * s))
        feet.addLine(to: CGPoint(x: cx + 1 * s, y: 40 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Jambe gauche LOSANGE LARGE : hanche → genou très écarté → pied au centre
        var legL = Path()
        legL.move(to: CGPoint(x: cx - 6 * s, y: 36 * s))
        legL.addLine(to: CGPoint(x: cx - 18 * s, y: 44 * s))    // genou écarté loin
        legL.addLine(to: CGPoint(x: cx, y: 40 * s))                // pied centre
        ctx.stroke(legL, with: .color(silhouette), style: stroke)

        // Jambe droite LOSANGE LARGE
        var legR = Path()
        legR.move(to: CGPoint(x: cx + 6 * s, y: 36 * s))
        legR.addLine(to: CGPoint(x: cx + 18 * s, y: 44 * s))
        legR.addLine(to: CGPoint(x: cx, y: 40 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Bras gauche (épaule → main qui descend vers pieds)
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 6 * s, y: 18 * s))
        armL.addLine(to: CGPoint(x: cx - 8 * s, y: 28 * s))
        armL.addLine(to: CGPoint(x: cx - 3 * s, y: 38 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        // Bras droit
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 6 * s, y: 18 * s))
        armR.addLine(to: CGPoint(x: cx + 8 * s, y: 28 * s))
        armR.addLine(to: CGPoint(x: cx + 3 * s, y: 38 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// Paschimottanasana (flexion avant assise) — refonte Story 3.23 Lot 2 v2.
    /// Source : https://en.wikipedia.org/wiki/Paschimottanasana
    /// Signature : profil + JAMBES horizontales nettes au sol + TRONC plié
    /// HORIZONTAL SÉPARÉ par un gap visible (au-dessus des jambes) + tête posée
    /// sur les genoux + bras qui descendent vers les pieds.
    private func drawPaschimottanasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil, jambes vers la droite. Centrée dans 80×48.
        let hipX: CGFloat = 12 * s
        let hipY: CGFloat = 42 * s
        let headSize: CGFloat = 6 * s

        // Hanche (point pivot, fesses assises au sol)
        // Jambes tendues horizontales au sol (hanche → genou → cheville)
        var legs = Path()
        legs.move(to: CGPoint(x: hipX, y: hipY))
        legs.addLine(to: CGPoint(x: 30 * s, y: hipY))    // genou
        legs.addLine(to: CGPoint(x: 62 * s, y: hipY))    // cheville
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Pieds (pointe vers le haut — signature flex/point)
        var feet = Path()
        feet.move(to: CGPoint(x: 62 * s, y: hipY))
        feet.addLine(to: CGPoint(x: 64 * s, y: hipY - 6 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Tronc plié horizontal SÉPARÉ DES JAMBES par gap vertical (signature
        // "buste rabattu sur jambes" — gap rend l'anatomie lisible).
        let shoulderX: CGFloat = 36 * s
        let shoulderY: CGFloat = 36 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: hipX, y: hipY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))   // tronc montant légèrement
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au bout du tronc (au-dessus des genoux signal "tête sur genoux")
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX, y: shoulderY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus qui descendent vers les pieds (épaule → main au pied)
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX, y: shoulderY + 2 * s))
        arm.addLine(to: CGPoint(x: 50 * s, y: 40 * s))
        arm.addLine(to: CGPoint(x: 60 * s, y: hipY - 2 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Marqueur main agrippe pied (mini cercle au point de jonction)
        let graspSize: CGFloat = 3 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 58.5 * s, y: hipY - 3.5 * s,
                                    width: graspSize, height: graspSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Supta Baddha Konasana (papillon allongé) — refonte Story 3.23 Lot 2 v2.
    /// Source : https://en.wikipedia.org/wiki/Supta_Baddha_Konasana
    /// Signature : silhouette de PROFIL allongée sur le dos sur ligne sol +
    /// jambes pliées en papillon (genoux tombants + pieds joints contre le bassin).
    /// Refonte v2 : passage en vue profil (et non cavalière) pour rendre la
    /// silhouette humaine clairement reconnaissable vs "cerf-volant".
    private func drawSuptaBaddhaKonasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil — corps allongé au sol, tête à gauche.
        let headX: CGFloat = 10 * s
        let headSize: CGFloat = 6 * s

        // Tête (à gauche, posée sur sol)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: 40 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Cou + tronc allongé au sol (épaule → bassin horizontal sur y=43)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 14 * s, y: 43 * s))   // épaule
        trunk.addLine(to: CGPoint(x: 40 * s, y: 43 * s)) // bassin
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Bras le long du corps (épaule → main posée près du bassin)
        var arm = Path()
        arm.move(to: CGPoint(x: 14 * s, y: 43 * s))
        arm.addLine(to: CGPoint(x: 26 * s, y: 45 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Jambes pliées en PAPILLON (signature) : du bassin, cuisses partent vers
        // le haut formant un V inversé (genoux écartés en l'air), pieds joints
        // qui reviennent au sol contre le bassin.
        // Jambe arrière (côté éloigné observateur — légèrement plus bas)
        var legL = Path()
        legL.move(to: CGPoint(x: 40 * s, y: 43 * s))
        legL.addLine(to: CGPoint(x: 50 * s, y: 28 * s))    // genou monte à gauche
        legL.addLine(to: CGPoint(x: 56 * s, y: 43 * s))    // pied collé au sol près bassin
        ctx.stroke(legL, with: .color(silhouette), style: stroke)

        // Jambe avant (côté observateur — légèrement plus à droite)
        var legR = Path()
        legR.move(to: CGPoint(x: 40 * s, y: 43 * s))
        legR.addLine(to: CGPoint(x: 56 * s, y: 28 * s))    // genou monte plus à droite
        legR.addLine(to: CGPoint(x: 60 * s, y: 43 * s))    // pied collé au sol
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Pieds joints au sol contre le bassin (marqueur "papillon allongé")
        var feet = Path()
        feet.move(to: CGPoint(x: 56 * s, y: 43 * s))
        feet.addLine(to: CGPoint(x: 60 * s, y: 43 * s))
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
