// CoachingSageTests/Coaching/Session/SessionExecutionModeTests.swift
// Story 3.33 (AC0) — routage de la façon d'avancer + fallback gracieux Manuel +
// triathlon hérite de sa discipline.
import XCTest
@testable import CoachingSage
import TemplateModel

final class SessionExecutionModeTests: XCTestCase {

    // MARK: - target (mode cible idéal)

    func test_target_strength_isManual() {
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "strengthTraining", sessionType: .strength), .manual)
    }

    func test_target_hiitAndYoga_areTimed() {
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "hiit", sessionType: .interval), .timed)
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "yoga", sessionType: .mobility), .timed)
    }

    func test_target_cardio_isAudio() {
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "running", sessionType: .endurance), .audio)
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "cycling", sessionType: .endurance), .audio)
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "hiking", sessionType: .endurance), .audio)
    }

    func test_target_swim_isWatch() {
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "swimming", sessionType: .technique), .watch)
    }

    func test_target_triathlon_inheritsDiscipline() {
        // Côté HUB, triathlon est résolu en discipline (ici cycling → audio).
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "cycling", sessionType: .endurance), .audio)
        // Discipline natation → watch.
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "swimming", sessionType: .technique), .watch)
    }

    func test_target_unknownSport_usesSessionType() {
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "tennis", sessionType: .interval), .timed)
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "tennis", sessionType: .endurance), .audio)
        XCTAssertEqual(SessionExecutionMode.target(sportCode: "tennis", sessionType: .strength), .manual)
    }

    // MARK: - available (fallback gracieux jusqu'à livraison 3.35-3.36)

    func test_available_timedShipped_hiitAndYogaUseTimed() {
        // Depuis 3.34, Minuté est embarqué → HIIT/yoga avancent au chrono.
        XCTAssertEqual(SessionExecutionMode.available(sportCode: "hiit", sessionType: .interval), .timed)
        XCTAssertEqual(SessionExecutionMode.available(sportCode: "yoga", sessionType: .mobility), .timed)
    }

    func test_available_audioAndWatchNotShipped_fallBackToManual() {
        // Audio (3.35) et Montre (3.36) pas encore embarqués → fallback Manuel.
        for code in ["running", "cycling", "hiking", "swimming"] {
            XCTAssertEqual(
                SessionExecutionMode.available(sportCode: code, sessionType: .endurance), .manual,
                "fallback Manuel attendu pour \(code) (audio/watch non livrés)"
            )
        }
    }

    func test_available_manualTargetStaysManual() {
        XCTAssertEqual(SessionExecutionMode.available(sportCode: "strengthTraining", sessionType: .strength), .manual)
    }

    func test_shippedModes_containsManualAndTimed() {
        XCTAssertEqual(SessionExecutionMode.shippedModes, [.manual, .timed])
    }
}
