// Views/Components/IllustrationStyle.swift
// Story 3.19 — constants stylistiques pour les illustrations exo (`ExercisePatternIllustration`
// + 16 illus individuelles). Centralise stroke widths et accesseurs couleur sport-aware.
// Aucune couleur custom — uniquement les tokens existants `Color+Coaching.swift`.
import SwiftUI

enum IllustrationStyle {
    /// Stroke standard pour silhouette / lignes structurelles.
    static let strokeWidth: CGFloat = 2.5
    /// Stroke épais pour charges / haltères (poids visuel + lisibilité).
    static let strokeWidthHeavy: CGFloat = 4.0
    /// Stroke fin pour annotations isométriques + flèches mouvement.
    static let strokeWidthThin: CGFloat = 1.5

    /// Viewbox standard d'une frame (carré).
    static let frameSize: CGFloat = 48
    /// Viewbox d'une illu statique avec annotations à droite.
    static let staticFrameSize = CGSize(width: 80, height: 48)

    /// Espace entre frames du strip.
    static let frameSpacing: CGFloat = 4

    /// Taille de la flèche entre 2 frames du storyboard.
    static let arrowSize: CGFloat = 10

    /// Silhouette / corps : encre unique pour toute la famille « schéma didactique »
    /// (harmonisation 2026-07-16, décision Sophie « deux familles cohérentes ») —
    /// l'ancienne couleur signature du sport (violet yoga, marron muscu…) faisait
    /// patchwork à côté des assets pictos-rig. `coachingEarth` = le même bleu nuit
    /// que l'équipement et que les pantalons/cheveux du perso des assets.
    static func silhouette(sportCode: String) -> Color {
        _ = sportCode  // signature conservée (16 vues appelantes), teinte désormais unique
        return .coachingEarth
    }

    /// Fond de la carte illustration, aligné sur le fond EMBARQUÉ dans les PNG
    /// pictos-rig (mesuré : beige ~(216,204,191) côté yoga, gris-mauve
    /// ~(180,169,175) côté muscu) — les assets fusionnent avec la carte au lieu
    /// de flotter en carré beige sur du gris système, et les dessins Canvas
    /// héritent du même fond → une seule famille visuelle.
    static func cardBackground(forCode code: String) -> Color {
        switch code.lowercased() {
        case "yoga", "mobility", "stretching":
            return Color(red: 216 / 255, green: 204 / 255, blue: 191 / 255)
        default:
            return Color(red: 180 / 255, green: 169 / 255, blue: 175 / 255)
        }
    }

    /// Barre / équipement fixe (barre de squat, barre de traction).
    static let equipment: Color = .coachingEarth

    /// Charges / haltères (disques squat, haltères RDL).
    static let load: Color = .coachingRecord

    /// Flèches mouvement (frame retour, indication direction).
    static let movementArrow: Color = .coachingWarning

    /// Sol / lignes alignement / annotations isométriques (gris 50% opacity).
    static var groundLine: Color { .coachingTextSecondary.opacity(0.5) }
}
