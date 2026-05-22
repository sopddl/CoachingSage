// CoachingSageTests/Views/SportAvatarViewTests.swift
// Story 3.14 AC12 — résolution sport code → SF Symbol et fallback unknown.
import XCTest

final class SportAvatarViewTests: XCTestCase {
    func test_symbolName_mapsTenKnownSports() {
        let expected: [(String, String)] = [
            ("running", "figure.run"),
            ("cycling", "figure.outdoor.cycle"),
            ("swimming", "figure.pool.swim"),
            ("triathlon", "figure.mixed.cardio"),
            ("strengthTraining", "dumbbell.fill"),
            ("yoga", "figure.yoga"),
            ("hiit", "bolt.heart.fill"),
            ("hiking", "figure.hiking"),
            ("tennis", "figure.tennis"),
            ("football", "soccerball")
        ]
        for (code, symbol) in expected {
            XCTAssertEqual(
                SportAvatarView.symbolName(forSportCode: code),
                symbol,
                "sport '\(code)' devrait mapper sur '\(symbol)'"
            )
        }
    }

    func test_symbolName_acceptsSnakeCaseStrengthTraining() {
        // Couvre le bridge SportCodeMapping qui accepte aussi `strength_training`.
        XCTAssertEqual(
            SportAvatarView.symbolName(forSportCode: "strength_training"),
            "dumbbell.fill"
        )
    }

    func test_symbolName_unknownSportCode_fallsBackToQuestionmark() {
        XCTAssertEqual(
            SportAvatarView.symbolName(forSportCode: "padel"),
            "questionmark.circle.fill"
        )
        XCTAssertEqual(
            SportAvatarView.symbolName(forSportCode: ""),
            "questionmark.circle.fill"
        )
    }
}
