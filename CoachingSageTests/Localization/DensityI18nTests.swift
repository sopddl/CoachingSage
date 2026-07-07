// CoachingSageTests/Localization/DensityI18nTests.swift
// Densité B (2026-07-02) — filet i18n des surfaces user de la densité :
//   - question calibrage QActivity (3 clés : text + yes + no)
//   - bannière phrase Léon (2 clés : title + subtitle)
// Vérifie : présence FR/EN/ES via le mécanisme réel (`String.localized` →
// lproj compilés depuis le xcstrings), pas de fallback silencieux entre
// langues, et registre G7/G7bis (aucun mot banni MDR, aucune évaluation de
// capacité physique — wording purement comportemental).
import XCTest

final class DensityI18nTests: XCTestCase {

    private let fr = Locale(identifier: "fr")
    private let en = Locale(identifier: "en")
    private let es = Locale(identifier: "es")

    private static let densityKeys = [
        "questionnaire.universal.q_activity.text",
        "questionnaire.universal.q_activity.option.yes",
        "questionnaire.universal.q_activity.option.no",
        "coaching.adapter.density.banner.title",
        "coaching.adapter.density.banner.subtitle",
    ]

    private func loc(_ key: String, _ locale: Locale) -> String {
        String.localized(String.LocalizationValue(key), locale: locale)
    }

    func testAllDensityKeysResolveInAllThreeLanguages() {
        for key in Self.densityKeys {
            for locale in [fr, en, es] {
                let value = loc(key, locale)
                XCTAssertNotEqual(value, key, "Clé densité manquante en \(locale.identifier) : \(key)")
                XCTAssertFalse(value.isEmpty, "Clé densité vide en \(locale.identifier) : \(key)")
            }
        }
    }

    func testDensityKeysAreNotCrossLanguageFallbacks() {
        // Les wordings diffèrent naturellement FR/EN/ES → une égalité = langue non câblée.
        for key in Self.densityKeys {
            XCTAssertNotEqual(loc(key, fr), loc(key, en), "« \(key) » identique FR/EN")
            XCTAssertNotEqual(loc(key, es), loc(key, en), "« \(key) » identique ES/EN")
            XCTAssertNotEqual(loc(key, es), loc(key, fr), "« \(key) » identique ES/FR")
        }
    }

    /// G7/G7bis — registre comportemental strict : jamais de mot banni MDR, jamais
    /// d'évaluation de capacité/état physique (« ton corps », « niveau de forme »,
    /// « pour ton objectif »), dans AUCUNE des 3 langues.
    func testDensityWordingIsBehavioralOnly() {
        let banned: [Locale: [String]] = [
            fr: ["soin", "thérap", "traitement", "guérir", "diagnostic", "pathologie",
                 "blessure", "ton corps", "niveau de forme", "pour ton objectif", "santé"],
            en: ["therapy", "treatment", "cure", "diagnos", "pathology", "injury",
                 "your body", "fitness level", "for your goal", "health"],
            es: ["terapia", "tratamiento", "curar", "diagnós", "patología", "lesión",
                 "tu cuerpo", "nivel de forma", "para tu objetivo", "salud"],
        ]
        for key in Self.densityKeys {
            for (locale, words) in banned {
                let value = loc(key, locale).lowercased()
                for word in words {
                    XCTAssertFalse(value.contains(word),
                                   "Registre non comportemental (« \(word) ») en \(locale.identifier) dans « \(key) » : \(value)")
                }
            }
        }
    }
}
