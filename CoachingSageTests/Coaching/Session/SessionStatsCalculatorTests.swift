// CoachingSageTests/Coaching/Session/SessionStatsCalculatorTests.swift
// Story 3.18 Phase 2 — tests heuristique stats SessionDetail hero.
import XCTest
import SwiftUI
@testable import CoachingSage
import TemplateModel

final class SessionStatsCalculatorTests: XCTestCase {

    // MARK: - dominantZone

    func test_dominantZone_emptyExercises_returnsNil() {
        let s = makeSession(type: .endurance, exercises: [])
        XCTAssertNil(SessionStatsCalculator.dominantZone(for: s))
    }

    func test_dominantZone_allNilZones_returnsNil() {
        let s = makeSession(type: .endurance, exercises: [
            ex(zone: nil), ex(zone: nil)
        ])
        XCTAssertNil(SessionStatsCalculator.dominantZone(for: s))
    }

    func test_dominantZone_singleExo_returnsItsZone() {
        let s = makeSession(type: .endurance, exercises: [ex(zone: "Daniels-E")])
        XCTAssertEqual(SessionStatsCalculator.dominantZone(for: s), "Daniels-E")
    }

    func test_dominantZone_majoritary_returnsTheMajority() {
        let s = makeSession(type: .interval, exercises: [
            ex(zone: "Daniels-I"), ex(zone: "Daniels-I"), ex(zone: "Daniels-E")
        ])
        XCTAssertEqual(SessionStatsCalculator.dominantZone(for: s), "Daniels-I")
    }

    func test_dominantZone_tiebreak_firstSeenWins() {
        let s = makeSession(type: .mixed, exercises: [
            ex(zone: "Z2"), ex(zone: "Daniels-T")
        ])
        XCTAssertEqual(SessionStatsCalculator.dominantZone(for: s), "Z2")
    }

    func test_dominantZone_ignoresEmptyStrings() {
        let s = makeSession(type: .endurance, exercises: [
            ex(zone: ""), ex(zone: "Daniels-M"), ex(zone: "")
        ])
        XCTAssertEqual(SessionStatsCalculator.dominantZone(for: s), "Daniels-M")
    }

    // MARK: - estimatedRPE — base par type

    func test_estimatedRPE_endurance_returnsBase4() {
        XCTAssertEqual(SessionStatsCalculator.estimatedRPE(for: makeSession(type: .endurance, exercises: [])), 4)
    }

    func test_estimatedRPE_interval_returnsBase8() {
        XCTAssertEqual(SessionStatsCalculator.estimatedRPE(for: makeSession(type: .interval, exercises: [])), 8)
    }

    func test_estimatedRPE_strength_returnsBase7() {
        XCTAssertEqual(SessionStatsCalculator.estimatedRPE(for: makeSession(type: .strength, exercises: [])), 7)
    }

    func test_estimatedRPE_mobility_returnsBase2() {
        XCTAssertEqual(SessionStatsCalculator.estimatedRPE(for: makeSession(type: .mobility, exercises: [])), 2)
    }

    func test_estimatedRPE_rest_returnsBase1() {
        XCTAssertEqual(SessionStatsCalculator.estimatedRPE(for: makeSession(type: .rest, exercises: [])), 1)
    }

    func test_estimatedRPE_other_returnsBase5() {
        XCTAssertEqual(SessionStatsCalculator.estimatedRPE(for: makeSession(type: .other, exercises: [])), 5)
    }

    // MARK: - estimatedRPE — adjustments

    func test_estimatedRPE_endurance_withHighZone_adjustsUp() {
        // Endurance base 4 + Daniels-T = high → 5
        let s = makeSession(type: .endurance, exercises: [ex(zone: "Daniels-T")])
        XCTAssertEqual(SessionStatsCalculator.estimatedRPE(for: s), 5)
    }

    func test_estimatedRPE_endurance_withLowZone_adjustsDown() {
        // Endurance base 4 + Daniels-E = low → 3
        let s = makeSession(type: .endurance, exercises: [ex(zone: "Daniels-E")])
        XCTAssertEqual(SessionStatsCalculator.estimatedRPE(for: s), 3)
    }

    func test_estimatedRPE_interval_withHighZone_clampsAt10() {
        // Interval base 8 + Daniels-I high = 9 (under 10, ok)
        let s = makeSession(type: .interval, exercises: [ex(zone: "Daniels-I")])
        XCTAssertEqual(SessionStatsCalculator.estimatedRPE(for: s), 9)
    }

    func test_estimatedRPE_rest_withHighZone_clampsAt1Floor() {
        // Rest base 1 + low = should clamp at 1 (cannot go below)
        let s = makeSession(type: .rest, exercises: [ex(zone: "Daniels-E")])
        XCTAssertEqual(SessionStatsCalculator.estimatedRPE(for: s), 1)
    }

    func test_estimatedRPE_unrecognizedZone_noAdjustment() {
        // Endurance base 4 + zone exotique → 4 (pas d'ajustement)
        let s = makeSession(type: .endurance, exercises: [ex(zone: "ZONE-XYZ")])
        XCTAssertEqual(SessionStatsCalculator.estimatedRPE(for: s), 4)
    }

    // MARK: - zoneAdjustment

