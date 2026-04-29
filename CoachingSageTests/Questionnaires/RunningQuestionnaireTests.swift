// CoachingSageTests/Questionnaires/RunningQuestionnaireTests.swift
// Story 3.1 — tests métier du moteur questionnaire Running.
// Zone de risque #1 : le branchement conditionnel Q4 si Q1=beginner (cf. AC5).
import Testing
import Foundation
@testable import CoachingSage

@Suite("RunningQuestionnaire")
struct RunningQuestionnaireTests {

    private let questionnaire = RunningQuestionnaire()

    // MARK: - Bootstrap

    @Test
    func firstQuestion_isQ1Level() {
        #expect(questionnaire.firstQuestion.id == "q1_level")
        #expect(questionnaire.firstQuestion.answerType == .singleChoice)
        #expect(questionnaire.firstQuestion.options.count == 4)
    }

    @Test
    func sportCodeAndVersion() {
        #expect(questionnaire.sportCode == "running")
        #expect(questionnaire.version == "running_v1")
    }

    // MARK: - Branchement Q4 (zone de risque)

    @Test("Q3 → Q5 si Q1=beginner (Q4 skippée)")
    func nextQuestion_skipsQ4WhenBeginner() {
        let accumulated: [QuestionId: AnswerValue] = [
            "q1_level": .single("beginner"),
            "q2_goal": .single("wellness"),
            "q3_frequency": .single("2")
        ]
        let next = questionnaire.nextQuestion(after: "q3_frequency", answer: .single("2"), accumulated: accumulated)
        #expect(next?.id == "q5_equipment")
    }

    @Test("Q3 → Q4 si Q1=regular")
    func nextQuestion_includesQ4WhenRegular() {
        let accumulated: [QuestionId: AnswerValue] = [
            "q1_level": .single("regular"),
            "q2_goal": .single("10k"),
            "q3_frequency": .single("3")
        ]
        let next = questionnaire.nextQuestion(after: "q3_frequency", answer: .single("3"), accumulated: accumulated)
        #expect(next?.id == "q4_constraints")
    }

    @Test("Q3 → Q4 si Q1=competitive")
    func nextQuestion_includesQ4WhenCompetitive() {
        let accumulated: [QuestionId: AnswerValue] = [
            "q1_level": .single("competitive")
        ]
        let next = questionnaire.nextQuestion(after: "q3_frequency", answer: .single("4_or_more"), accumulated: accumulated)
        #expect(next?.id == "q4_constraints")
    }

    @Test("Flow complet enchainement standard")
    func nextQuestion_fullFlowStandard() {
        // Q1 → Q2 → Q3 → Q4 (regular) → Q5 → Q6 → nil
        let acc: [QuestionId: AnswerValue] = ["q1_level": .single("regular")]
        #expect(questionnaire.nextQuestion(after: "q1_level", answer: .single("regular"), accumulated: acc)?.id == "q2_goal")
        #expect(questionnaire.nextQuestion(after: "q2_goal", answer: .single("5k"), accumulated: acc)?.id == "q3_frequency")
        #expect(questionnaire.nextQuestion(after: "q3_frequency", answer: .single("3"), accumulated: acc)?.id == "q4_constraints")
        #expect(questionnaire.nextQuestion(after: "q4_constraints", answer: .multi(["knee"]), accumulated: acc)?.id == "q5_equipment")
        #expect(questionnaire.nextQuestion(after: "q5_equipment", answer: .multi(["gps_watch"]), accumulated: acc)?.id == "q6_freetext")
        #expect(questionnaire.nextQuestion(after: "q6_freetext", answer: .text("note"), accumulated: acc) == nil)
    }

    // MARK: - buildProfile sérialisation

    @Test
    func buildProfile_serializesAllFields() {
        let userId = UUID()
        let answers: [QuestionId: AnswerValue] = [
            "q1_level": .single("regular"),
            "q2_goal": .single("10k"),
            "q3_frequency": .single("3"),
            "q4_constraints": .multi(["knee", "back"]),
            "q5_equipment": .multi(["gps_watch", "heart_rate_monitor"])
        ]
        let history = [ConversationEntry(questionId: "q1_level", questionTextKey: "questionnaire.running.q1.text", answer: .single("regular"), askedAt: Date())]
        let profile = questionnaire.buildProfile(
            userId: userId,
            answers: answers,
            freeTextNotes: "Une note",
            history: history,
            medicalClearanceAcknowledged: false
        )

        #expect(profile.userId == userId)
        #expect(profile.sportCode == "running")
        #expect(profile.level == "regular")
        #expect(profile.goals.primary == "10k")
        #expect(profile.frequencyPerWeek == 3)
        #expect(profile.frequencyLabel == "3")
        #expect(profile.constraints == ["knee", "back"])
        #expect(profile.equipment == ["gps_watch", "heart_rate_monitor"])
        #expect(profile.freeTextNotes == "Une note")
        #expect(profile.questionnaireVersion == "running_v1")
        #expect(profile.medicalClearanceAcknowledged == false)
        #expect(profile.conversationHistory.count == 1)
    }

    @Test("freeTextNotes nil si vide après trim")
    func buildProfile_freeTextNotesNilWhenEmpty() {
        let profile = questionnaire.buildProfile(
            userId: UUID(),
            answers: ["q1_level": .single("beginner"), "q2_goal": .single("wellness"), "q3_frequency": .single("2"), "q5_equipment": .multi(["none"])],
            freeTextNotes: "   ",
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.freeTextNotes == nil)
    }

    @Test("Q4 skippée → constraints = [] (pas [\"none\"])")
    func buildProfile_Q4SkippedYieldsEmptyArray() {
        // beginner → Q4 skippée par le moteur, donc answers["q4_constraints"] absent
        let profile = questionnaire.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("beginner"),
                "q2_goal": .single("wellness"),
                "q3_frequency": .single("2"),
                "q5_equipment": .multi(["none"])
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        #expect(profile.constraints == [])  // [] explicit = question skippée
        #expect(profile.equipment == ["none"])  // ["none"] explicit = user a confirmé "rien"
    }

    @Test("frequency '4_or_more' préservé dans label, mappé à 4 dans int")
    func buildProfile_preservesFrequencyLabelFourOrMore() {
        let profile = questionnaire.buildProfile(
            userId: UUID(),
            answers: [
                "q1_level": .single("regular"),
                "q2_goal": .single("marathon"),
                "q3_frequency": .single("4_or_more"),
                "q4_constraints": .multi(["none"]),
                "q5_equipment": .multi(["gps_watch"])
            ],
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: true
        )
        #expect(profile.frequencyPerWeek == 4)
        #expect(profile.frequencyLabel == "4_or_more")
        #expect(profile.medicalClearanceAcknowledged == true)
    }
}
