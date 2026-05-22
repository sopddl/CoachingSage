// CoachingSageTests/Questionnaires/UniversalQuestionnaireSupabaseConstraintTests.swift
// Hotfix CHECK constraint Supabase `coaching_sport_profiles_target_date_consistency` :
// vérifie que le JSON sérialisé qui PARTIRAIT à Supabase respecte la contrainte
// `(duration_mode = 'routineCyclic' AND target_date IS NULL) OR
//  (duration_mode IN ('deadlineFixed', 'deadlineEstimated') AND target_date IS NOT NULL)`
// pour les 3 modes possibles depuis le questionnaire universel.
//
// Avant ce hotfix, le mode `deadlineEstimated` envoyait `target_date=null` →
// INSERT rejeté + bandeau d'erreur Supabase rouge en bas du questionnaire.
import XCTest

final class UniversalQuestionnaireSupabaseConstraintTests: XCTestCase {

    // MARK: - Helpers

    private func buildAndEncode(answers: [QuestionId: AnswerValue], sportCode: String = "running") throws -> (json: [String: Any], profile: CoachingSportProfile) {
        let q = UniversalQuestionnaire(sportCode: sportCode)
        let profile = q.buildProfile(
            userId: UUID(),
            answers: answers,
            freeTextNotes: nil,
            history: [],
            medicalClearanceAcknowledged: false
        )
        let dto = CoachingSportProfileUpsertDTO(from: profile)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(dto)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        return (json, profile)
    }

    // MARK: - deadlineEstimated (Q4=let_me_estimate)

    func test_letMeEstimate_payloadIncludesTargetDate() throws {
        // Reproduction exacte du flow user qui a crashé : Loisir (recreational)
        // + 10 km + 2 par semaine + "Je ne sais pas — propose-moi un délai".
        let (json, profile) = try buildAndEncode(answers: [
            "q1_level": .single("recreational"),
            "q2_goal": .single("10k"),
            "q3_frequency": .single("2"),
            "q4_duration": .single(UniversalQuestionnaire.q4LetMeEstimateCode)
        ])

        // Côté Swift
        XCTAssertEqual(profile.durationMode, .deadlineEstimated)
        XCTAssertNotNil(profile.targetDate, "targetDate doit être pré-calculée pour respecter la CHECK constraint")

        // Côté JSON (= ce que Supabase recevra)
        XCTAssertEqual(json["duration_mode"] as? String, "deadlineEstimated")
        XCTAssertNotNil(json["target_date"], "target_date ne doit pas être null dans le payload Supabase")
        let targetDateString = try XCTUnwrap(json["target_date"] as? String)
        XCTAssertFalse(targetDateString.isEmpty, "target_date doit être un ISO8601 non vide")
    }

    // MARK: - routineCyclic (Q3=dont_know)

    func test_dontKnowFrequency_payloadHasNullTargetDate() throws {
        let (json, profile) = try buildAndEncode(answers: [
            "q1_level": .single("beginner"),
            "q2_goal": .single("general-form"),
            "q3_frequency": .single(UniversalQuestionnaire.q3DontKnowCode)
        ])
        XCTAssertEqual(profile.durationMode, .routineCyclic)
        XCTAssertNil(profile.targetDate)
        XCTAssertEqual(json["duration_mode"] as? String, "routineCyclic")
        XCTAssertTrue(
            json["target_date"] is NSNull || json["target_date"] == nil,
            "target_date doit être null pour routineCyclic (CHECK constraint)"
        )
    }

    // MARK: - deadlineFixed (Q4=target_date avec date)

    func test_targetDateMode_payloadIncludesTargetDate() throws {
        let futureISO = ISO8601DateFormatter().string(from: Date().addingTimeInterval(60 * 86_400)) // J+60
        let (json, profile) = try buildAndEncode(answers: [
            "q1_level": .single("regular"),
            "q2_goal": .single("10k"),
            "q3_frequency": .single("3"),
            "q4_duration": .single(UniversalQuestionnaire.q4TargetDateCode),
            "q4_date": .text(futureISO)
        ])
        XCTAssertEqual(profile.durationMode, .deadlineFixed)
        XCTAssertNotNil(profile.targetDate)
        XCTAssertEqual(json["duration_mode"] as? String, "deadlineFixed")
        XCTAssertNotNil(json["target_date"])
    }

    // MARK: - routineCyclic (Q4=routine_3_months)

    // MARK: - triathlon + sprint + routine — reproduit bug Sophie 2026-05-20

    func test_triathlonSprintRoutine_targetDateKeyExplicitlyPresent() throws {
        // Hotfix 2026-05-20 : avec le default JSONEncoder, `target_date` était
        // ABSENT du payload (Optional nil → omis). L'UPSERT Supabase laissait
        // alors une ancienne `target_date` non-null en DB → violation CHECK.
        // Désormais le DTO custom-encode force `target_date: null` explicite.
        let (json, profile) = try buildAndEncode(answers: [
            "q1_level": .single("recreational"),
            "q2_goal": .single("sprint"),
            "q3_frequency": .single("2"),
            "q4_duration": .single(UniversalQuestionnaire.q4Routine3MonthsCode)
        ], sportCode: "triathlon")
        XCTAssertEqual(profile.durationMode, .routineCyclic)
        XCTAssertNil(profile.targetDate)
        XCTAssertEqual(json["duration_mode"] as? String, "routineCyclic")
        // Le test critique : la KEY `target_date` DOIT être présente dans le JSON
        // (avec une valeur null), pas absente.
        XCTAssertTrue(
            json.keys.contains("target_date"),
            "target_date doit apparaître explicitement dans le JSON pour qu'un UPSERT efface une ancienne valeur"
        )
        XCTAssertTrue(
            json["target_date"] is NSNull,
            "target_date doit être NSNull (= JSON null), pas une date résiduelle"
        )
    }

    func test_routine3Months_payloadHasNullTargetDate() throws {
        let (json, profile) = try buildAndEncode(answers: [
            "q1_level": .single("recreational"),
            "q2_goal": .single("10k"),
            "q3_frequency": .single("2"),
            "q4_duration": .single(UniversalQuestionnaire.q4Routine3MonthsCode)
        ])
        XCTAssertEqual(profile.durationMode, .routineCyclic)
        XCTAssertNil(profile.targetDate)
        XCTAssertEqual(json["duration_mode"] as? String, "routineCyclic")
        XCTAssertTrue(json["target_date"] is NSNull || json["target_date"] == nil)
    }
}
