// CoachingSageTests/Coaching/Persistence/ExerciseWeightStateTests.swift
// Chantier charge muscu V2 — increment 2 (décision B). Poids noté par exo : round-trip
// Codable + migration record pré-feature (Data() vide → .empty).
import XCTest
@testable import CoachingSage

final class ExerciseWeightStateTests: XCTestCase {

    func test_roundTrip_codable() throws {
        let state = ExerciseWeightState(weights: [
            "Goblet squat": 22.5,
            "Romanian Deadlift": 40,
        ])
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(ExerciseWeightState.self, from: data)
        XCTAssertEqual(decoded, state)
        XCTAssertEqual(decoded.weight(for: "Goblet squat"), 22.5)
    }

    func test_emptyData_decodesToEmpty() {
        // Simule un record pré-feature (Data() vide) → .empty, pas de crash.
        let decoded = (try? JSONDecoder().decode(ExerciseWeightState.self, from: Data())) ?? .empty
        XCTAssertEqual(decoded, .empty)
    }

    func test_weight_forUnknownKey_isNil() {
        XCTAssertNil(ExerciseWeightState.empty.weight(for: "x"))
    }
}
