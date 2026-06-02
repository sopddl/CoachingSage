// CoachingSageTests/Coaching/Swim/SwimLevelEstimatorTests.swift
// Story 3.16 Phase 2.B — tests de l'estimateur de niveau natation.
import XCTest
@testable import CoachingSage

final class SwimLevelEstimatorTests: XCTestCase {

    private func summary(
        sessions: Int,
        totalMeters: Double,
        bestPace: Double?
    ) -> SwimSummary {
        SwimSummary(
            sessionCount: sessions,
            windowWeeks: 12,
            activeWeeks: max(1, sessions),
            totalDistanceMeters: totalMeters,
            weeklyAverageDistanceMeters: totalMeters / 12,
            weeklyAverageSessions: Double(sessions) / 12,
            avgPaceSecondsPer100m: bestPace,
            bestPaceSecondsPer100m: bestPace,
            strokeDistribution: [:],
            longestSessionDistanceMeters: sessions > 0 ? totalMeters / Double(sessions) : nil,
            sessions: []
        )
    }

    func testNoSessions_returnsNil() {
        XCTAssertNil(SwimLevelEstimator.estimate(from: summary(sessions: 0, totalMeters: 0, bestPace: nil)))
    }

    func testCompetitive_requiresBigSessionAndFastPace() {
        // 3000 m/séance + 90 s/100m → competitive.
        let s = summary(sessions: 4, totalMeters: 12_000, bestPace: 90)
        XCTAssertEqual(SwimLevelEstimator.estimate(from: s), "competitive")
    }

    func testBigSessionButSlowPace_notCompetitive_butRegular() {
        // 3000 m/séance mais 130 s/100m → pas competitive (pace), mais regular (volume).
        let s = summary(sessions: 4, totalMeters: 12_000, bestPace: 130)
        XCTAssertEqual(SwimLevelEstimator.estimate(from: s), "regular")
    }

    func testOccasionalButCapableSwimmer_isRegularViaPace() {
        // Cas Sophie : peu de séances mais 1500 m à allure solide (97 s/100m).
        // avgSession 1500 (>=1500 → regular par volume) ET pace 97 (<=110) → regular.
        let s = summary(sessions: 2, totalMeters: 3000, bestPace: 97)
        XCTAssertEqual(SwimLevelEstimator.estimate(from: s), "regular")
    }

    func testRegularViaPaceOnly_smallSessions() {
        // Petites séances (800 m) mais allure rapide (105) → regular via pace.
        let s = summary(sessions: 3, totalMeters: 2400, bestPace: 105)
        XCTAssertEqual(SwimLevelEstimator.estimate(from: s), "regular")
    }

    func testRecreational_moderateVolumeNoPace() {
        // 700 m/séance, pace inconnue → recreational.
        let s = summary(sessions: 3, totalMeters: 2100, bestPace: nil)
        XCTAssertEqual(SwimLevelEstimator.estimate(from: s), "recreational")
    }

    func testBeginner_lowVolumeSlowPace() {
        // 400 m/séance, allure lente → beginner.
        let s = summary(sessions: 2, totalMeters: 800, bestPace: 160)
        XCTAssertEqual(SwimLevelEstimator.estimate(from: s), "beginner")
    }
}
