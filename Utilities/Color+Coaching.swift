// Utilities/Color+Coaching.swift
// Design tokens couleur CoachingSage — Story 1.2 palette finale.
// Source : ux-design-CoachingSage-direction-finale.html + palette.html.
// Light-only pour l'instant ; dark mode = migration vers Assets.xcassets (1 fichier à toucher).
import SwiftUI

extension Color {

    // MARK: - Couleur signature
    /// #1E5090 — Bleu coach Léon, action principale, icône app.
    /// Identique à `coachingLeon` : cohérence app+assistant (cf. Flore/GardenSage et Coco/TailorSage).
    static let coachingPrimary = Color(hex: 0x1E5090)

    /// #7BC142 — Vert lime électrique, CTA "GO!" (démarrer séance, valider).
    static let coachingAccent = Color(hex: 0x7BC142)

    /// #1B3A5C — Bleu marine profondeur, éléments secondaires (ex-primary).
    static let coachingEarth = Color(hex: 0x1B3A5C)

    // MARK: - Texte
    /// #141E2B — Bleu nuit, texte principal sur fonds clairs.
    static let coachingTextPrimary = Color(hex: 0x141E2B)
    /// #5A6577 — Gris ardoise, texte secondaire.
    static let coachingTextSecondary = Color(hex: 0x5A6577)
    /// #FFFFFF — Texte / icônes sur fond `coachingPrimary` (bleu marine).
    static let coachingOnPrimary = Color.white

    // MARK: - Fonds
    /// #F5F2EE — Blanc sport, fond principal.
    static let coachingBackground = Color(hex: 0xF5F2EE)
    /// #EDE9E3 — Ivoire clair, cartes / conteneurs.
    static let coachingCard = Color(hex: 0xEDE9E3)

    // MARK: - États sémantiques
    /// #2D8A4E — Vert victoire / validation.
    static let coachingSuccess = Color(hex: 0x2D8A4E)
    /// #D4A85A — Or record / performance notable.
    static let coachingRecord = Color(hex: 0xD4A85A)
    static let coachingError = Color(hex: 0xC43D3D)
    static let coachingWarning = Color(hex: 0xE08A3A)
    static let coachingDisabled = Color(hex: 0x9AA0A8)

    // MARK: - Signature assistant Léon
    /// #1E5090 — Bleu coach IA, bulle / avatar Léon.
    static let coachingLeon = Color(hex: 0x1E5090)
    /// #E8F0FA — Blanc bleuté, texte sur bulle Léon.
    static let coachingLeonText = Color(hex: 0xE8F0FA)
}

extension Color {
    /// Initialisation depuis un entier RGB 0xRRGGBB (sRGB).
    fileprivate init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
