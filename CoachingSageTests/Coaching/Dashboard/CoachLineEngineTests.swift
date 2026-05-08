// CoachingSageTests/Coaching/Dashboard/CoachLineEngineTests.swift
// Story 3.8 sous-tâche 8 — couvre le mapping deterministic mood → hint key
// (pas d'IA, validation EU MDR garde-fou cf epic3_leon_legal_constraints).
import XCTest
@testable import CoachingSage

@MainActor
final class CoachLineEngineTests: XCTestCase {

    func testMoodFreshWhenNoCompletion() {
        XCTAssertEqual(CoachLineEngine().mood(weeklyCompletedCount: 0), .fresh)
    }

    func testMoodWarmingUpWhenOneCompletion() {
        XCTAssertEqual(CoachLineEngine().mood(weeklyCompletedCount: 1), .warmingUp)
    }

    func testMoodBalancedWhenTwoCompletions() {
        XCTAssertEqual(CoachLineEngine().mood(weeklyCompletedCount: 2), .balanced)
    }

    func testMoodIntenseWhenThreeOrMoreCompletions() {
        XCTAssertEqual(CoachLineEngine().mood(weeklyCompletedCount: 3), .intense)
        XCTAssertEqual(CoachLineEngine().mood(weeklyCompletedCount: 7), .intense)
    }

    func testRestDayHintIsDeterministic() {
        let engine = CoachLineEngine()
        let first = engine.restDayHint(weeklyCompletedCount: 2)
        let second = engine.restDayHint(weeklyCompletedCount: 2)
        // LocalizedStringKey n'est pas Equatable directement — on vérifie la stabilité
        // via un wrapper Mirror (suffisant pour ce contrôle deterministic).
        XCTAssertEqual(String(describing: first), String(describing: second))
    }
}
