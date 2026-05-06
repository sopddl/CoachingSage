// Coaching/Questionnaires/UniversalQuestionnaire.swift
// Phase 2 #5 (Epic 3) — questionnaire universel applicable aux 10 sports.
// Remplace RunningQuestionnaire (supprimé). 3 questions max :
//   Q1 — niveau/forme actuelle (options universelles, pré-remplie par autoprofil HK)
//   Q2 — objectif (options sport-specific alignées sur les slugs templates v2)
//   Q3 — fréquence (options universelles, pré-remplie par autoprofil HK)
//
// Equipement et contraintes ne sont PLUS demandés ici :
//   - équipement = onboarding global (CoachingProfile.equipment, story Phase 2 #3)
//   - contraintes = PARQ onboarding (CoachingProfile.requiresMedicalClearance)
//
// Aucun switch FR/EN, aucun LocalizedStringKey ici (mémoire `multilangue_extensible_regle`).
// Tous les textes sont des clés xcstrings résolues côté View via Text(LocalizedStringKey(textKey)).
import Foundation

struct UniversalQuestionnaire: SportQuestionnaire {

    let sportCode: String
    let version: String = "universal_v1"

    init(sportCode: String) {
        self.sportCode = sportCode
    }

    // MARK: - Question IDs (statiques, identifiants stables)

    static let q1LevelId: QuestionId = "q1_level"
    static let q2GoalId: QuestionId = "q2_goal"
    static let q3FrequencyId: QuestionId = "q3_frequency"

    // MARK: - Q1 niveau (universel)

    static let q1Level = QuestionnaireQuestion(
        id: q1LevelId,
        textKey: "questionnaire.universal.q1.text",
        answerType: .singleChoice,
        options: [
            QuestionOption(code: "beginner",     labelKey: "questionnaire.universal.q1.option.beginner"),
            QuestionOption(code: "recreational", labelKey: "questionnaire.universal.q1.option.recreational"),
            QuestionOption(code: "regular",      labelKey: "questionnaire.universal.q1.option.regular"),
            QuestionOption(code: "competitive",  labelKey: "questionnaire.universal.q1.option.competitive")
        ]
    )

    // MARK: - Q3 fréquence (universel)

    static let q3Frequency = QuestionnaireQuestion(
        id: q3FrequencyId,
        textKey: "questionnaire.universal.q3.text",
        answerType: .singleChoice,
        options: [
            QuestionOption(code: "2",          labelKey: "questionnaire.universal.q3.option.2"),
            QuestionOption(code: "3",          labelKey: "questionnaire.universal.q3.option.3"),
            QuestionOption(code: "4_or_more",  labelKey: "questionnaire.universal.q3.option.4_or_more")
        ]
    )

    // MARK: - Q2 objectif (sport-specific — options alignées sur les slugs templates v2)

    var q2Goal: QuestionnaireQuestion {
        QuestionnaireQuestion(
            id: Self.q2GoalId,
            textKey: "questionnaire.\(sportCode).q2.text",
            answerType: .singleChoice,
            options: Self.goalOptions(for: sportCode)
        )
    }

