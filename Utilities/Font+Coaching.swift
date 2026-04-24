// Utilities/Font+Coaching.swift
// Échelle typographique CoachingSage — Story 1.2.
// SF Pro rounded pour les titres (ton sport, cohérence iOS natif, zéro asset embarqué) ;
// serif italic pour la voix de Léon.
import SwiftUI
import UIKit

extension Font {

    private static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    /// Titre héroïque — écrans principaux
    static var coachingDisplay: Font {
        .system(size: isIPad ? 34 : 28, weight: .bold, design: .rounded)
    }

    /// Titre de section principale
    static var coachingH1: Font {
        .system(size: isIPad ? 26 : 22, weight: .semibold, design: .rounded)
    }

    /// Sous-titres, labels secondaires (utilisé dans PrimaryButtonStyle)
    static var coachingH2: Font {
        .system(size: isIPad ? 21 : 18, weight: .semibold, design: .default)
    }

    /// Corps de texte standard
    static var coachingBody: Font {
        .system(size: isIPad ? 18 : 15, weight: .regular, design: .default)
    }

    /// Légendes, métadonnées
    static var coachingCaption: Font {
        .system(size: isIPad ? 15 : 13, weight: .regular, design: .default)
    }

    /// Voix de Léon — messages conversationnels
    static var coachingLeon: Font {
        .system(size: isIPad ? 19 : 16, weight: .regular, design: .serif).italic()
    }
}
