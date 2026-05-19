// CoachingSageTests/Questionnaires/UniversalQuestionnaireTests.swift
// Phase 2 #5 — tests métier du moteur questionnaire universel.
import Testing
import Foundation
@testable import CoachingSage

@Suite("UniversalQuestionnaire")
struct UniversalQuestionnaireTests {

    // MARK: - Bootstrap

    @Test
    func firstQuestion_isQ1Level_universal() {
        let q = UniversalQuestionnaire(sportCode: "running")
        #expect(q.firstQuestion.id == "q1_level")
        #expect(q.firstQuestion.textKey == "questionnaire.universal.q1.text")
        #expect(q.firstQuestion.answerType == .singleChoice)
        #expect(q.firstQuestion.options.count == 4)
    }

    @Test
    func versionIsUniversalV1() {
        #expect(UniversalQuestionnaire(sportCode: "yoga").version == "universal_v1")
    }

    @Test
    func sportCodeReflectsConstructor() {
        #expect(UniversalQuestionnaire(sportCode: "tennis").sportCode == "tennis")
    }

    // MARK: - Flow Q1 → Q2 → Q3 → end

    @Test
    func nextQuestion_followsLinearFlow() {
        let q = UniversalQuestionnaire(sportCode: "running")
        let acc: [QuestionId: AnswerValue] = [:]
        #expect(q.nextQuestion(after: "q1_level", answer: .single("regular"), accumulated: acc)?.id == "q2_goal")
        #expect(q.nextQuestion(after: "q2_goal", answer: .single("10k"), accumulated: acc)?.id == "q3_frequency")
        #expect(q.nextQuestion(after: "q3_frequency", answer: .single("3"), accumulated: acc) == nil)
    }

    // MARK: - Q2 sport-specific

    @Test("Q2 textKey est sport-specific")
    func q2TextKeyIsSportSpecific() {
        #expect(UniversalQuestionnaire(sportCode: "running").q2Goal.textKey == "questionnaire.running.q2.text")
        #expect(UniversalQuestionnaire(sportCode: "cycling").q2Goal.textKey == "questionnaire.cycling.q2.text")
        #expect(UniversalQuestionnaire(sportCode: "yoga").q2Goal.textKey == "questionnaire.yoga.q2.text")
    }

    @Test("Q2 options diffèrent par sport (running vs swimming)")
    func q2OptionsDifferBySport() {
        let runningGoals = UniversalQuestionnaire(sportCode: "running").q2Goal.options.map { $0.code }
        let swimmingGoals = UniversalQuestionnaire(sportCode: "swimming").q2Goal.options.map { $0.code }
        #expect(runningGoals != swimmingGoals)
        #expect(runningGoals.contains("marathon"))
        #expect(swimmingGoals.contains("technique"))
    }

    @Test("Tous les sports SportCode ont au moins 2 goals")
    func allSportsHaveGoals() {
        for code in SportCode.allCases.map({ $0.rawValue }) {
            let opts = UniversalQuestionnaire.goalOptions(for: code)
            #expect(opts.count >= 2, "Sport \(code) a moins de 2 goals : \(opts.count)")
        }
    }

    // MARK: - findQuestion

    @Test("findQuestion retourne les 3 questions universelles, nil sinon")
    func findQuestionResolvesAll() {
        let q = UniversalQuestionnaire(sportCode: "hiking")
        #expect(q.findQuestion(byId: "q1_level")?.id == "q1_level")
        #expect(q.findQuestion(byId: "q2_goal")?.id == "q2_goal")
        #expect(q.findQuestion(byId: "q3_frequency")?.id == "q3_frequency")
        #expect(q.findQuestion(byId: "q4_constraints") == nil)
    }

    // MARK: - buildProfile

    @Test
    func buildProfile_serializesUniversalV1() {
        let q = UniversalQuestionnaire(sportCode: "running")
        let userId = UUID()
        let profile = q.buildProfile(
            userId: userId,
            answers: [
                "q1_level": .single("regular"),
                "q2_goal": .single("10k"),
                "q3_frequency": .single("3")
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.userId == userId)
        #expect(profile.sportCode == "running")
        #expect(profile.level == "regular")
        #expect(profile.goals.primary == "10k")
        #expect(profile.frequencyPerWeek == 3)
        #expect(profile.frequencyLabel == "3")
        // Phase 2 #5 : equipment + constraints sont retournés vides — ils viennent de CoachingProfile.
        #expect(profile.equipment == [])
        #expect(profile.constraints == [])
        #expect(profile.questionnaireVersion == "universal_v1")
    }

    @Test("frequency '4_or_more' préservé dans label, mappé à 4 dans int")
    func buildProfile_preservesFrequencyLabelFourOrMore() {
        let q = UniversalQuestionnaire(sportCode: "cycling")
        let profile = q.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("competitive"),
                "q2_goal": .single("cyclosportive"),
                "q3_frequency": .single("4_or_more")
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: true
        )
        #expect(profile.frequencyPerWeek == 4)
        #expect(profile.frequencyLabel == "4_or_more")
        #expect(profile.medicalClearanceAcknowledged == true)
    }

