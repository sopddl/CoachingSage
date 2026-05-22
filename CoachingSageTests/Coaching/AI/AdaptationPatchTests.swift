// CoachingSageTests/Coaching/AI/AdaptationPatchTests.swift
// Story 3.3b — tests unitaires du modèle AdaptationPatch (decoding alignement
// 1:1 avec types.ts Edge Function, hasContent flag, error mapping).
import XCTest

final class AdaptationPatchTests: XCTestCase {

    // MARK: - hasContent

    func testHasContentFalseWhenAllNil() {
        let patch = AdaptationPatch()
        XCTAssertFalse(patch.hasContent)
    }

    func testHasContentFalseWhenAllEmptyArrays() {
        let patch = AdaptationPatch(
            exerciseSubstitutions: [],
            volumeAdjustments: [],
            progressionPacing: [],
            safetyNotes: [],
            personalizationNote: ""
        )
        XCTAssertFalse(patch.hasContent)
    }

    func testHasContentTrueWithPersonalizationNoteOnly() {
        let patch = AdaptationPatch(personalizationNote: "Bien joué Sarah !")
        XCTAssertTrue(patch.hasContent)
    }

    func testHasContentTrueWithOneSubstitution() {
        let patch = AdaptationPatch(exerciseSubstitutions: [
            .init(weekNumber: 2, day: 3, originalExerciseName: "Pliométrie",
                  replacementExerciseName: "Marche nordique", reason: "knee")
        ])
        XCTAssertTrue(patch.hasContent)
    }

    // MARK: - JSON decoding alignment with types.ts

    func testDecodeFullPatchFromServerJSON() throws {
        let json = """
        {
          "exercise_substitutions": [
            {
              "week_number": 2,
              "day": 3,
              "original_exercise_name": "Plyo",
              "replacement_exercise_name": "Marche nordique",
              "reason": "Genou sensible"
            }
          ],
          "volume_adjustments": [
            {
              "week_number": 1,
              "day": null,
              "exercise_name": null,
              "adjustment": "Réduire de 15%",
              "reason": "Reprise après pause"
            }
          ],
          "progression_pacing": [
            {
              "week_number": 3,
              "adjustment": "RPE 6 au lieu de 7",
              "reason": "Charge trop forte W2"
            }
          ],
          "safety_notes": ["Bien hydrater"],
          "personalization_note": "Tu enchaînes 4 séances/sem, Sarah, on pousse."
        }
        """
        let patch = try JSONDecoder().decode(AdaptationPatch.self, from: Data(json.utf8))

        XCTAssertEqual(patch.exerciseSubstitutions?.count, 1)
        XCTAssertEqual(patch.exerciseSubstitutions?.first?.weekNumber, 2)
        XCTAssertEqual(patch.exerciseSubstitutions?.first?.replacementExerciseName, "Marche nordique")

        XCTAssertEqual(patch.volumeAdjustments?.count, 1)
        XCTAssertNil(patch.volumeAdjustments?.first?.day)
        XCTAssertNil(patch.volumeAdjustments?.first?.exerciseName)

        XCTAssertEqual(patch.progressionPacing?.first?.weekNumber, 3)
        XCTAssertEqual(patch.safetyNotes, ["Bien hydrater"])
        XCTAssertEqual(patch.personalizationNote, "Tu enchaînes 4 séances/sem, Sarah, on pousse.")
        XCTAssertTrue(patch.hasContent)
    }

    func testDecodeEmptyPatch() throws {
        let json = "{}"
        let patch = try JSONDecoder().decode(AdaptationPatch.self, from: Data(json.utf8))
        XCTAssertNil(patch.exerciseSubstitutions)
        XCTAssertNil(patch.personalizationNote)
        XCTAssertFalse(patch.hasContent)
    }

    // MARK: - AdaptRareResponse decoding

    func testDecodeAdaptRareResponseWithFractionalSecondsDate() throws {
        // Format réel renvoyé par l'Edge Function (TS Date.toISOString() inclut les ms).
        // Le decoder custom du service supporte ce format ET le format sans ms.
        let json = """
        {
          "patch": {"personalization_note": "GG"},
          "quota": {
            "used": 3,
            "limit": 10,
            "resets_at": "2026-05-11T00:00:00.000Z",
            "tier": "free"
          },
          "meta": {
            "model": "claude-haiku-4-5",
            "prompt_version": "1.1.0",
            "duration_ms": 4123
          }
        }
        """
        let response = try Self.decodeWithCustomISO8601(AdaptRareResponse.self, json: json)
        XCTAssertEqual(response.patch.personalizationNote, "GG")
        XCTAssertEqual(response.quota.used, 3)
        XCTAssertEqual(response.quota.limit, 10)
        XCTAssertEqual(response.quota.tier, "free")
        XCTAssertEqual(response.meta?.model, "claude-haiku-4-5")
    }

    func testDecodeAdaptRareResponseWithoutFractionalSecondsDate() throws {
        // Robustesse : format sans ms doit aussi marcher (au cas où le serveur change).
        let json = """
        {
          "patch": {},
          "quota": {"used": 1, "limit": 10, "resets_at": "2026-05-11T00:00:00Z", "tier": "free"},
          "meta": null
        }
        """
        let response = try Self.decodeWithCustomISO8601(AdaptRareResponse.self, json: json)
        XCTAssertEqual(response.quota.used, 1)
        XCTAssertNil(response.meta)
    }

