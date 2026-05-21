// CoachingSageTests/Services/HealthKitSwimWorkoutDetailTests.swift
// Story 3.16 AC9 — sanity check pace + enum decoding.
// PAS de test live HealthKit (pas faisable simu/CI) : la validation de la
// lecture lap-by-lap se fait via l'écran DEBUG sur iPhone réel.
import XCTest
@testable import CoachingSage

final class HealthKitSwimWorkoutDetailTests: XCTestCase {

    // MARK: - Pace s/100m

    func testPaceCalculation_25mLapIn30s_yields120sPer100m() throws {
        let pace = try XCTUnwrap(HealthKitSwimLap.computePaceSecondsPer100m(
            durationSeconds: 30,
            distanceMeters: 25
        ))
        XCTAssertEqual(pace, 120.0, accuracy: 0.001)
    }

    func testPaceCalculation_distanceNil_yieldsNil() {
        let pace = HealthKitSwimLap.computePaceSecondsPer100m(
            durationSeconds: 30,
            distanceMeters: nil
        )
        XCTAssertNil(pace)
    }

    func testPaceCalculation_distanceZero_yieldsNil() {
        // Garde-fou division par 0.
        let pace = HealthKitSwimLap.computePaceSecondsPer100m(
            durationSeconds: 30,
            distanceMeters: 0
        )
        XCTAssertNil(pace)
    }

    // MARK: - SwimStrokeStyle decoding

    func testStrokeStyleDecoding_knownRawValues() {
        XCTAssertEqual(SwimStrokeStyle(rawValueSafe: 0), .unknown)
        XCTAssertEqual(SwimStrokeStyle(rawValueSafe: 1), .mixed)
        XCTAssertEqual(SwimStrokeStyle(rawValueSafe: 2), .freestyle)
        XCTAssertEqual(SwimStrokeStyle(rawValueSafe: 3), .backstroke)
        XCTAssertEqual(SwimStrokeStyle(rawValueSafe: 4), .breaststroke)
        XCTAssertEqual(SwimStrokeStyle(rawValueSafe: 5), .butterfly)
        XCTAssertEqual(SwimStrokeStyle(rawValueSafe: 6), .kickboard)
    }

    func testStrokeStyleDecoding_unknownRawValue_fallsBackToUnknown() {
        XCTAssertEqual(SwimStrokeStyle(rawValueSafe: 99), .unknown)
        XCTAssertEqual(SwimStrokeStyle(rawValueSafe: -1), .unknown)
    }

    // MARK: - SwimLocationType decoding

    func testLocationTypeDecoding_knownRawValues() {
        XCTAssertEqual(SwimLocationType(rawValueSafe: 0), .unknown)
        XCTAssertEqual(SwimLocationType(rawValueSafe: 1), .pool)
        XCTAssertEqual(SwimLocationType(rawValueSafe: 2), .openWater)
    }

    func testLocationTypeDecoding_unknownRawValue_fallsBackToUnknown() {
        XCTAssertEqual(SwimLocationType(rawValueSafe: 99), .unknown)
    }
}