    @Test("Goal manquant → defaultGoal du sport")
    func buildProfile_defaultGoalWhenMissing() {
        let q = UniversalQuestionnaire(sportCode: "yoga")
        let profile = q.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("beginner"),
                "q3_frequency": .single("2")
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        // Default = première option de la table goalOptions(for: "yoga") = "initiation".
        #expect(profile.goals.primary == UniversalQuestionnaire.defaultGoal(for: "yoga"))
        #expect(profile.goals.primary == "initiation")
    }

    // MARK: - Story sœur — Q3 dont_know

    @Test("Q3=dont_know termine le flow (pas de Q4) et bascule en routineCyclic")
    func nextQuestion_q3DontKnow_terminatesAndForcesRoutine() {
        let q = UniversalQuestionnaire(sportCode: "running")
        let acc: [QuestionId: AnswerValue] = [
            "q1_level": .single("regular"),
            "q2_goal": .single("marathon"),  // marathon est deadline-eligible mais dont_know domine
            "q3_frequency": .single(UniversalQuestionnaire.q3DontKnowCode)
        ]
        #expect(q.nextQuestion(after: "q3_frequency", answer: .single(UniversalQuestionnaire.q3DontKnowCode), accumulated: acc) == nil)

        let profile = q.buildProfile(
            userId: UUID(),
            answers: acc,
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.durationMode == .routineCyclic)
        #expect(profile.targetDate == nil)
        #expect(profile.frequencyLabel == "dont_know")
        #expect(profile.frequencyPerWeek == 3)  // mid-range default
    }

    // MARK: - Story sœur — Q4 conditionnel selon goal eligibility

    @Test("Q3=3 + goal non eligible → fin (pas de Q4) et routineCyclic")
    func nextQuestion_goalNotEligible_terminatesAtQ3() {
        let q = UniversalQuestionnaire(sportCode: "yoga")
        let acc: [QuestionId: AnswerValue] = [
            "q1_level": .single("beginner"),
            "q2_goal": .single("initiation"),  // yoga = aucun goal eligible
            "q3_frequency": .single("3")
        ]
        #expect(q.nextQuestion(after: "q3_frequency", answer: .single("3"), accumulated: acc) == nil)

        let profile = q.buildProfile(
            userId: UUID(),
            answers: acc,
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.durationMode == .routineCyclic)
        #expect(profile.targetDate == nil)
    }

    @Test("Q3=3 + goal eligible → Q4 posée")
    func nextQuestion_goalEligible_propagatesToQ4() {
        let q = UniversalQuestionnaire(sportCode: "running")
        let acc: [QuestionId: AnswerValue] = [
            "q1_level": .single("regular"),
            "q2_goal": .single("10k"),  // running 10k = deadline-eligible
            "q3_frequency": .single("3")
        ]
        let next = q.nextQuestion(after: "q3_frequency", answer: .single("3"), accumulated: acc)
        #expect(next?.id == "q4_duration")
        #expect(next?.answerType == .singleChoice)
        #expect(next?.options.count == 3)
    }

    // MARK: - Story sœur — Q4 → durationMode

