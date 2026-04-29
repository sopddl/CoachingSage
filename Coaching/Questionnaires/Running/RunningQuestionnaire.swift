// Coaching/Questionnaires/Running/RunningQuestionnaire.swift
// Story 3.1 — sport pilote, 6 questions (Q1-Q5 closed + Q6 freeText optionnel).
// Branchement conditionnel : Q4 skippée si Q1=beginner (pas pertinent au démarrage — review P0-6 / AC5).
// Aucun switch FR/EN, aucun LocalizedStringKey ici (mémoire `multilangue_extensible_regle`, review P0-1).
// Tous les textes sont des clés xcstrings résolues côté View via Text(LocalizedStringKey(textKey)).
import Foundation

struct RunningQuestionnaire: SportQuestionnaire {

    let sportCode: String = "running"
    let version: String = "running_v1"

    // MARK: - Questions

    static let q1Level = QuestionnaireQuestion(
        id: "q1_level",
        textKey: "questionnaire.running.q1.text",
        answerType: .singleChoice,
        options: [
            QuestionOption(code: "beginner",     labelKey: "questionnaire.running.q1.option.beginner"),
            QuestionOption(code: "recreational", labelKey: "questionnaire.running.q1.option.recreational"),
            QuestionOption(code: "regular",      labelKey: "questionnaire.running.q1.option.regular"),
            QuestionOption(code: "competitive",  labelKey: "questionnaire.running.q1.option.competitive")
        ]
    )

    static let q2Goal = QuestionnaireQuestion(
        id: "q2_goal",
        textKey: "questionnaire.running.q2.text",
        answerType: .singleChoice,
        options: [
            QuestionOption(code: "5k",            labelKey: "questionnaire.running.q2.option.5k"),
            QuestionOption(code: "10k",           labelKey: "questionnaire.running.q2.option.10k"),
            QuestionOption(code: "half_marathon", labelKey: "questionnaire.running.q2.option.half_marathon"),
            QuestionOption(code: "marathon",      labelKey: "questionnaire.running.q2.option.marathon"),
            QuestionOption(code: "wellness",      labelKey: "questionnaire.running.q2.option.wellness")
        ]
    )

    static let q3Frequency = QuestionnaireQuestion(
        id: "q3_frequency",
        textKey: "questionnaire.running.q3.text",
        answerType: .singleChoice,
        options: [
            QuestionOption(code: "2",          labelKey: "questionnaire.running.q3.option.2"),
            QuestionOption(code: "3",          labelKey: "questionnaire.running.q3.option.3"),
            QuestionOption(code: "4_or_more",  labelKey: "questionnaire.running.q3.option.4_or_more")
        ]
    )

    /// ⚠️ Formulation neutre — pas « souffres-tu de... » (mémoire `epic3_leon_legal_constraints`).
    /// Options = zones du corps neutres, pas de pathologie.
    static let q4Constraints = QuestionnaireQuestion(
        id: "q4_constraints",
        textKey: "questionnaire.running.q4.text",
        answerType: .multiChoice,
        options: [
            QuestionOption(code: "knee",  labelKey: "questionnaire.running.q4.option.knee"),
            QuestionOption(code: "back",  labelKey: "questionnaire.running.q4.option.back"),
            QuestionOption(code: "ankle", labelKey: "questionnaire.running.q4.option.ankle"),
            QuestionOption(code: "shin",  labelKey: "questionnaire.running.q4.option.shin"),
            QuestionOption(code: "none",  labelKey: "questionnaire.running.q4.option.none")
        ]
    )

    static let q5Equipment = QuestionnaireQuestion(
        id: "q5_equipment",
        textKey: "questionnaire.running.q5.text",
        answerType: .multiChoice,
        options: [
            QuestionOption(code: "gps_watch",          labelKey: "questionnaire.running.q5.option.gps_watch"),
            QuestionOption(code: "heart_rate_monitor", labelKey: "questionnaire.running.q5.option.heart_rate_monitor"),
            QuestionOption(code: "treadmill_access",   labelKey: "questionnaire.running.q5.option.treadmill_access"),
            QuestionOption(code: "none",               labelKey: "questionnaire.running.q5.option.none")
        ]
    )

