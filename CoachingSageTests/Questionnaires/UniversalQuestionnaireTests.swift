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
}
