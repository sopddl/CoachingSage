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
    /// ✅ `.spanish` activé le 2026-06-14 : contenu templates ES (B2 + passes
    /// qualité #2c/#2d) ET chrome UI ES (0-bis, 776 strings) livrés. ES couvert
    /// 894/921 (reste = trous de contenu toutes langues, fallback FR propre).
    static let selectable: [AppLanguage] = [.french, .english, .spanish]
}
