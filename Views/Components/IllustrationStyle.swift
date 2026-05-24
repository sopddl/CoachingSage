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

    /// Silhouette / corps : couleur signature du sport (`coachingSport(forCode:)`).
    /// Fallback `coachingTextSecondary` géré par l'helper existant.
    static func silhouette(sportCode: String) -> Color {
        Color.coachingSport(forCode: sportCode)
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
