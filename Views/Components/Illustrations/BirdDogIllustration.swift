// Views/Components/Illustrations/BirdDogIllustration.swift
// Story 3.23 Lot 3 — Bird-dog 1 frame statique, viewbox 80×48.
// Source : https://en.wikipedia.org/wiki/Bird_dog_(exercise)
// Signature : profil 4 pattes + bras avant droit tendu + jambe arrière gauche
// tendue (croisement contralatéral) + tronc horizontal parallèle au sol.
import SwiftUI

struct BirdDogIllustration: View {
    let sportCode: String

    var body: some View {
        Canvas { ctx, size in
            let sx = size.width / IllustrationStyle.staticFrameSize.width
            let sy = size.height / IllustrationStyle.staticFrameSize.height
            let s = min(sx, sy)
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)
            let silhouette = IllustrationStyle.silhouette(sportCode: sportCode)

            // Sol pointillé
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 44 * s))
            ground.addLine(to: CGPoint(x: 76 * s, y: 44 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            // Tête (devant les épaules, regard vers le sol-avant)
            let headSize: CGFloat = 6 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: 50 * s - headSize / 2, y: 23 * s,
                                        width: headSize, height: headSize)),
                with: .color(silhouette), style: stroke
            )

            // Tronc horizontal parallèle au sol (épaule → bassin)
            var trunk = Path()
            trunk.move(to: CGPoint(x: 28 * s, y: 28 * s))     // bassin
            trunk.addLine(to: CGPoint(x: 44 * s, y: 28 * s))  // épaule
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Bras d'appui (épaule → coude → paume au sol)
            var supportArm = Path()
            supportArm.move(to: CGPoint(x: 45 * s, y: 28 * s))
            supportArm.addLine(to: CGPoint(x: 45 * s, y: 44 * s))
            ctx.stroke(supportArm, with: .color(silhouette), style: stroke)
            // Main au sol (petit segment horizontal)
            var supportHand = Path()
            supportHand.move(to: CGPoint(x: 43 * s, y: 44 * s))
            supportHand.addLine(to: CGPoint(x: 47 * s, y: 44 * s))
            ctx.stroke(supportHand, with: .color(silhouette), style: stroke)

            // Bras TENDU avant droit (signature — horizontal vers la droite)
            var frontArm = Path()
            frontArm.move(to: CGPoint(x: 43 * s, y: 28 * s))
            frontArm.addLine(to: CGPoint(x: 66 * s, y: 28 * s))
            ctx.stroke(frontArm, with: .color(silhouette), style: stroke)

            // Genou d'appui (bassin → genou → tibia au sol)
            var supportLeg = Path()
            supportLeg.move(to: CGPoint(x: 29 * s, y: 28 * s))
            supportLeg.addLine(to: CGPoint(x: 29 * s, y: 44 * s))
            ctx.stroke(supportLeg, with: .color(silhouette), style: stroke)
            // Pied/tibia replié au sol (petit segment horizontal)
            var supportFoot = Path()
            supportFoot.move(to: CGPoint(x: 27 * s, y: 44 * s))
            supportFoot.addLine(to: CGPoint(x: 33 * s, y: 44 * s))
            ctx.stroke(supportFoot, with: .color(silhouette), style: stroke)

            // Jambe TENDUE arrière gauche (signature — horizontal vers la gauche)
            var backLeg = Path()
            backLeg.move(to: CGPoint(x: 27 * s, y: 28 * s))
            backLeg.addLine(to: CGPoint(x: 8 * s, y: 28 * s))
            ctx.stroke(backLeg, with: .color(silhouette), style: stroke)
            // Pied flexion plantaire arrière
            var backFoot = Path()
            backFoot.move(to: CGPoint(x: 8 * s, y: 28 * s))
            backFoot.addLine(to: CGPoint(x: 6 * s, y: 26 * s))
            ctx.stroke(backFoot, with: .color(silhouette), style: stroke)

            // Annotations flèches orange aux extrémités (extension active)
            var arrowFront = Path()
            arrowFront.move(to: CGPoint(x: 60 * s, y: 24 * s))
            arrowFront.addLine(to: CGPoint(x: 66 * s, y: 24 * s))
            arrowFront.move(to: CGPoint(x: 64 * s, y: 22 * s))
            arrowFront.addLine(to: CGPoint(x: 66 * s, y: 24 * s))
            arrowFront.addLine(to: CGPoint(x: 64 * s, y: 26 * s))
            ctx.stroke(arrowFront, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round))

            var arrowBack = Path()
            arrowBack.move(to: CGPoint(x: 14 * s, y: 24 * s))
            arrowBack.addLine(to: CGPoint(x: 8 * s, y: 24 * s))
            arrowBack.move(to: CGPoint(x: 10 * s, y: 22 * s))
            arrowBack.addLine(to: CGPoint(x: 8 * s, y: 24 * s))
            arrowBack.addLine(to: CGPoint(x: 10 * s, y: 26 * s))
            ctx.stroke(arrowBack, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round))
        }
        .frame(width: IllustrationStyle.staticFrameSize.width,
               height: IllustrationStyle.staticFrameSize.height)
    }
}

#if DEBUG
#Preview("Bird-dog — gainage diagonal") {
    BirdDogIllustration(sportCode: "strengthTraining")
        .padding()
        .background(Color.coachingBackground)
}
#endif
