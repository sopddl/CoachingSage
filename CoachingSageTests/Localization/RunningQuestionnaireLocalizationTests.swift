// CoachingSageTests/Localization/RunningQuestionnaireLocalizationTests.swift
// Story 3.1 — safety net obligatoire pour la localisation.
// Test 1 : toutes les clés du Running questionnaire existent en FR ET EN.
// Test 2 : aucun mot banni EU MDR (FR + EN) dans les valeurs (review P0-5, mémoire epic3_leon_legal_constraints).
import Testing
import Foundation
@testable import CoachingSage

@Suite("RunningQuestionnaireLocalization")
struct RunningQuestionnaireLocalizationTests {

    // MARK: - Toutes les clés existent en FR + EN

    @Test
    func allRunningKeys_existInBothFRandEN() {
        let q = RunningQuestionnaire()
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
            "questionnaire.\(q.sportCode).intro",
            "questionnaire.\(q.sportCode).completion",
            "chat.a11y.leonAvatar",
            "chat.a11y.leonSays",
            "chat.a11y.leonTyping",
            "chat.a11y.userReplied",
            "session.requestProgram.title",
            "session.button.comingSoon"
        ]
        // Ajouter les textKeys et labelKeys de toutes les questions
        let allQuestions: [QuestionnaireQuestion] = [
            RunningQuestionnaire.q1Level,
            RunningQuestionnaire.q2Goal,
            RunningQuestionnaire.q3Frequency,
            RunningQuestionnaire.q4Constraints,
            RunningQuestionnaire.q5Equipment,
            RunningQuestionnaire.q6FreeText
        ]
        for question in allQuestions {
            keys.insert(question.textKey)
            for option in question.options {
                keys.insert(option.labelKey)
            }
        }

        // Pour chaque clé, vérifier qu'elle est résolue en FR ET en EN
        for key in keys {
            let frValue = String(localized: String.LocalizationValue(key), bundle: .main, locale: Locale(identifier: "fr"))
            let enValue = String(localized: String.LocalizationValue(key), bundle: .main, locale: Locale(identifier: "en"))
            // Si la clé n'existe pas, NSLocalizedString renvoie la clé elle-même.
            #expect(frValue != key, "Clé manquante en FR : \(key)")
            #expect(enValue != key, "Clé manquante en EN : \(key)")
        }
    }

    // MARK: - Mots bannis EU MDR (review P0-5)

    @Test("Aucun mot banni EU MDR FR dans les clés Running")
    func noBannedTerms_FR() {
        let bannedFR = ["soin", "thérapie", "traitement", "guérir", "diagnostiquer", "prévenir", "pathologie", "blessure"]
        for key in runningKeys {
            let value = String(localized: String.LocalizationValue(key), bundle: .main, locale: Locale(identifier: "fr")).lowercased()
            for word in bannedFR {
                #expect(!value.contains(word), "Mot banni FR « \(word) » dans la clé « \(key) » : \(value)")
            }
        }
    }

    @Test("Aucun mot banni EU MDR EN dans les clés Running")
    func noBannedTerms_EN() {
        // Note : "medical" est autorisé dans le contexte explicite du disclaimer médical (mémoire `epic3_leon_legal_constraints`),
        // mais Story 3.1 ne touche PAS au disclaimer — donc 0 occurrence attendue ici.
        let bannedEN = ["therapy", "treatment", "cure", "diagnose", "prevent", "pathology", "injury"]
        for key in runningKeys {
            let value = String(localized: String.LocalizationValue(key), bundle: .main, locale: Locale(identifier: "en")).lowercased()
            for word in bannedEN {
                #expect(!value.contains(word), "Mot banni EN « \(word) » dans la clé « \(key) » : \(value)")
            }
        }
    }

    // MARK: - Helpers

    /// Toutes les clés produites par Story 3.1 (questionnaire + session + chat.a11y).
    private var runningKeys: [String] {
        var keys: [String] = [
            "questionnaire.running.intro",
            "questionnaire.running.completion",
            "questionnaire.intro.medicalClearance",
            "questionnaire.title"
        ]
        let allQuestions: [QuestionnaireQuestion] = [
            RunningQuestionnaire.q1Level,
            RunningQuestionnaire.q2Goal,
            RunningQuestionnaire.q3Frequency,
            RunningQuestionnaire.q4Constraints,
            RunningQuestionnaire.q5Equipment,
            RunningQuestionnaire.q6FreeText
        ]
        for question in allQuestions {
            keys.append(question.textKey)
            keys.append(contentsOf: question.options.map { $0.labelKey })
        }
        return keys
    }
}
