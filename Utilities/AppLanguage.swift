// Utilities/AppLanguage.swift
// Langues de CoachingSage — type LOCAL à l'app (ne dépend PAS de
// SageCore.SupportedLanguage) pour porter l'espagnol sans modifier le package
// partagé `SageCore.git` (risque de déstabiliser GardenSage / TailorSage).
// Cf mémoire `reference_sagecore_no_touch_es_local`.
//
// Si ES doit un jour exister dans les 3 apps : remonter le case dans SageCore
// de façon COORDONNÉE (package + chrome ES des 3 apps en même temps), pas ici.
//
// Surface volontairement alignée sur `SageCore.SupportedLanguage` (rawValue =
// code ISO, CaseIterable, Identifiable, Codable, Sendable, `nativeName`,
// `init(languageCode:)`) pour rester un drop-in dans LanguageManager.
import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case french = "fr"
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }

    /// Nom de la langue dans sa propre langue.
    var nativeName: String {
        switch self {
        case .french: return "Français"
        case .english: return "English"
        case .spanish: return "Español"
        }
    }

    /// Initialise depuis un code langue (fallback → .french).
    init(languageCode: String) {
        self = AppLanguage(rawValue: languageCode) ?? .french
    }

    /// Langues exposées dans le sélecteur in-app.
    ///
    /// ⚠️ `.spanish` est volontairement ABSENT tant que le chrome UI ES
    /// (Story 0-bis, ~849 strings `Localizable.xcstrings`) et le contenu
    /// templates ES (Story B2) ne sont pas livrés — éviter une app à moitié
    /// traduite en prod. Ajouter `.spanish` ici une fois 0-bis mergée.
    static let selectable: [AppLanguage] = [.french, .english]
}