    /// Codes goal alignés avec les slugs des templates `templates-manifest.json` (Story 0.5.10).
    /// Le tie-breaker du `ProgramTemplateSelector` matche `template.id.contains(goal.lowercased())`.
    static func goalOptions(for sportCode: String) -> [QuestionOption] {
        switch sportCode {
        case "running":
            return [
                QuestionOption(code: "wellness",      labelKey: "questionnaire.running.q2.option.wellness"),
                QuestionOption(code: "5k",            labelKey: "questionnaire.running.q2.option.5k"),
                QuestionOption(code: "10k",           labelKey: "questionnaire.running.q2.option.10k"),
                QuestionOption(code: "half_marathon", labelKey: "questionnaire.running.q2.option.half_marathon"),
                QuestionOption(code: "marathon",      labelKey: "questionnaire.running.q2.option.marathon")
            ]
        case "cycling":
            return [
                QuestionOption(code: "reprise",         labelKey: "questionnaire.cycling.q2.option.reprise"),
                QuestionOption(code: "endurance",       labelKey: "questionnaire.cycling.q2.option.endurance"),
                QuestionOption(code: "sorties-longues", labelKey: "questionnaire.cycling.q2.option.sorties_longues"),
                QuestionOption(code: "cyclosportive",   labelKey: "questionnaire.cycling.q2.option.cyclosportive")
            ]
        case "swimming":
            return [
                QuestionOption(code: "initiation",       labelKey: "questionnaire.swimming.q2.option.initiation"),
                QuestionOption(code: "endurance",        labelKey: "questionnaire.swimming.q2.option.endurance"),
                QuestionOption(code: "technique",        labelKey: "questionnaire.swimming.q2.option.technique"),
                QuestionOption(code: "perfectionnement", labelKey: "questionnaire.swimming.q2.option.perfectionnement")
            ]
        case "triathlon":
            return [
                QuestionOption(code: "decouverte",   labelKey: "questionnaire.triathlon.q2.option.decouverte"),
                QuestionOption(code: "sprint",       labelKey: "questionnaire.triathlon.q2.option.sprint"),
                QuestionOption(code: "distance-m",   labelKey: "questionnaire.triathlon.q2.option.distance_m"),
                QuestionOption(code: "half-ironman", labelKey: "questionnaire.triathlon.q2.option.half_ironman")
            ]
        case "strengthTraining":
            return [
                QuestionOption(code: "home-basics",  labelKey: "questionnaire.strengthTraining.q2.option.home_basics"),
                QuestionOption(code: "upperlower",   labelKey: "questionnaire.strengthTraining.q2.option.upperlower"),
                QuestionOption(code: "ppl",          labelKey: "questionnaire.strengthTraining.q2.option.ppl"),
                QuestionOption(code: "strength-5x5", labelKey: "questionnaire.strengthTraining.q2.option.strength_5x5")
            ]
        case "yoga":
            return [
                QuestionOption(code: "initiation", labelKey: "questionnaire.yoga.q2.option.initiation"),
                QuestionOption(code: "hatha",      labelKey: "questionnaire.yoga.q2.option.hatha"),
                QuestionOption(code: "vinyasa",    labelKey: "questionnaire.yoga.q2.option.vinyasa"),
                QuestionOption(code: "advanced",   labelKey: "questionnaire.yoga.q2.option.advanced")
            ]
        case "hiit":
            // Templates HIIT n'ont pas de goal explicite dans le slug (juste durée). Goals neutres
            // pour V1 ; le selector tombera sur le fallback level + tri id deterministic — ok.
            return [
                QuestionOption(code: "wellness",     labelKey: "questionnaire.hiit.q2.option.wellness"),
                QuestionOption(code: "conditioning", labelKey: "questionnaire.hiit.q2.option.conditioning"),
                QuestionOption(code: "performance",  labelKey: "questionnaire.hiit.q2.option.performance")
            ]
        case "hiking":
            return [
                QuestionOption(code: "decouverte",    labelKey: "questionnaire.hiking.q2.option.decouverte"),
                QuestionOption(code: "day-hikes",     labelKey: "questionnaire.hiking.q2.option.day_hikes"),
                QuestionOption(code: "mountain-trek", labelKey: "questionnaire.hiking.q2.option.mountain_trek"),
                QuestionOption(code: "fastpacking",   labelKey: "questionnaire.hiking.q2.option.fastpacking")
            ]
        case "tennis":
            return [
                QuestionOption(code: "initiation",   labelKey: "questionnaire.tennis.q2.option.initiation"),
                QuestionOption(code: "regularite",   labelKey: "questionnaire.tennis.q2.option.regularite"),
                QuestionOption(code: "match-prep",   labelKey: "questionnaire.tennis.q2.option.match_prep"),
                QuestionOption(code: "tournoi-prep", labelKey: "questionnaire.tennis.q2.option.tournoi_prep")
            ]
        case "football":
            return [
                QuestionOption(code: "initiation",      labelKey: "questionnaire.football.q2.option.initiation"),
                QuestionOption(code: "loisir",          labelKey: "questionnaire.football.q2.option.loisir"),
                QuestionOption(code: "club",            labelKey: "questionnaire.football.q2.option.club"),
                QuestionOption(code: "saison-regional", labelKey: "questionnaire.football.q2.option.saison_regional")
            ]
        default:
            return [
                QuestionOption(code: "wellness",    labelKey: "questionnaire.universal.q2.option.wellness"),
                QuestionOption(code: "performance", labelKey: "questionnaire.universal.q2.option.performance")
            ]
        }
    }

    /// Goal par défaut si le user passe par un chemin où Q2 n'est pas répondue (défense en profondeur).
    static func defaultGoal(for sportCode: String) -> String {
        goalOptions(for: sportCode).first?.code ?? "wellness"
    }

    // MARK: - Flow

    var firstQuestion: QuestionnaireQuestion { Self.q1Level }

    func nextQuestion(
        after questionId: QuestionId,
        answer: AnswerValue,
        accumulated: [QuestionId: AnswerValue]
    ) -> QuestionnaireQuestion? {
        switch questionId {
        case Self.q1LevelId:     return q2Goal
        case Self.q2GoalId:      return Self.q3Frequency
        case Self.q3FrequencyId: return nil  // fin
        default:                 return nil
        }
    }

    func findQuestion(byId id: QuestionId) -> QuestionnaireQuestion? {
        switch id {
        case Self.q1LevelId:     return Self.q1Level
        case Self.q2GoalId:      return q2Goal
        case Self.q3FrequencyId: return Self.q3Frequency
        default:                 return nil
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

        let level = Self.singleAnswer(answers, key: Self.q1LevelId, default: "beginner")
        let primaryGoal = Self.singleAnswer(answers, key: Self.q2GoalId, default: Self.defaultGoal(for: sportCode))

        let frequencyLabel = Self.singleAnswer(answers, key: Self.q3FrequencyId, default: "2")
        let frequencyPerWeek: Int = {
            switch frequencyLabel {
            case "2": return 2
            case "3": return 3
            case "4_or_more": return 4
            default: return Int(frequencyLabel) ?? 2
            }
        }()

        // Free text non collecté dans le universal mais conservé en API : le ViewModel pourra
        // toujours en injecter via `freeTextNotes` si une UI optionnelle l'expose plus tard.
        let trimmed = freeTextNotes?.trimmingCharacters(in: .whitespacesAndNewlines)
        let notesValue: String? = (trimmed ?? "").isEmpty ? nil : trimmed

        return CoachingSportProfile(
            userId: userId,
            sportCode: sportCode,
            level: level,
            goals: GoalsPayload(primary: primaryGoal),
            equipment: [],         // décision Sophie 2026-05-04 : équipement = CoachingProfile.equipment (onboarding global)
            constraints: [],       // décision Sophie 2026-05-04 : contraintes = PARQ onboarding (requiresMedicalClearance)
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
}
