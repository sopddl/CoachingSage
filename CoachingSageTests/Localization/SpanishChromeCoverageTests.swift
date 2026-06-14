// CoachingSageTests/Localization/SpanishChromeCoverageTests.swift
// Passe qualité chrome ES (0-bis, 2026-06-14) — filet de régression : vérifie que
// les strings d'INTERFACE (chrome) se résolvent bien en espagnol via le mécanisme
// réel `LanguageManager.localized(_:locale:)` → es.lproj compilé depuis le
// xcstrings. Golden sur un échantillon représentatif + garde-fou « ES ≠ FR »
// (prouve que la localisation ES est câblée, pas un fallback FR silencieux).
//
// 776 clés traduites (#chrome-es). Restent 27 trous de contenu TOUTES LANGUES
// (coaching.tip.*, profile.personalData.*.label — vides même en FR), hors scope.
import XCTest

final class SpanishChromeCoverageTests: XCTestCase {

    private let es = Locale(identifier: "es")
    private let fr = Locale(identifier: "fr")

    private func loc(_ key: String, _ locale: Locale) -> String {
        String.localized(String.LocalizationValue(key), locale: locale)
    }

    /// Golden : un échantillon de clés chrome doit rendre exactement l'ES attendu.
    func testChromeKeysRenderExpectedSpanish() {
        let golden: [String: String] = [
            "tab.session": "Inicio",
            "tab.progress": "Progreso",
            "tab.profile": "Perfil",
            "auth.signIn": "Iniciar sesión",
            "common.cancel": "Cancelar",
            "session.type.strength": "Refuerzo",
            "profile.disclaimer.title": "Aviso médico",
        ]
        for (key, expected) in golden {
            XCTAssertEqual(loc(key, es), expected, "Chrome ES cassé pour « \(key) »")
        }
    }

    /// Garde-fou câblage : ces clés (FR ≠ EN ≠ ES naturellement) NE doivent PAS
    /// retomber sur le FR sous locale ES → preuve que es.lproj est chargé.
    func testSpanishChromeIsNotFrenchFallback() {
        for key in ["tab.session", "auth.signIn", "common.cancel", "profile.disclaimer.title"] {
            XCTAssertNotEqual(loc(key, es), loc(key, fr),
                              "« \(key) » identique FR/ES → ES non câblé (fallback FR)")
        }
    }
}