    func test_zoneAdjustment_nilOrEmpty_returnsZero() {
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment(nil), 0)
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment(""), 0)
    }

    func test_zoneAdjustment_highMarkers_returnPlusOne() {
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment("Daniels-T"), 1)
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment("Daniels-I"), 1)
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment("FTP-Z4"), 1)
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment("Threshold"), 1)
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment("VO2max"), 1)
    }

    func test_zoneAdjustment_lowMarkers_returnMinusOne() {
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment("Daniels-E"), -1)
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment("FTP-Z2"), -1)
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment("EN1"), -1)
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment("Recovery"), -1)
    }

    func test_zoneAdjustment_caseInsensitive() {
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment("daniels-t"), 1)
        XCTAssertEqual(SessionStatsCalculator.zoneAdjustment("DANIELS-E"), -1)
    }

    // MARK: - rpeColor

    func test_rpeColor_lowRPE_returnsSuccess() {
        // 1-4 → success
        XCTAssertEqual(SessionStatsCalculator.rpeColor(1), Color.coachingSuccess)
        XCTAssertEqual(SessionStatsCalculator.rpeColor(4), Color.coachingSuccess)
    }

    func test_rpeColor_midRPE_returnsWarning() {
        // 5-7 → warning
        XCTAssertEqual(SessionStatsCalculator.rpeColor(5), Color.coachingWarning)
        XCTAssertEqual(SessionStatsCalculator.rpeColor(7), Color.coachingWarning)
    }

    func test_rpeColor_highRPE_returnsError() {
        // 8+ → error
        XCTAssertEqual(SessionStatsCalculator.rpeColor(8), Color.coachingError)
        XCTAssertEqual(SessionStatsCalculator.rpeColor(10), Color.coachingError)
    }

    // MARK: - displayZone

    func test_displayZone_danielsCompactsToDx() {
        XCTAssertEqual(SessionStatsCalculator.displayZone("Daniels-E"), "D-E")
        XCTAssertEqual(SessionStatsCalculator.displayZone("Daniels-M"), "D-M")
        XCTAssertEqual(SessionStatsCalculator.displayZone("Daniels-T"), "D-T")
        XCTAssertEqual(SessionStatsCalculator.displayZone("Daniels-I"), "D-I")
        XCTAssertEqual(SessionStatsCalculator.displayZone("Daniels-R"), "D-R")
    }

    func test_displayZone_sweetspotCompactsToSS() {
        XCTAssertEqual(SessionStatsCalculator.displayZone("Sweetspot"), "SS")
        XCTAssertEqual(SessionStatsCalculator.displayZone("sweet-spot"), "SS")
    }

    func test_displayZone_shortZonesPassthrough() {
        XCTAssertEqual(SessionStatsCalculator.displayZone("Z2"), "Z2")
        XCTAssertEqual(SessionStatsCalculator.displayZone("EN1"), "EN1")
        XCTAssertEqual(SessionStatsCalculator.displayZone("FTP-Z2"), "FTP-Z2")
        XCTAssertEqual(SessionStatsCalculator.displayZone("race.pace"), "race.pace")
    }

    // MARK: - effortLevel (Story 3.19 Jalon 3)

    func test_effortLevel_rpe1_returnsLevel1() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 1), 1)
    }

    func test_effortLevel_rpe2_returnsLevel1() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 2), 1)
    }

    func test_effortLevel_rpe3_returnsLevel2() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 3), 2)
    }

    func test_effortLevel_rpe4_returnsLevel2() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 4), 2)
    }

    func test_effortLevel_rpe5_returnsLevel3() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 5), 3)
    }

    func test_effortLevel_rpe6_returnsLevel3() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 6), 3)
    }

    func test_effortLevel_rpe7_returnsLevel4() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 7), 4)
    }

    func test_effortLevel_rpe8_returnsLevel4() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 8), 4)
    }

    func test_effortLevel_rpe9_returnsLevel5() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 9), 5)
    }

    func test_effortLevel_rpe10_returnsLevel5() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 10), 5)
    }

    func test_effortLevel_belowRange_clampedToLevel1() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 0), 1)
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: -5), 1)
    }

    func test_effortLevel_aboveRange_clampedToLevel5() {
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 11), 5)
        XCTAssertEqual(SessionStatsCalculator.effortLevel(rpe: 99), 5)
    }

    // MARK: - effortLabel

    func test_effortLabel_returnsExpectedKeysForEachLevel() {
        XCTAssertEqual(SessionStatsCalculator.effortLabel(level: 1), "coaching.effort.level.1")
        XCTAssertEqual(SessionStatsCalculator.effortLabel(level: 2), "coaching.effort.level.2")
        XCTAssertEqual(SessionStatsCalculator.effortLabel(level: 3), "coaching.effort.level.3")
        XCTAssertEqual(SessionStatsCalculator.effortLabel(level: 4), "coaching.effort.level.4")
        XCTAssertEqual(SessionStatsCalculator.effortLabel(level: 5), "coaching.effort.level.5")
    }

    func test_effortLabel_clampsOutOfRange() {
        XCTAssertEqual(SessionStatsCalculator.effortLabel(level: 0), "coaching.effort.level.1")
        XCTAssertEqual(SessionStatsCalculator.effortLabel(level: -3), "coaching.effort.level.1")
        XCTAssertEqual(SessionStatsCalculator.effortLabel(level: 6), "coaching.effort.level.5")
        XCTAssertEqual(SessionStatsCalculator.effortLabel(level: 99), "coaching.effort.level.5")
    }

    // MARK: - Helpers

    private func makeSession(type: SessionType, exercises: [AdaptedExercise]) -> AdaptedSession {
        AdaptedSession(
            day: 1,
            name: "Test",
            durationMinutes: 30,
            type: type,
            warmup: nil,
            exercises: exercises,
            cooldown: nil
        )
    }

    private func ex(zone: String?) -> AdaptedExercise {
        AdaptedExercise(
            name: "Exo",
            originalName: "Exo",
            targetZone: zone
        )
    }
}
