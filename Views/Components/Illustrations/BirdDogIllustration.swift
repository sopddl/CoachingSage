// Views/Components/Illustrations/BirdDogIllustration.swift
// Story 3.23 Lot 3 — Bird-dog 1 frame statique, viewbox 80×48.
// Source : https://en.wikipedia.org/wiki/Bird_dog_(exercise)
// Signature : profil 4 pattes + bras avant droit tendu + jambe arrière gauche
// tendue (croisement contralatéral) + tronc horizontal parallèle au sol.
import SwiftUI

struct BirdDogIllustration: View {
    let sportCode: String
    var size: CGFloat = IllustrationStyle.staticFrameSize.height // revue 2026-06-08 : scale (cf yoga)

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

            // Revue experte pictos 2026-06-08 : VUE 3/4 (pas profil). Signature qui débloque =
            // les 2 APPUIS qui pendent au sol (main avant + genou arrière) → « à 4 pattes »,
            // puis bras-avant + jambe-arrière étendus en DIAGONALE, décalés côtés opposés (≠ étoile).
            let shoulder = CGPoint(x: 30 * s, y: 22 * s)
            let hip = CGPoint(x: 50 * s, y: 24 * s)

            // Tronc court (raccourci par la perspective 3/4), dos plat
            var trunk = Path()
            trunk.move(to: shoulder)
            trunk.addLine(to: hip)
            ctx.stroke(trunk, with: .color(silhouette), style: stroke)

            // Tête à l'AVANT du tronc (gauche), regard sol
            let headSize: CGFloat = 6 * s
            let headC = CGPoint(x: 24 * s, y: 19 * s)
            ctx.stroke(Path(ellipseIn: CGRect(x: headC.x - headSize / 2, y: headC.y - headSize / 2,
                                              width: headSize, height: headSize)),
                       with: .color(silhouette), style: stroke)

            // APPUI 1 — bras d'appui (sous l'épaule) descend VERTICAL au sol + main
            var supportArm = Path()
            supportArm.move(to: shoulder)
            supportArm.addLine(to: CGPoint(x: 30 * s, y: 42 * s))
            ctx.stroke(supportArm, with: .color(silhouette), style: stroke)
            var supportHand = Path()
            supportHand.move(to: CGPoint(x: 27 * s, y: 42 * s)); supportHand.addLine(to: CGPoint(x: 33 * s, y: 42 * s))
            ctx.stroke(supportHand, with: .color(silhouette), style: stroke)

            // APPUI 2 — genou d'appui (sous la hanche) descend VERTICAL au sol + tibia
            var supportLeg = Path()
            supportLeg.move(to: hip)
            supportLeg.addLine(to: CGPoint(x: 51 * s, y: 42 * s))
            ctx.stroke(supportLeg, with: .color(silhouette), style: stroke)
            var supportShin = Path()
            supportShin.move(to: CGPoint(x: 48 * s, y: 42 * s)); supportShin.addLine(to: CGPoint(x: 54 * s, y: 42 * s))
            ctx.stroke(supportShin, with: .color(silhouette), style: stroke)

            // EXTENSION — bras AVANT (depuis l'épaule, vers l'avant-haut, aligné dos→bras) ;
            // léger décalage bas = côté opposé à la jambe (3/4).
            var frontArm = Path()
            frontArm.move(to: shoulder)
            frontArm.addLine(to: CGPoint(x: 8 * s, y: 20 * s))
            ctx.stroke(frontArm, with: .color(silhouette), style: stroke)

            // EXTENSION — jambe ARRIÈRE (depuis la hanche, vers l'arrière-haut) ; léger décalage haut.
            var backLeg = Path()
            backLeg.move(to: hip)
            backLeg.addLine(to: CGPoint(x: 73 * s, y: 16 * s))
            ctx.stroke(backLeg, with: .color(silhouette), style: stroke)

            // Flèches d'extension (avant-bas-gauche, arrière-haut-droite)
            var arrowFront = Path()
            arrowFront.move(to: CGPoint(x: 5 * s, y: 19 * s)); arrowFront.addLine(to: CGPoint(x: 9 * s, y: 19 * s))
            arrowFront.move(to: CGPoint(x: 5 * s, y: 19 * s)); arrowFront.addLine(to: CGPoint(x: 5 * s, y: 23 * s))
            ctx.stroke(arrowFront, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
            var arrowBack = Path()
            arrowBack.move(to: CGPoint(x: 75 * s, y: 15 * s)); arrowBack.addLine(to: CGPoint(x: 71 * s, y: 15 * s))
            arrowBack.move(to: CGPoint(x: 75 * s, y: 15 * s)); arrowBack.addLine(to: CGPoint(x: 75 * s, y: 19 * s))
            ctx.stroke(arrowBack, with: .color(IllustrationStyle.movementArrow),
                       style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
        }
        .frame(width: size * (IllustrationStyle.staticFrameSize.width / IllustrationStyle.staticFrameSize.height),
               height: size)
    }
}

#if DEBUG
#Preview("Bird-dog — gainage diagonal") {
    BirdDogIllustration(sportCode: "strengthTraining")
        .padding()
        .background(Color.coachingBackground)
}
#endif
