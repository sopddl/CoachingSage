// Coaching/Questionnaires/UniversalQuestionnaire.swift
// Phase 2 #5 (Epic 3) — questionnaire universel applicable aux 10 sports.
// Remplace RunningQuestionnaire (supprimé).
// Story sœur post-3.3b — ajout dimension durée du programme :
//   Q1 — niveau/forme actuelle (options universelles, pré-remplie par autoprofil HK)
//   Q2 — objectif (options sport-specific alignées sur les slugs templates v2)
//   Q3 — fréquence (options universelles, pré-remplie par autoprofil HK)
//        + nouvelle option "dont_know" → bascule en mode routine cyclique
//   Q4 — durée du programme (conditionnelle : skip si Q3=dont_know OU si Q2 non
//        deadline-eligible ; pose si Q2=goal compétition + Q3≠dont_know)
//   Q4Date — date picker (conditionnelle Q4=target_date)
//
// Sémantique des combinaisons → durationMode :
//   • Q3=dont_know                              → routineCyclic
//   • Q3=N + goal non eligible                   → routineCyclic
//   • Q3=N + goal eligible + Q4=routine_3_months → routineCyclic
//   • Q3=N + goal eligible + Q4=let_me_estimate  → deadlineEstimated
//   • Q3=N + goal eligible + Q4=target_date + Q4Date=DATE → deadlineFixed
//
// Equipement et contraintes ne sont PLUS demandés ici :
//   - équipement = onboarding global (CoachingProfile.equipment, story Phase 2 #3)
//   - contraintes = PARQ onboarding (CoachingProfile.requiresMedicalClearance)
//
// Aucun switch FR/EN, aucun LocalizedStringKey ici (mémoire `multilangue_extensible_regle`).
// Tous les textes sont des clés xcstrings résolues côté View via Text(LocalizedStringKey(textKey)).
import Foundation
import TemplateModel

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
    static let q4DurationId: QuestionId = "q4_duration"
    static let q4DateId: QuestionId = "q4_date"
    /// Indoor/outdoor vélo (2026-06-11) — lieu de pratique par défaut, posé en DERNIER
    /// pour le cycling uniquement. Pose `environmentDefaultRaw` du record au commit.
    static let q5LocationId: QuestionId = "q5_location"

    // MARK: - Q3 frequency option codes (refs partagés)

    static let q3DontKnowCode = "dont_know"

    // MARK: - Q4 duration option codes (refs partagés)

    static let q4TargetDateCode = "target_date"
    static let q4LetMeEstimateCode = "let_me_estimate"
    static let q4Routine3MonthsCode = "routine_3_months"

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
            QuestionOption(code: "1",          labelKey: "questionnaire.universal.q3.option.1"),
            QuestionOption(code: "2",          labelKey: "questionnaire.universal.q3.option.2"),
            QuestionOption(code: "3",          labelKey: "questionnaire.universal.q3.option.3"),
            QuestionOption(code: "4_or_more",  labelKey: "questionnaire.universal.q3.option.4_or_more"),
            QuestionOption(code: q3DontKnowCode, labelKey: "questionnaire.universal.q3.option.dont_know")
        ]
    )

    // MARK: - Q4 durée (universel, conditionnel)

    static let q4Duration = QuestionnaireQuestion(
        id: q4DurationId,
        textKey: "questionnaire.universal.q4.text",
        answerType: .singleChoice,
        options: [
            QuestionOption(code: q4TargetDateCode,     labelKey: "questionnaire.universal.q4.option.target_date"),
            QuestionOption(code: q4LetMeEstimateCode,  labelKey: "questionnaire.universal.q4.option.let_me_estimate"),
            QuestionOption(code: q4Routine3MonthsCode, labelKey: "questionnaire.universal.q4.option.routine_3_months")
        ]
    )

    /// Q4Date : date picker rendu spécial côté View (`QuestionAnswerOptionsView` détecte par `id`).
    /// answerType `.freeText` réutilisé : la View pose un DatePicker au lieu d'un TextField,
    /// et stocke la date au format ISO8601 dans `AnswerValue.text(...)`.
    static let q4Date = QuestionnaireQuestion(
        id: q4DateId,
        textKey: "questionnaire.universal.q4_date.text",
        answerType: .freeText,
        options: []
    )

    // MARK: - Q5 lieu (indoor/outdoor vélo — cycling uniquement, posée en dernier)

    /// Question lieu de pratique vélo. Le code choisi ("outdoor"/"indoor"/"both")
    /// pose le défaut de lieu du programme (`AdaptedProgramRecord.environmentDefaultRaw`).
    /// "outdoor"/"indoor" → toutes les séances à variante s'affichent dans ce lieu ;
    /// "both" → chaque séance garde sa variante native, flip libre via la puce.
    static let q5Location = QuestionnaireQuestion(
        id: q5LocationId,
        textKey: "questionnaire.cycling.q5.text",
        answerType: .singleChoice,
        options: [
            QuestionOption(code: "outdoor", labelKey: "questionnaire.cycling.q5.option.outdoor"),
            QuestionOption(code: "indoor",  labelKey: "questionnaire.cycling.q5.option.indoor"),
            QuestionOption(code: "both",    labelKey: "questionnaire.cycling.q5.option.both")
        ]
    )

    /// Lieu par défaut extrait de l'historique questionnaire (réponse Q5). Retourne le
    /// code brut ("outdoor"/"indoor"/"both") ou nil si non posée (sports non-vélo).
    /// Consommé au commit du programme pour poser `environmentDefaultRaw`.
    static func environmentDefault(from history: [ConversationEntry]) -> String? {
        guard let entry = history.first(where: { $0.questionId == q5LocationId }),
              case .single(let code)? = entry.answer else { return nil }
        return code
    }

    // MARK: - Deadline-eligible goals (= goals avec date cible possible)

    /// Goals qui autorisent une date cible explicite (vs routine cyclique). Liste alignée
    /// avec les slugs des templates v2 (`templates-manifest.json`). Si le goal Q2 n'est PAS
    /// dans cette liste → Q4 skip → routineCyclic forcé.
    static func goalAllowsDeadline(_ goal: String, in sportCode: String) -> Bool {
        let eligible = deadlineEligibleGoals(for: sportCode)
        return eligible.contains(goal)
    }

    static func deadlineEligibleGoals(for sportCode: String) -> Set<String> {
        switch sportCode {
        case "running":  return ["5k", "10k", "half_marathon", "marathon"]
        case "cycling":  return ["cyclosportive"]
        case "triathlon": return ["sprint", "distance-m", "half-ironman"]
        case "tennis":   return ["tournoi-prep", "match-prep"]
        case "football": return ["saison-regional"]
        // swimming, strengthTraining, yoga, hiit, hiking → tous routine V1
        default: return []
        }
    }

    // MARK: - Q2 objectif (sport-specific — options alignées sur les slugs templates v2)

    var q2Goal: QuestionnaireQuestion {
        QuestionnaireQuestion(
            id: Self.q2GoalId,
            textKey: "questionnaire.\(sportCode).q2.text",
            answerType: Self.isCycleExclusiveSport(sportCode) ? .singleChoice : .multiChoice,
            options: Self.goalOptions(for: sportCode)
        )
    }

    /// Story 3.13 Phase E — `strengthTraining` + `triathlon` ont un catalogue de templates
    /// structurellement exclusif (1 split = 1 programme ; 1 distance = 1 cycle). Pour ces
    /// 2 sports, Q2 reste en `.singleChoice` : on force l'user à choisir un cycle à la fois
    /// + hint pédagogique "tu pourras en enchaîner d'autres ensuite" affichée par la View.
    /// Les 8 autres sports passent en `.multiChoice` (objectifs combinables via overlay).
    static func isCycleExclusiveSport(_ sportCode: String) -> Bool {
        sportCode == "strengthTraining" || sportCode == "triathlon"
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
        case Self.q1LevelId:
            return q2Goal
        case Self.q2GoalId:
            return Self.q3Frequency
        case Self.q3FrequencyId:
            return nextAfterFrequency(answer: answer, accumulated: accumulated) ?? locationGate(accumulated)
        case Self.q4DurationId:
            // Si target_date → poser le date picker. Sinon fin (mode = estimated ou routine).
            if case .single(let code) = answer, code == Self.q4TargetDateCode {
                return Self.q4Date
            }
            return locationGate(accumulated)
        case Self.q4DateId:
            return locationGate(accumulated)
        case Self.q5LocationId:
            return nil
        default:
            return nil
        }
    }

    /// Indoor/outdoor vélo — Q5 lieu posée en DERNIER, cycling uniquement, si pas déjà
    /// répondue. Branchée sur tous les points terminaux du flux (`?? locationGate`).
    private func locationGate(_ accumulated: [QuestionId: AnswerValue]) -> QuestionnaireQuestion? {
        guard sportCode == "cycling", accumulated[Self.q5LocationId] == nil else { return nil }
        return Self.q5Location
    }

    /// Logique conditionnelle après Q3 :
    ///   - "dont_know" → fin (forcera routineCyclic au build)
    ///   - sinon, vérifier si le goal Q2 autorise une date cible :
    ///       • oui → poser Q4
    ///       • non → fin (forcera routineCyclic au build)
    private func nextAfterFrequency(
        answer: AnswerValue,
        accumulated: [QuestionId: AnswerValue]
    ) -> QuestionnaireQuestion? {
        if case .single(let code) = answer, code == Self.q3DontKnowCode {
            return nil
        }
        // Story 3.13 Phase B : Q2 = .multiChoice. On utilise le primary canonique (selon ordre
        // sport-specifique GoalCompatibilityMatrix.primaryPriority) comme pivot pour le branchement Q4,
        // pour rester cohérent avec ce que buildProfile() finira par persister comme `goals.primary`.
        let goalsList = Self.goalsList(accumulated, sportCode: sportCode)
        guard let primaryGoal = GoalCompatibilityMatrix.pickPrimary(from: goalsList, sportCode: sportCode) else {
            return nil
        }
        return Self.goalAllowsDeadline(primaryGoal, in: sportCode) ? Self.q4Duration : nil
    }

    func findQuestion(byId id: QuestionId) -> QuestionnaireQuestion? {
        switch id {
        case Self.q1LevelId:     return Self.q1Level
        case Self.q2GoalId:      return q2Goal
        case Self.q3FrequencyId: return Self.q3Frequency
        case Self.q4DurationId:  return Self.q4Duration
        case Self.q4DateId:      return Self.q4Date
        case Self.q5LocationId:  return Self.q5Location
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

        // Story 3.13 Phase B (AC8-9) : Q2 = .multiChoice → on extrait goals = [...].
        // Primary algo : premier de l'ordre canonique sport-specifique qui matche la sélection user
        // (cf GoalCompatibilityMatrix.primaryPriority). Fallback : premier goal user.
        // Secondary = autres goals (ordre user préservé), primary exclu.
        // Compat : si rows legacy .single (DB ou tests) → migré en .multi([primary]).
        let goalsList = Self.goalsList(answers, sportCode: sportCode)
        let primaryGoal = GoalCompatibilityMatrix.pickPrimary(from: goalsList, sportCode: sportCode)
            ?? Self.defaultGoal(for: sportCode)
        let secondaryGoals = goalsList.filter { $0 != primaryGoal }

        let frequencyLabel = Self.singleAnswer(answers, key: Self.q3FrequencyId, default: "2")
        let frequencyPerWeek: Int = {
            switch frequencyLabel {
            case "1": return 1
            case "2": return 2
            case "3": return 3
            case "4_or_more": return 4
            case Self.q3DontKnowCode: return 3   // routine = mid-range sensible default
            default: return Int(frequencyLabel) ?? 2
            }
        }()

        let (durationMode, targetDate) = Self.resolveDuration(
            answers: answers,
            goal: primaryGoal,
            sportCode: sportCode,
            level: level
        )

        // Free text non collecté dans le universal mais conservé en API : le ViewModel pourra
        // toujours en injecter via `freeTextNotes` si une UI optionnelle l'expose plus tard.
        let trimmed = freeTextNotes?.trimmingCharacters(in: .whitespacesAndNewlines)
        let notesValue: String? = (trimmed ?? "").isEmpty ? nil : trimmed

        return CoachingSportProfile(
            userId: userId,
            sportCode: sportCode,
            level: level,
            goals: GoalsPayload(primary: primaryGoal, secondary: secondaryGoals),
            equipment: [],         // décision Sophie 2026-05-04 : équipement = CoachingProfile.equipment (onboarding global)
            constraints: [],       // décision Sophie 2026-05-04 : contraintes = PARQ onboarding (requiresMedicalClearance)
            frequencyPerWeek: frequencyPerWeek,
            frequencyLabel: frequencyLabel,
            sessionDurationMinutes: nil,
            freeTextNotes: notesValue,
            conversationHistory: history,
            medicalClearanceAcknowledged: medicalClearanceAcknowledged,
            questionnaireVersion: version,
            durationMode: durationMode,
            targetDate: targetDate
        )
    }

    /// Calcule (durationMode, targetDate) à partir des réponses Q3/Q4/Q4Date.
    /// - Q3=dont_know → routineCyclic
    /// - Q3=N + goal non eligible → routineCyclic
    /// - Q4=routine_3_months → routineCyclic
    /// - Q4=let_me_estimate → deadlineEstimated (targetDate **pré-calculée**
    ///   ici via `ProgramDurationResolver` pour respecter la CHECK constraint
    ///   Supabase `coaching_sport_profiles_target_date_consistency` qui exige
    ///   `target_date NOT NULL` pour ce mode. L'ancienne version retournait
    ///   `nil` et déléguait au ProgramAdapter, mais le profile est sauvegardé
    ///   AVANT que l'adapter ne s'exécute → insert rejeté).
    /// - Q4=target_date + Q4Date=ISO8601 → deadlineFixed (targetDate = parsed date)
    /// - Q4=target_date sans Q4Date valide → fallback routineCyclic (défense en profondeur)
    static func resolveDuration(
        answers: [QuestionId: AnswerValue],
        goal: String,
        sportCode: String,
        level: String,
        now: Date = Date()
    ) -> (ProgramDurationMode, Date?) {
        // Q3 dont_know → routine
        if case .single(let freq) = answers[q3FrequencyId], freq == q3DontKnowCode {
            return (.routineCyclic, nil)
        }
        // goal non eligible deadline → routine
        guard goalAllowsDeadline(goal, in: sportCode) else {
            return (.routineCyclic, nil)
        }
        // Q4 manquant (cas extrême) → routine
        guard case .single(let q4) = answers[q4DurationId] else {
            return (.routineCyclic, nil)
        }
        switch q4 {
        case q4Routine3MonthsCode:
            return (.routineCyclic, nil)
        case q4LetMeEstimateCode:
            // Hotfix CHECK constraint Supabase : on pré-calcule la date estimée
            // ICI plutôt que de la déléguer au ProgramAdapter (qui s'exécute après
            // le save du profile). Sport/Level invalides → fallback routineCyclic
            // (défense en profondeur, ne devrait jamais arriver en prod).
            guard let sport = Sport(sportCode: sportCode),
                  let levelEnum = Level(rawValue: level) else {
                return (.routineCyclic, nil)
            }
            let (_, estimated) = ProgramDurationResolver().resolve(
                durationMode: .deadlineEstimated,
                targetDate: nil,
                goal: goal,
                sport: sport,
                level: levelEnum,
                templateDurationWeeks: 12, // ignoré par le resolver en .deadlineEstimated
                now: now
            )
            return (.deadlineEstimated, estimated)
        case q4TargetDateCode:
            // Q4Date = ISO8601 string (cf View date picker)
            if case .text(let dateString?) = answers[q4DateId],
               let parsed = ISO8601DateFormatter().date(from: dateString) {
                return (.deadlineFixed, parsed)
            }
            return (.routineCyclic, nil)
        default:
            return (.routineCyclic, nil)
        }
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

    /// Story 3.13 Phase A — extrait la liste des goals cochés à Q2.
    /// Tolère 3 formats : `.multi([codes])` (nominal post-3.13), `.single(code)` (legacy pre-3.13),
    /// rien → []. Filtre les codes vides pour robustesse.
    static func goalsList(
        _ answers: [QuestionId: AnswerValue],
        sportCode: String
    ) -> [String] {
        guard let v = answers[q2GoalId] else { return [] }
        switch v {
        case .multi(let codes):
            return codes.filter { !$0.isEmpty }
        case .single(let code):
            return code.isEmpty ? [] : [code]
        case .text:
            return []
        }
    }

    /// Premier goal coché (= primary en Phase A). Phase B raffinera via ranking sport-specifique.
    static func firstGoal(in answers: [QuestionId: AnswerValue]) -> String? {
        guard let v = answers[q2GoalId] else { return nil }
        switch v {
        case .multi(let codes):
            return codes.first { !$0.isEmpty }
        case .single(let code):
            return code.isEmpty ? nil : code
        case .text:
            return nil
        }
    }
}
