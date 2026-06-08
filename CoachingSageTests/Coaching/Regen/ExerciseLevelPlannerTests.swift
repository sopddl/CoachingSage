// CoachingSageTests/Coaching/Regen/ExerciseLevelPlannerTests.swift
// Chantier charge muscu V2 — TRANCHE 5. Table de transitions de l'apprentissage.
import XCTest
@testable import CoachingSage

final class ExerciseLevelPlannerTests: XCTestCase {

    private func lvl(_ l: Int, _ easy: Int = 0) -> ExerciseLevel {
        ExerciseLevel(level: l, consecutiveEasy: easy)
    }

    func test_tooHard_dropsImmediately_andResetsEasy() {
        let out = ExerciseLevelPlanner.apply(.tooHard, to: lvl(3, 1))
        XCTAssertEqual(out.level, 2)
        XCTAssertEqual(out.consecutiveEasy, 0)
    }

    func test_right_noChange_resetsEasy() {
        let out = ExerciseLevelPlanner.apply(.right, to: lvl(3, 1))
        XCTAssertEqual(out.level, 3)
        XCTAssertEqual(out.consecutiveEasy, 0)
    }

    func test_easy_firstTime_doesNotBump_butCounts() {
        let out = ExerciseLevelPlanner.apply(.easy, to: lvl(3, 0))
        XCTAssertEqual(out.level, 3)
        XCTAssertEqual(out.consecutiveEasy, 1)
    }

    func test_easy_secondConsecutive_bumps_andResets() {
        let out = ExerciseLevelPlanner.apply(.easy, to: lvl(3, 1))
        XCTAssertEqual(out.level, 4)
        XCTAssertEqual(out.consecutiveEasy, 0)
    }

    func test_maxOneCranPerCall() {
        // Même avec un gros compteur, on ne monte que d'un cran.
        let out = ExerciseLevelPlanner.apply(.easy, to: lvl(2, 9))
        XCTAssertEqual(out.level, 3)
    }

    func test_clampUpper() {
        let out = ExerciseLevelPlanner.apply(.easy, to: lvl(5, 1))
        XCTAssertEqual(out.level, 5) // déjà au max
    }

    func test_clampLower() {
        let out = ExerciseLevelPlanner.apply(.tooHard, to: lvl(1, 0))
        XCTAssertEqual(out.level, 1) // déjà au min
    }

    func test_medicalClearance_bridesIncrease_silently() {
        let out = ExerciseLevelPlanner.apply(.easy, to: lvl(3, 1), requiresMedicalClearance: true)
        XCTAssertEqual(out.level, 3) // hausse bridée
        XCTAssertEqual(out.consecutiveEasy, 0)
    }

    func test_medicalClearance_stillAllowsDecrease() {
        let out = ExerciseLevelPlanner.apply(.tooHard, to: lvl(3, 0), requiresMedicalClearance: true)
        XCTAssertEqual(out.level, 2) // baisse sécurité autorisée
    }
}
