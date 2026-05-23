// Views/Components/Illustrations/RunEnduranceIllustration.swift
// Story 3.19 Jalon 2a — running endurance / foulée 3 frames vue de PROFIL.
// Grille didactique : sol pointillé fixe en bas. Le coureur garde sa
// position centrale (= caméra qui suit), seuls les bras / jambes alternent.
//
// Frame 0 : pied gauche au sol, pied droit en arrière
// Frame 1 : pied gauche en propulsion (talon levé), pied droit avance
// Frame 2 : pied droit au sol, pied gauche en arrière (= miroir frame 0)
import SwiftUI

struct RunEnduranceIllustration: View {
    let sportCode: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / IllustrationStyle.frameSize
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)

            // Sol pointillé fixe
            var ground = Path()
            ground.move(to: CGPoint(x: 2 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 46 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Corps de profil. Silhouette penchée légèrement vers l'avant (~5°)
            let centerX: CGFloat = 24 * s
            let headSize: CGFloat = 6 * s
            let topOfHeadY: CGFloat = 8 * s
            let shoulderY: CGFloat = topOfHeadY + headSize
            let hipY: CGFloat = 26 * s

            // Tête (légèrement décalée vers l'avant)
            ctx.stroke(
                Path(ellipseIn: CGRect(x: centerX + 1 * s - headSize / 2, y: topOfHeadY,
                                        width: headSize, height: headSize)),
                with: .color(IllustrationStyle.silhouette(sportCode: sportCode)),
                style: stroke
            )

            // Tronc légèrement penché
            var trunk = Path()
            trunk.move(to: CGPoint(x: centerX + 1 * s, y: shoulderY))
            trunk.addLine(to: CGPoint(x: centerX, y: hipY))
            ctx.stroke(trunk, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Positions jambes selon frame (foulée alternée)
            // Convention : frame 0 = jambe avant droite tendue, frame 1 = en l'air, frame 2 = inverse
            let (frontKneeX, frontKneeY, frontFootX, frontFootY,
                 backKneeX, backKneeY, backFootX, backFootY) = legPositions(s: s)

            // Jambe avant
            var frontLeg = Path()
            frontLeg.move(to: CGPoint(x: centerX, y: hipY))
            frontLeg.addLine(to: CGPoint(x: frontKneeX, y: frontKneeY))
            frontLeg.addLine(to: CGPoint(x: frontFootX, y: frontFootY))
            ctx.stroke(frontLeg, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Jambe arrière
            var backLeg = Path()
            backLeg.move(to: CGPoint(x: centerX, y: hipY))
            backLeg.addLine(to: CGPoint(x: backKneeX, y: backKneeY))
            backLeg.addLine(to: CGPoint(x: backFootX, y: backFootY))
            ctx.stroke(backLeg, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            // Bras alternés (opposés aux jambes pour équilibre)
            let (frontArmX, frontArmY, backArmX, backArmY) = armPositions(s: s)
            var frontArm = Path()
            frontArm.move(to: CGPoint(x: centerX + 2 * s, y: shoulderY + 1 * s))
            frontArm.addLine(to: CGPoint(x: frontArmX, y: frontArmY))
            ctx.stroke(frontArm, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)

            var backArm = Path()
            backArm.move(to: CGPoint(x: centerX - 1 * s, y: shoulderY + 1 * s))
            backArm.addLine(to: CGPoint(x: backArmX, y: backArmY))
            ctx.stroke(backArm, with: .color(IllustrationStyle.silhouette(sportCode: sportCode)), style: stroke)
        }
        .frame(width: IllustrationStyle.frameSize, height: IllustrationStyle.frameSize)
    }

    /// Positions jambes selon frame (avant, arrière). Foulée alternée endurance.
    private func legPositions(s: CGFloat) -> (CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat) {
        let hipX: CGFloat = 24 * s
        let hipY: CGFloat = 26 * s
        switch frame {
        case 0:
            // Pied droit (avant) attaque au sol, pied gauche (arrière) en propulsion
            return (
                hipX + 6 * s, 36 * s, hipX + 10 * s, 46 * s,   // avant : genou avancé, pied au sol
                hipX - 4 * s, 36 * s, hipX - 8 * s, 42 * s     // arrière : genou plié, pied décollé
            )
        case 1:
            // Phase d'envol : pieds en l'air, jambes croisent
            return (
                hipX + 2 * s, 34 * s, hipX + 4 * s, 38 * s,    // jambe avant pliée
                hipX - 2 * s, 38 * s, hipX - 4 * s, 44 * s     // jambe arrière reculée
            )
        default:
            // Miroir frame 0 : pied gauche au sol, pied droit en arrière
            return (
                hipX - 6 * s, 36 * s, hipX - 10 * s, 46 * s,   // jambe gauche au sol
                hipX + 4 * s, 36 * s, hipX + 8 * s, 42 * s     // jambe droite en arrière
            )
        }
    }

    /// Positions mains (avant + arrière, opposées aux jambes)
    private func armPositions(s: CGFloat) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let centerX: CGFloat = 24 * s
        switch frame {
        case 0:
            // Bras gauche avant (opposé jambe avant droite), bras droit arrière
            return (centerX - 4 * s, 24 * s, centerX + 6 * s, 30 * s)
        case 1:
            // Bras croisent (mi-foulée)
            return (centerX - 2 * s, 22 * s, centerX + 2 * s, 30 * s)
        default:
            // Miroir frame 0
            return (centerX + 4 * s, 24 * s, centerX - 6 * s, 30 * s)
        }
    }
}

#if DEBUG
#Preview("RunEndurance — foulée 3 frames") {
    HStack(spacing: 4) {
        RunEnduranceIllustration(sportCode: "running", frame: 0)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        RunEnduranceIllustration(sportCode: "running", frame: 1)
        Image(systemName: "arrow.right").foregroundStyle(IllustrationStyle.movementArrow)
        RunEnduranceIllustration(sportCode: "running", frame: 2)
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
