// Views/Components/Illustrations/PushHorizontalIllustration.swift
// Story 3.19 Jalon 2a — pompe / bench press 3 frames vue de PROFIL.
// Story 3.23 Tier 1 Jalon 1 — ajout `exerciseName` + variante DB bench press
// (banc horizontal + corps allongé + 2 haltères) suite test simu Sophie
// 2026-05-24 (KO confirmé : "le dessin ne correspond pas"). Réf :
// https://en.wikipedia.org/wiki/Bench_press#Dumbbell_bench_press
//
// Grille didactique : mains au sol fixes (ancrage), corps qui descend/remonte
// en pompe (vs montagne russe verticale). Sol pointillé en bas.
//
// Frame 0 : position haute (bras tendus, corps droit aligné en pompe)
// Frame 1 : descente (coudes pliés à 90°)
// Frame 2 : position basse (poitrine près du sol, coudes très pliés)
import SwiftUI

struct PushHorizontalIllustration: View {
    let sportCode: String
    let frame: Int
    /// Story 3.23 — si le nom de l'exo matche "bench"/"banc"/"dumbbell bench"/
    /// "haltères couché" → rendu variante DB bench press au lieu de pompe.
    var exerciseName: String? = nil

    private var isDumbbellBench: Bool {
        guard let name = exerciseName?.lowercased() else { return false }
        return name.contains("db bench") || name.contains("dumbbell bench")
            || name.contains("haltères couché") || name.contains("halteres couche")
            || (name.contains("bench") && (name.contains("dumbbell") || name.contains("haltère") || name.contains("haltere") || name.contains("db ")))
            || (name.contains("banc") && (name.contains("haltère") || name.contains("haltere") || name.contains("dumbbell")))
    }

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)

            // Sol pointillé fixe en bas (ancrage référentiel)
            var ground = Path()
            ground.move(to: CGPoint(x: 2 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 46 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Story 3.23 — Variante DB bench press : early-return avec son propre rendu.
            if isDumbbellBench {
                drawDumbbellBench(ctx: ctx, s: s, stroke: stroke)
                return
            }

            // Mains au sol FIXES (pivot fixe pour les bras)
            let handX: CGFloat = 38 * s
            let handY: CGFloat = 46 * s

            // Pieds au sol FIXES (orteils côté gauche)
            let toeX: CGFloat = 6 * s
            let toeY: CGFloat = 46 * s

            // Position du corps selon frame
            // Hauteur du corps au-dessus du sol (épaule) :
            // Frame 0 : épaule haut (bras tendus presque verticaux)
            // Frame 1 : épaule mi-haut (coudes pliés ~90°)
            // Frame 2 : épaule basse (poitrine près du sol)
            let shoulderY: CGFloat
            switch frame {
            case 0: shoulderY = 22 * s
            case 1: shoulderY = 32 * s
            default: shoulderY = 40 * s
            }

            // Le corps est aligné en planche entre épaule et talons
            let shoulderX: CGFloat = handX - 2 * s // légèrement derrière les mains
            // hanche, genou, talon → on garde le corps droit (alignement plank)
            // Les coordonnées sont sur un AXE OBLIQUE entre épaule (handX-2, shoulderY)
            // et toe (toeX, toeY). On distribue le corps proportionnellement.

            let bodyVecX = toeX - shoulderX
            let bodyVecY = toeY - shoulderY

            // Distribution : tronc 35% / cuisse 35% / tibia 30% (le corps n'est pas
            // un segment unique, on a hanche / genou / talon comme points charnières)
            let hipX = shoulderX + bodyVecX * 0.35
            let hipY = shoulderY + bodyVecY * 0.35
            let kneeX = shoulderX + bodyVecX * 0.70
            let kneeY = shoulderY + bodyVecY * 0.70

            // Tête (cercle) au bout du tronc, à l'opposé de la hanche
            // Vecteur perpendiculaire à l'axe corps pour avoir une tête "en avant"
            let headDistance: CGFloat = 4 * s
            let bodyLen = sqrt(bodyVecX * bodyVecX + bodyVecY * bodyVecY)
            let unitX = bodyVecX / bodyLen
            let unitY = bodyVecY / bodyLen
            // Tête prolonge l'axe corps au-delà de l'épaule (côté droit)
            let headCenterX = shoulderX - unitX * headDistance
            let headCenterY = shoulderY - unitY * headDistance
            let headSize: CGFloat = 6 * s

            ctx.stroke(
                Path(ellipseIn: CGRect(x: headCenterX - headSize / 2, y: headCenterY - headSize / 2,
                                        width: headSize, height: headSize)),
                with: .color(IllustrationStyle.silhouette(sportCode: sportCode)),
                style: stroke
            )

            // Tronc (épaule → hanche)
            var trunk = Path()
            trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
            trunk.addLine(to: CGPoint(x: hipX, y: hipY))
            ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Cuisse + tibia (hanche → genou → talon)
            var legs = Path()
            legs.move(to: CGPoint(x: hipX, y: hipY))
            legs.addLine(to: CGPoint(x: kneeX, y: kneeY))
            legs.addLine(to: CGPoint(x: toeX, y: toeY))
            ctx.stroke(legs, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Bras (épaule → coude → main au sol). Le coude est plié selon
            // la distance épaule-main. En frame 2, le coude sort très vers
            // l'arrière (~horizontal au sol). En frame 0, bras presque droit.
            let armReach = handY - shoulderY // distance verticale épaule→sol
            // Plus le corps descend, plus le coude sort sur le côté (vers la droite, behind hand)
            let elbowOutset = max(0, (24 * s - armReach)) * 0.6
            let elbowX = handX + elbowOutset
            // Coude entre épaule et main, légèrement décalé vers l'extérieur
            let elbowY = (shoulderY + handY) / 2

            var arm = Path()
            arm.move(to: CGPoint(x: shoulderX, y: shoulderY))
            arm.addLine(to: CGPoint(x: elbowX, y: elbowY))
            arm.addLine(to: CGPoint(x: handX, y: handY))
            ctx.stroke(arm, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }

    /// Story 3.23 Tier 1 Jalon 1 — variante DB bench press.
    /// Banc horizontal marron (`equipment`), corps allongé sur le banc, 2 haltères
    /// tenus bras tendus verticaux. Frame 0 = haltères en haut, frame 2 = près
    /// de la poitrine. Le banc et le corps restent fixes, seuls les bras+haltères
    /// bougent (référentiel observateur).
    private func drawDumbbellBench(ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)
        let equipment = IllustrationStyle.equipment
        let load = IllustrationStyle.load

        // Banc horizontal : segment épais (équipement marron)
        let benchY: CGFloat = 30 * s
        let benchXStart: CGFloat = 10 * s
        let benchXEnd: CGFloat = 38 * s
        var bench = Path()
        bench.move(to: CGPoint(x: benchXStart, y: benchY))
        bench.addLine(to: CGPoint(x: benchXEnd, y: benchY))
        ctx.stroke(bench, with: .color(equipment),
                   style: StrokeStyle(lineWidth: 3 * s, lineCap: .round))

        // Pieds du banc (2 traits verticaux)
        var leg1 = Path()
        leg1.move(to: CGPoint(x: 12 * s, y: benchY + 1 * s))
        leg1.addLine(to: CGPoint(x: 12 * s, y: 46 * s))
        ctx.stroke(leg1, with: .color(equipment),
                   style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))
        var leg2 = Path()
        leg2.move(to: CGPoint(x: 36 * s, y: benchY + 1 * s))
        leg2.addLine(to: CGPoint(x: 36 * s, y: 46 * s))
        ctx.stroke(leg2, with: .color(equipment),
                   style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round))

        // Corps allongé sur le banc (tête à gauche → pieds qui sortent à droite)
        let headX: CGFloat = 8 * s
        let headY: CGFloat = 28 * s
        let headSize: CGFloat = 5 * s
        let shoulderX: CGFloat = 13 * s
        let shoulderY: CGFloat = 28 * s
        let hipX: CGFloat = 30 * s
        let hipY: CGFloat = 28 * s

        // Tête (cercle)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc (épaule → hanche, posé sur banc)
        var trunk = Path()
        trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Cuisses qui sortent du banc (hanche → genou plié à l'extérieur du banc)
        var thigh = Path()
        thigh.move(to: CGPoint(x: hipX, y: hipY))
        thigh.addLine(to: CGPoint(x: 40 * s, y: 34 * s))
        ctx.stroke(thigh, with: .color(silhouette), style: stroke)

        // Tibias (genou → pieds au sol)
        var shin = Path()
        shin.move(to: CGPoint(x: 40 * s, y: 34 * s))
        shin.addLine(to: CGPoint(x: 40 * s, y: 46 * s))
        ctx.stroke(shin, with: .color(silhouette), style: stroke)

        // Bras + haltères selon frame
        // Frame 0 : haltères haut (bras tendus verticaux au-dessus de la poitrine)
        // Frame 1 : à mi-hauteur (coudes pliés ~45°)
        // Frame 2 : haltères près de la poitrine (coudes très pliés, bras horizontaux)
        let dumbbellY: CGFloat
        let elbowOutset: CGFloat  // déviation latérale du coude
        switch frame {
        case 0: dumbbellY = 10 * s; elbowOutset = 1 * s
        case 1: dumbbellY = 18 * s; elbowOutset = 3 * s
        default: dumbbellY = 24 * s; elbowOutset = 5 * s
        }

        // Bras gauche (= bras visible avant en profil) : épaule → coude → haltère
        let chestX: CGFloat = 17 * s  // position bras gauche au-dessus poitrine
        let elbowYL = (shoulderY + dumbbellY) / 2
        var armL = Path()
        armL.move(to: CGPoint(x: chestX, y: shoulderY))
        armL.addLine(to: CGPoint(x: chestX - elbowOutset, y: elbowYL))
        armL.addLine(to: CGPoint(x: chestX, y: dumbbellY + 1 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        // Bras droit (légèrement décalé)
        let chestX2: CGFloat = 22 * s
        var armR = Path()
        armR.move(to: CGPoint(x: chestX2, y: shoulderY))
        armR.addLine(to: CGPoint(x: chestX2 + elbowOutset, y: elbowYL))
        armR.addLine(to: CGPoint(x: chestX2, y: dumbbellY + 1 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // 2 haltères (cercles or `load`) — disques visibles aux 2 extrémités
        let dbSize: CGFloat = 3 * s
        for dbX in [chestX, chestX2] {
            ctx.stroke(
                Path(ellipseIn: CGRect(x: dbX - dbSize / 2, y: dumbbellY - dbSize / 2,
                                        width: dbSize, height: dbSize)),
                with: .color(load),
                style: StrokeStyle(lineWidth: 1.5 * s, lineCap: .round)
            )
        }
    }
}

#if DEBUG
#Preview("PushHorizontal — pompe 3 frames") {
    HStack(spacing: 4) {
        PushHorizontalIllustration(sportCode: "strengthTraining", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PushHorizontalIllustration(sportCode: "strengthTraining", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        PushHorizontalIllustration(sportCode: "strengthTraining", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