    @Test("Q4=routine_3_months → routineCyclic")
    func buildProfile_q4Routine_buildsRoutineCyclic() {
        let q = UniversalQuestionnaire(sportCode: "running")
        let profile = q.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("regular"),
                "q2_goal": .single("marathon"),
                "q3_frequency": .single("4_or_more"),
                "q4_duration": .single(UniversalQuestionnaire.q4Routine3MonthsCode)
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.durationMode == .routineCyclic)
        #expect(profile.targetDate == nil)
    }

    @Test("Q4=let_me_estimate → deadlineEstimated, targetDate nil (calculé par adapter)")
    func buildProfile_q4Estimate_buildsDeadlineEstimated() {
        let q = UniversalQuestionnaire(sportCode: "triathlon")
        let profile = q.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("competitive"),
                "q2_goal": .single("sprint"),
                "q3_frequency": .single("3"),
                "q4_duration": .single(UniversalQuestionnaire.q4LetMeEstimateCode)
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.durationMode == .deadlineEstimated)
        #expect(profile.targetDate == nil)
    }

    @Test("Q4=target_date suit Q4Date date picker")
    func nextQuestion_q4TargetDate_propagatesToQ4Date() {
        let q = UniversalQuestionnaire(sportCode: "tennis")
        let acc: [QuestionId: AnswerValue] = [
            "q1_level": .single("regular"),
            "q2_goal": .single("tournoi-prep"),
            "q3_frequency": .single("3")
        ]
        let next = q.nextQuestion(
            after: "q4_duration",
            answer: .single(UniversalQuestionnaire.q4TargetDateCode),
            accumulated: acc
        )
        #expect(next?.id == "q4_date")
        #expect(next?.answerType == .freeText)
    }

    @Test("Q4=target_date + Q4Date ISO8601 → deadlineFixed avec parsed date")
    func buildProfile_q4TargetDateWithDate_buildsDeadlineFixed() {
        let q = UniversalQuestionnaire(sportCode: "running")
        let raceDate = Date(timeIntervalSince1970: 1_750_000_000)  // ~2026 mid-year
        let iso = ISO8601DateFormatter().string(from: raceDate)
        let profile = q.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("regular"),
                "q2_goal": .single("half_marathon"),
                "q3_frequency": .single("3"),
                "q4_duration": .single(UniversalQuestionnaire.q4TargetDateCode),
                "q4_date": .text(iso)
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.durationMode == .deadlineFixed)
        // Tolérance 1s (ISO8601 round-trip arrondit les ms).
        if let parsed = profile.targetDate {
            #expect(abs(parsed.timeIntervalSince(raceDate)) < 1.0)
        } else {
            Issue.record("targetDate doit être non-nil en deadlineFixed")
        }
    }

    @Test("Q4=target_date sans Q4Date → fallback routineCyclic (défense en profondeur)")
    func buildProfile_q4TargetDateMissingDate_fallsBackToRoutine() {
        let q = UniversalQuestionnaire(sportCode: "running")
        let profile = q.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("regular"),
                "q2_goal": .single("10k"),
                "q3_frequency": .single("3"),
                "q4_duration": .single(UniversalQuestionnaire.q4TargetDateCode)
                // q4_date manquant
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.durationMode == .routineCyclic)
        #expect(profile.targetDate == nil)
    }

    // MARK: - Story sœur — goalAllowsDeadline mapping

    @Test("Mapping deadline-eligible : running courses oui, wellness non")
    func goalAllowsDeadline_runningMapping() {
        #expect(UniversalQuestionnaire.goalAllowsDeadline("5k", in: "running"))
        #expect(UniversalQuestionnaire.goalAllowsDeadline("marathon", in: "running"))
        #expect(!UniversalQuestionnaire.goalAllowsDeadline("wellness", in: "running"))
    }

    @Test("Mapping : sports purement routine (yoga, swimming, hiking) → aucun goal eligible")
    func goalAllowsDeadline_routineOnlySports() {
        #expect(UniversalQuestionnaire.deadlineEligibleGoals(for: "yoga").isEmpty)
        #expect(UniversalQuestionnaire.deadlineEligibleGoals(for: "swimming").isEmpty)
        #expect(UniversalQuestionnaire.deadlineEligibleGoals(for: "hiking").isEmpty)
        #expect(UniversalQuestionnaire.deadlineEligibleGoals(for: "strengthTraining").isEmpty)
        #expect(UniversalQuestionnaire.deadlineEligibleGoals(for: "hiit").isEmpty)
    }

    @Test("Mapping : tennis tournoi/match-prep, football saison-regional, cycling cyclosportive")
    func goalAllowsDeadline_otherSports() {
        #expect(UniversalQuestionnaire.goalAllowsDeadline("tournoi-prep", in: "tennis"))
        #expect(UniversalQuestionnaire.goalAllowsDeadline("match-prep", in: "tennis"))
        #expect(!UniversalQuestionnaire.goalAllowsDeadline("regularite", in: "tennis"))

        #expect(UniversalQuestionnaire.goalAllowsDeadline("saison-regional", in: "football"))
        #expect(!UniversalQuestionnaire.goalAllowsDeadline("loisir", in: "football"))

        #expect(UniversalQuestionnaire.goalAllowsDeadline("cyclosportive", in: "cycling"))
        #expect(!UniversalQuestionnaire.goalAllowsDeadline("endurance", in: "cycling"))
    }

    // MARK: - Story sœur — findQuestion étendue

    @Test("findQuestion résout aussi q4_duration et q4_date")
    func findQuestionIncludesQ4() {
        let q = UniversalQuestionnaire(sportCode: "running")
        #expect(q.findQuestion(byId: "q4_duration")?.id == "q4_duration")
        #expect(q.findQuestion(byId: "q4_date")?.id == "q4_date")
    }

    // MARK: - Story 3.13 Phase E (AC22) — Q2 multi-choice end-to-end

    @Test("Q2 est multiChoice pour la majorité des sports + textKey sport-spécifique")
    func q2Goal_isMultiChoice() {
        let q = UniversalQuestionnaire(sportCode: "running")
        #expect(q.q2Goal.answerType == .multiChoice)
        #expect(q.q2Goal.textKey == "questionnaire.running.q2.text")
    }

    @Test("Q2 forcé en singleChoice pour strengthTraining + triathlon (catalogue exclusif)")
    func q2Goal_isSingleChoiceForCycleExclusiveSports() {
        // Phase E : ces 2 sports ont un catalogue structurellement exclusif (1 split / 1 distance
        // par cycle). On force single-choice + hint pédagogique côté UI plutôt que d'autoriser
        // multi et ignorer secondary silencieusement.
        #expect(UniversalQuestionnaire(sportCode: "strengthTraining").q2Goal.answerType == .singleChoice)
        #expect(UniversalQuestionnaire(sportCode: "triathlon").q2Goal.answerType == .singleChoice)
        #expect(UniversalQuestionnaire.isCycleExclusiveSport("strengthTraining"))
        #expect(UniversalQuestionnaire.isCycleExclusiveSport("triathlon"))
        // Autres sports restent multiChoice
        #expect(!UniversalQuestionnaire.isCycleExclusiveSport("running"))
        #expect(!UniversalQuestionnaire.isCycleExclusiveSport("swimming"))
    }

    @Test("buildProfile multi running [10k, wellness] → primary=10k, secondary=[wellness]")
    func buildProfile_multiGoals_picksPrimaryFromCanonical() {
        let q = UniversalQuestionnaire(sportCode: "running")
        let profile = q.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("regular"),
                "q2_goal": .multi(["10k", "wellness"]),
                "q3_frequency": .single("3")
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.goals.primary == "10k")
        #expect(profile.goals.secondary == ["wellness"])
    }

    @Test("buildProfile multi est order-independent — primary suit l'ordre canonique sport")
    func buildProfile_multiGoals_orderIndependent() {
        let q = UniversalQuestionnaire(sportCode: "running")
        let profile = q.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("regular"),
                "q2_goal": .multi(["wellness", "10k"]),  // ordre user inverse
                "q3_frequency": .single("3")
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        // Canonical running : [marathon, half_marathon, 10k, 5k, wellness] → 10k > wellness.
        #expect(profile.goals.primary == "10k")
        #expect(profile.goals.secondary == ["wellness"])
    }

    @Test("buildProfile multi swimming [technique, endurance] → primary=endurance (post-review reviewer)")
    func buildProfile_multiGoals_swimmingEnduranceBackbone() {
        let q = UniversalQuestionnaire(sportCode: "swimming")
        let profile = q.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("regular"),
                "q2_goal": .multi(["technique", "endurance"]),
                "q3_frequency": .single("3")
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        // Swimming canonical post-review : [endurance, perfectionnement, technique, initiation].
        #expect(profile.goals.primary == "endurance")
        #expect(profile.goals.secondary == ["technique"])
    }

    @Test("buildProfile single legacy (.single) migré en .multi([primary]) → secondary vide")
    func buildProfile_singleLegacyGoal_secondaryEmpty() {
        let q = UniversalQuestionnaire(sportCode: "running")
        let profile = q.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("regular"),
                "q2_goal": .single("10k"),     // legacy single
                "q3_frequency": .single("3")
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.goals.primary == "10k")
        #expect(profile.goals.secondary.isEmpty)
    }

    @Test("Multi avec un seul goal coché → secondary vide (pas de bruit)")
    func buildProfile_multiGoals_singleCheckedYieldsEmptySecondary() {
        let q = UniversalQuestionnaire(sportCode: "cycling")
        let profile = q.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("regular"),
                "q2_goal": .multi(["cyclosportive"]),
                "q3_frequency": .single("3")
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.goals.primary == "cyclosportive")
        #expect(profile.goals.secondary.isEmpty)
    }

    @Test("nextAfterFrequency utilise le primary canonique du multi (deadline-eligible)")
    func nextAfterFrequency_usesCanonicalPrimary() {
        let q = UniversalQuestionnaire(sportCode: "running")
        // multi [wellness, 10k] → primary canonique = 10k = deadline-eligible
        // → Q4 duration doit s'enclencher.
        let acc: [QuestionId: AnswerValue] = [
            "q1_level": .single("regular"),
            "q2_goal": .multi(["wellness", "10k"])
        ]
        let next = q.nextQuestion(after: "q3_frequency", answer: .single("3"), accumulated: acc)
        #expect(next?.id == "q4_duration")
    }
}
