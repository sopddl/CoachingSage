// CoachingSageTests/Localization/UniversalQuestionnaireLocalizationTests.swift
// Phase 2 #5 — safety net localisation pour le questionnaire universel + 10 sports.
// Test 1 : toutes les clés (universal + Q2 sport-specific) résolvent en FR ET EN.
// Test 2 : aucun mot banni EU MDR (FR + EN) dans les valeurs (mémoire epic3_leon_legal_constraints).
import Testing
import Foundation

/// Marker ObjC class pour récupérer le bundle du test target en logic test mode
/// (sans TEST_HOST, `Bundle.main` = le binary xctest agent, pas le `.xctest`
/// bundle qui contient les `Localizable.xcstrings`).
private final class _LocalizationTestBundleLocator: NSObject {}

@Suite("UniversalQuestionnaireLocalization")
struct UniversalQuestionnaireLocalizationTests {

    private let allSportCodes: [String] = SportCode.allCases.map { $0.rawValue }
    private static let testBundle = Bundle(for: _LocalizationTestBundleLocator.self)

    // MARK: - Toutes les clés existent en FR + EN

    @Test
    func allUniversalKeys_existInBothFRandEN() {
        var keys: Set<String> = [
            "questionnaire.title",
            "questionnaire.intro.medicalClearance",
            "questionnaire.exit.confirm.title",
            "questionnaire.exit.confirm.message",
            "questionnaire.exit.confirm.action",
            "questionnaire.exit.cancel",
            "questionnaire.error.save.title",
            "questionnaire.error.save.retry",
            "questionnaire.error.userChanged",
            "questionnaire.options.confirm",
            "questionnaire.options.continue",
            "questionnaire.recovery.prompt",
            "questionnaire.recovery.resume",
            "questionnaire.recovery.restart",
            "questionnaire.universal.intro",
            "questionnaire.universal.completion",
            "chat.a11y.leonAvatar",
            "chat.a11y.leonSays",
            "chat.a11y.leonTyping",
            "chat.a11y.userReplied",
            "session.requestProgram.title"
        ]

        // Q1 universel (level) + Q3 universel (frequency) — communs aux 10 sports.
        keys.insert(UniversalQuestionnaire.q1Level.textKey)
        for option in UniversalQuestionnaire.q1Level.options { keys.insert(option.labelKey) }
        keys.insert(UniversalQuestionnaire.q3Frequency.textKey)
        for option in UniversalQuestionnaire.q3Frequency.options { keys.insert(option.labelKey) }

        // QActivity calibrage densité (densité B, 2026-07-02) — conditionnelle cold-start.
        keys.insert(UniversalQuestionnaire.qActivity.textKey)
        for option in UniversalQuestionnaire.qActivity.options { keys.insert(option.labelKey) }

        // Q2 par sport — sport-specific.
        for code in allSportCodes {
            let q = UniversalQuestionnaire(sportCode: code).q2Goal
            keys.insert(q.textKey)
            for option in q.options { keys.insert(option.labelKey) }
        }

        for key in keys {
            let frValue = String(localized: String.LocalizationValue(key), bundle: Self.testBundle, locale: Locale(identifier: "fr"))
            let enValue = String(localized: String.LocalizationValue(key), bundle: Self.testBundle, locale: Locale(identifier: "en"))
            #expect(frValue != key, "Clé manquante en FR : \(key)")
            #expect(enValue != key, "Clé manquante en EN : \(key)")
        }
    }

    // MARK: - Mots bannis EU MDR

    @Test("Aucun mot banni EU MDR FR dans les clés universal + Q2 par sport")
    func noBannedTerms_FR() {
        let bannedFR = ["soin", "thérapie", "traitement", "guérir", "diagnostiquer", "prévenir", "pathologie", "blessure"]
        for key in collectAllKeys() {
            let value = String(localized: String.LocalizationValue(key), bundle: Self.testBundle, locale: Locale(identifier: "fr")).lowercased()
            for word in bannedFR {
                #expect(!value.contains(word), "Mot banni FR « \(word) » dans la clé « \(key) » : \(value)")
            }
        }
    }

    @Test("Aucun mot banni EU MDR EN dans les clés universal + Q2 par sport")
    func noBannedTerms_EN() {
        let bannedEN = ["therapy", "treatment", "cure", "diagnose", "prevent", "pathology", "injury"]
        for key in collectAllKeys() {
            let value = String(localized: String.LocalizationValue(key), bundle: Self.testBundle, locale: Locale(identifier: "en")).lowercased()
            for word in bannedEN {
                #expect(!value.contains(word), "Mot banni EN « \(word) » dans la clé « \(key) » : \(value)")
            }
        }
    }

    // MARK: - Helpers

    private func collectAllKeys() -> [String] {
        var keys: [String] = [
            "questionnaire.universal.intro",
            "questionnaire.universal.completion",
            "questionnaire.intro.medicalClearance",
            "questionnaire.title",
            UniversalQuestionnaire.q1Level.textKey,
            UniversalQuestionnaire.q3Frequency.textKey,
            UniversalQuestionnaire.qActivity.textKey
        ]
        keys.append(contentsOf: UniversalQuestionnaire.q1Level.options.map { $0.labelKey })
        keys.append(contentsOf: UniversalQuestionnaire.q3Frequency.options.map { $0.labelKey })
        keys.append(contentsOf: UniversalQuestionnaire.qActivity.options.map { $0.labelKey })
        for code in allSportCodes {
            let q = UniversalQuestionnaire(sportCode: code).q2Goal
            keys.append(q.textKey)
            keys.append(contentsOf: q.options.map { $0.labelKey })
        }
        return keys
    }
}
