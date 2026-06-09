// CoachingSageTests/Coaching/Persistence/ExerciseLevelStateTests.swift
// Chantier charge muscu V2 — TRANCHE 2. Niveau relatif caché : round-trip Codable,
// clamp des bornes, niveau initial par niveau de programme.
import XCTest
@testable import CoachingSage

final class ExerciseLevelStateTests: XCTestCase {

    func test_roundTrip_codable() throws {
        let state = ExerciseLevelState(levels: [
            "squat (pattern squat)": ExerciseLevel(level: 3, consecutiveEasy: 1),
            "bench (pattern push)": ExerciseLevel(level: 4),
        ])
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(ExerciseLevelState.self, from: data)
        XCTAssertEqual(decoded, state)
        XCTAssertEqual(decoded.level(for: "squat (pattern squat)")?.consecutiveEasy, 1)
    }

    func test_emptyData_decodesToEmpty() {
        // Simule un record pré-feature (Data() vide) → .empty, pas de crash.
        let decoded = (try? JSONDecoder().decode(ExerciseLevelState.self, from: Data())) ?? .empty
        XCTAssertEqual(decoded, .empty)
    }

    func test_clamp_bounds() {
        XCTAssertEqual(ExerciseLevel(level: 9).level, 5)
        XCTAssertEqual(ExerciseLevel(level: 0).level, 1)
        XCTAssertEqual(ExerciseLevel(level: -3, consecutiveEasy: -2).level, 1)
        XCTAssertEqual(ExerciseLevel(level: 3, consecutiveEasy: -2).consecutiveEasy, 0)
    }

    func test_initialLevel_byProfileLevel() {
        XCTAssertEqual(InitialLevelResolver.initialLevel(forProfileLevel: "beginner"), 2)
        XCTAssertEqual(InitialLevelResolver.initialLevel(forProfileLevel: "competitive"), 4)
        XCTAssertEqual(InitialLevelResolver.initialLevel(forProfileLevel: "recreational"), 3)
        XCTAssertEqual(InitialLevelResolver.initialLevel(forProfileLevel: "regular"), 3)
        XCTAssertEqual(InitialLevelResolver.initialLevel(forProfileLevel: "wat"), 3)
    }
}
