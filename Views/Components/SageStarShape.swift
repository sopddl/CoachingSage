// Views/Components/SageStarShape.swift
// Étoile à 8 branches asymétriques signature « Sages » — réutilisée dans le badge
// AppIcon GardenSage / TailorSage / CoachingSage et dans les FABs (FloreFAB,
// CocoFAB, LeonFAB). 4 grandes pointes cardinales (haut/droite/bas/gauche) +
// 4 petites diagonales pinceuses entre.
//
// Geometry du SVG d'origine (cf `GardenSage/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-Light.svg`) :
//   `M0 -55 L2 -7 L55 0 L2 7 L0 55 L-2 7 L-55 0 L-2 -7 Z`
// → ratio shortX = 2/55 ≈ 0.036, shortY = 7/55 ≈ 0.127, longArm = 1.0.
import SwiftUI

struct SageStarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        let R = min(rect.width, rect.height) / 2
        let shortX = R * (2.0 / 55.0)
        let shortY = R * (7.0 / 55.0)

        let points: [(CGFloat, CGFloat)] = [
            (0, -R),         // pointe haut
            (shortX, -shortY),
            (R, 0),          // pointe droite
            (shortX, shortY),
            (0, R),          // pointe bas
            (-shortX, shortY),
            (-R, 0),         // pointe gauche
            (-shortX, -shortY)
        ]

        var path = Path()
        path.move(to: CGPoint(x: cx + points[0].0, y: cy + points[0].1))
        for i in 1..<points.count {
            path.addLine(to: CGPoint(x: cx + points[i].0, y: cy + points[i].1))
        }
        path.closeSubpath()
        return path
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 24) {
        SageStarShape()
            .fill(Color.coachingSageStar)
            .frame(width: 64, height: 64)
        SageStarShape()
            .fill(Color.coachingRecord)
            .frame(width: 32, height: 32)
        SageStarShape()
            .fill(Color.white)
            .frame(width: 16, height: 16)
            .background(Color.coachingPrimary)
    }
    .padding()
    .background(Color.coachingSand)
}
#endif