    static let q6FreeText = QuestionnaireQuestion(
        id: "q6_freetext",
        textKey: "questionnaire.running.q6.text",
        answerType: .freeText,
        options: []
    )

    var firstQuestion: QuestionnaireQuestion { Self.q1Level }

    // MARK: - Branchement

    func nextQuestion(
        after questionId: QuestionId,
        answer: AnswerValue,
        accumulated: [QuestionId: AnswerValue]
    ) -> QuestionnaireQuestion? {
        switch questionId {
        case Self.q1Level.id:
            return Self.q2Goal
        case Self.q2Goal.id:
            return Self.q3Frequency
        case Self.q3Frequency.id:
            // Branchement Q3 → Q4 OU Q5 :
            // si l'user est beginner (Q1), Q4 (contraintes physiques) n'est pas pertinente au démarrage → skip.
            if case .single("beginner") = accumulated[Self.q1Level.id] {
                return Self.q5Equipment
            }
            return Self.q4Constraints
        case Self.q4Constraints.id:
            return Self.q5Equipment
        case Self.q5Equipment.id:
            return Self.q6FreeText
        case Self.q6FreeText.id:
            return nil  // fin
        default:
            return nil
        }
    }

    // MARK: - Build profile

    func buildProfile(
        userId: UUID,
        answers: [QuestionId: AnswerValue],
        freeTextNotes: String?,
        history: [ConversationEntry],
        medicalClearanceAcknowledged: Bool
    ) -> CoachingSportProfile {

        // Q1 - level (single, default beginner pour défense en profondeur)
        let level = Self.singleAnswer(answers, key: Self.q1Level.id, default: "beginner")

        // Q2 - primary goal (single)
        let primaryGoal = Self.singleAnswer(answers, key: Self.q2Goal.id, default: "wellness")

        // Q3 - frequency : préserver le label brut "4_or_more" (review P1-3)
        let frequencyLabel = Self.singleAnswer(answers, key: Self.q3Frequency.id, default: "2")
        let frequencyPerWeek: Int = {
            switch frequencyLabel {
            case "2": return 2
            case "3": return 3
            case "4_or_more": return 4
            default: return Int(frequencyLabel) ?? 2
            }
        }()

        // Q4 - constraints : skippée si beginner ([] explicit) sinon array brute (review P1-10)
        // ["none"] explicit ≠ [] : ["none"] = user a confirmé "pas de contrainte" ; [] = question pas posée.
        let constraints = Self.multiAnswer(answers, key: Self.q4Constraints.id)

        // Q5 - equipment : même règle ["none"] explicit
        let equipment = Self.multiAnswer(answers, key: Self.q5Equipment.id)

        // Q6 - freeText (passé en paramètre, normalisé)
        let trimmed = freeTextNotes?.trimmingCharacters(in: .whitespacesAndNewlines)
        let notesValue: String? = (trimmed ?? "").isEmpty ? nil : trimmed

        return CoachingSportProfile(
            userId: userId,
            sportCode: sportCode,
            level: level,
            goals: GoalsPayload(primary: primaryGoal),
            equipment: equipment,
            constraints: constraints,
            frequencyPerWeek: frequencyPerWeek,
            frequencyLabel: frequencyLabel,
            sessionDurationMinutes: nil,
            freeTextNotes: notesValue,
            conversationHistory: history,
            medicalClearanceAcknowledged: medicalClearanceAcknowledged,
            questionnaireVersion: version
        )
    }

    // MARK: - Helpers

    private static func singleAnswer(
        _ answers: [QuestionId: AnswerValue],
        key: QuestionId,
        default fallback: String
    ) -> String {
        guard let v = answers[key], case .single(let s) = v else { return fallback }
        return s
    }

    /// Q4/Q5 multi : si la question est absente (skippée) → []. Sinon retourne l'array brute,
    /// même si elle contient ["none"] (préservation sémantique — review P1-10).
    private static func multiAnswer(
        _ answers: [QuestionId: AnswerValue],
        key: QuestionId
    ) -> [String] {
        guard let v = answers[key], case .multi(let arr) = v else { return [] }
        return arr
    }
}
