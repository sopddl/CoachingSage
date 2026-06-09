// Views/Components/Illustrations/StrengthFigureKit.swift
// Chantier refonte dessins muscu (2026-06-07) — primitives partagées des illustrations
// strength refondues (profil + variante par équipement). Centralise sol, membres, tête
// et les pièces d'équipement (barre vue en bout, barre vue de côté, haltère, kettlebell)
// pour garder les 8 dessins cohérents. Coordonnées normalisées 48×48.
import SwiftUI

enum StrengthFigureKit {
    static func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }

    /// Sol pointillé bas.
    static func ground(_ ctx: GraphicsContext, s: CGFloat, from: CGFloat = 4, to: CGFloat = 44, y: CGFloat = 44) {
        var p = Path()
        p.move(to: CGPoint(x: from * s, y: y * s))
        p.addLine(to: CGPoint(x: to * s, y: y * s))
        ctx.stroke(p, with: .color(IllustrationStyle.groundLine),
                   style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))
    }

    /// Polyligne (membre / tronc). `heavy` = trait épais (équipement).
    static func limb(_ ctx: GraphicsContext, _ pts: [CGPoint], color: Color, s: CGFloat, heavy: Bool = false) {
        guard let first = pts.first else { return }
        var p = Path()
        p.move(to: first)
        for q in pts.dropFirst() { p.addLine(to: q) }
        let w = (heavy ? IllustrationStyle.strokeWidthHeavy : IllustrationStyle.strokeWidth) * s
        ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round))
    }

    /// Tête (cercle) + cou jusqu'à l'épaule.
    static func headNeck(_ ctx: GraphicsContext, head: CGPoint, shoulder: CGPoint, color: Color, s: CGFloat, r: CGFloat = 3) {
        let rr = r * s
        // cou
        limb(ctx, [shoulder, CGPoint(x: head.x, y: head.y + rr * 0.6)], color: color, s: s)
        ctx.stroke(Path(ellipseIn: CGRect(x: head.x - rr, y: head.y - rr, width: rr * 2, height: rr * 2)),
                   with: .color(color), style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round))
    }

    /// Disque vu EN BOUT (barre perpendiculaire à la vue de profil) : stub de barre + disque plein or.
    static func barbellEndOn(_ ctx: GraphicsContext, center: CGPoint, s: CGFloat, plateR: CGFloat = 3.2, stub: CGFloat = 4) {
        limb(ctx, [CGPoint(x: center.x - stub * s, y: center.y), CGPoint(x: center.x + stub * s, y: center.y)],
             color: IllustrationStyle.equipment, s: s, heavy: true)
        let r = plateR * s
        ctx.fill(Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)),
                 with: .color(IllustrationStyle.load))
    }

    /// Barre vue DE CÔTÉ (longue horizontale) + disques aux deux bouts (deadlift/bench de profil).
    static func barbellSide(_ ctx: GraphicsContext, center: CGPoint, halfLen: CGFloat, s: CGFloat) {
        limb(ctx, [CGPoint(x: center.x - halfLen * s, y: center.y), CGPoint(x: center.x + halfLen * s, y: center.y)],
             color: IllustrationStyle.equipment, s: s, heavy: true)
        for sign in [CGFloat(-1), 1] {
            let x = center.x + sign * halfLen * s
            ctx.fill(Path(roundedRect: CGRect(x: x - 1 * s, y: center.y - 3.5 * s, width: 2 * s, height: 7 * s),
                                              cornerRadius: 0.6 * s),
                     with: .color(IllustrationStyle.load))
        }
    }

    static func dumbbell(_ ctx: GraphicsContext, center: CGPoint, s: CGFloat) {
        let w = 4.6 * s, h = 2.6 * s
        ctx.fill(Path(roundedRect: CGRect(x: center.x - w / 2, y: center.y - h / 2, width: w, height: h),
                                          cornerRadius: 0.6 * s),
                 with: .color(IllustrationStyle.load))
    }

    static func kettlebell(_ ctx: GraphicsContext, center: CGPoint, s: CGFloat) {
        let r = 3 * s
        ctx.fill(Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r + 0.8 * s, width: r * 2, height: r * 2)),
                 with: .color(IllustrationStyle.load))
        var handle = Path()
        handle.addArc(center: CGPoint(x: center.x, y: center.y - 1 * s), radius: 1.8 * s,
                      startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
        ctx.stroke(handle, with: .color(IllustrationStyle.equipment),
                   style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round))
    }

    /// Bloc plein (banc / step / box) contour équipement.
    static func box(_ ctx: GraphicsContext, rect: CGRect, s: CGFloat, filled: Bool = false) {
        let path = Path(roundedRect: rect, cornerRadius: 1 * s)
        if filled {
            ctx.fill(path, with: .color(IllustrationStyle.groundLine.opacity(0.5)))
        }
        ctx.stroke(path, with: .color(IllustrationStyle.equipment),
                   style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round))
    }
}