    /// Réplique la stratégie de decoder du `DefaultSageCoachingAIService` (custom
    /// ISO8601 avec/sans fractional seconds). Si le service change, mettre à jour ici.
    private static func decodeWithCustomISO8601<T: Decodable>(_ type: T.Type, json: String) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateStr) { return date }
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateStr) { return date }
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: "Invalid ISO8601: \(dateStr)"
            )
        }
        return try decoder.decode(T.self, from: Data(json.utf8))
    }

    // MARK: - mapErrorResponse

    func testMapQuotaExceededErrorWithResetDate() {
        let json = """
        {"error":{"code":"quota_exceeded","message":"...","quota_resets_at":"2026-05-10T00:00:00Z"}}
        """
        let error = DefaultSageCoachingAIService.mapErrorResponse(data: Data(json.utf8), statusCode: 429)
        guard case let .quotaExceeded(resetsAt) = error else {
            return XCTFail("Expected .quotaExceeded, got \(error)")
        }
        XCTAssertNotNil(resetsAt)
    }

    func testMapAnthropicUnavailableError() {
        let json = """
        {"error":{"code":"anthropic_unavailable","message":"down"}}
        """
        let error = DefaultSageCoachingAIService.mapErrorResponse(data: Data(json.utf8), statusCode: 502)
        XCTAssertEqual(error, .anthropicUnavailable)
    }

    func testMapInvalidPatchError() {
        let json = """
        {"error":{"code":"invalid_patch","message":"banned word"}}
        """
        let error = DefaultSageCoachingAIService.mapErrorResponse(data: Data(json.utf8), statusCode: 502)
        XCTAssertEqual(error, .invalidPatch)
    }

    func testMapUnauthorizedError() {
        let json = """
        {"error":{"code":"unauthorized","message":"invalid token"}}
        """
        let error = DefaultSageCoachingAIService.mapErrorResponse(data: Data(json.utf8), statusCode: 401)
        XCTAssertEqual(error, .unauthorized)
    }

    func testMapInvalidRequestError() {
        let json = """
        {"error":{"code":"invalid_request","message":"mode unknown"}}
        """
        let error = DefaultSageCoachingAIService.mapErrorResponse(data: Data(json.utf8), statusCode: 400)
        XCTAssertEqual(error, .invalidRequest("mode unknown"))
    }

    func testMapFallbackToServerErrorOnUnknownPayload() {
        let error = DefaultSageCoachingAIService.mapErrorResponse(data: Data("garbage".utf8), statusCode: 500)
        XCTAssertEqual(error, .server(500))
    }

    func testMapStatusCode401WithoutPayloadReturnsUnauthorized() {
        let error = DefaultSageCoachingAIService.mapErrorResponse(data: Data(), statusCode: 401)
        XCTAssertEqual(error, .unauthorized)
    }

    func testMapStatusCode429WithoutPayloadReturnsQuotaExceeded() {
        let error = DefaultSageCoachingAIService.mapErrorResponse(data: Data(), statusCode: 429)
        XCTAssertEqual(error, .quotaExceeded(resetsAt: nil))
    }

    // MARK: - encodeRequestBody shape

    func testEncodeRequestBodyShapeMatchesEdgeFunctionContract() throws {
        let templateJSON = Data(#"{"id":"running-beginner-c25k","sport":"running"}"#.utf8)
        let profileJSON = Data(#"{"first_name":"Sarah","language":"fr"}"#.utf8)
        let adaptedJSON = Data(#"{"templateId":"running-beginner-c25k","sport":"running"}"#.utf8)
        let summary = HealthSummary(
            vo2maxBucket: .advanced,
            restingHeartRateBpm: 58,
            maxObservedHeartRateBpm: 190,
            weeklyWorkoutsAverage4w: 3.0,
            recentWorkouts: [],
            hasAppleWatch: true
        )

        let body = try DefaultSageCoachingAIService.encodeRequestBody(
            triggeredReason: .atypicalConstraints,
            templateJSON: templateJSON,
            profileJSON: profileJSON,
            healthSummary: summary,
            adaptedProgramJSON: adaptedJSON
        )

        let parsed = try XCTUnwrap(try JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(parsed["mode"] as? String, "adapt-rare")
        XCTAssertEqual(parsed["triggered_reason"] as? String, "atypical_constraints")

        let template = try XCTUnwrap(parsed["template_json"] as? [String: Any])
        XCTAssertEqual(template["id"] as? String, "running-beginner-c25k")

        let profile = try XCTUnwrap(parsed["profile_json"] as? [String: Any])
        XCTAssertEqual(profile["first_name"] as? String, "Sarah")

        let healthDict = try XCTUnwrap(parsed["health_summary"] as? [String: Any])
        XCTAssertEqual(healthDict["vo2max_bucket"] as? String, "advanced")
        XCTAssertEqual(healthDict["resting_heart_rate_bpm"] as? Int, 58)

        XCTAssertNotNil(parsed["adapted_program_json"])
    }

    func testEncodeRequestBodyThrowsOnInvalidTemplateJSON() {
        let invalidJSON = Data("not json".utf8)
        XCTAssertThrowsError(try DefaultSageCoachingAIService.encodeRequestBody(
            triggeredReason: .userExplicit,
            templateJSON: invalidJSON,
            profileJSON: Data("{}".utf8),
            healthSummary: HealthSummary(),
            adaptedProgramJSON: Data("{}".utf8)
        ))
    }
}
