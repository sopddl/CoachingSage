// CoachingSageTests/Services/HealthKitProfileDataTests.swift
// Story 2.1 — sanity check struct Equatable + 4 champs optionnels.
import XCTest
import HealthKit
@testable import CoachingSage

final class HealthKitProfileDataTests: XCTestCase {

    func testEquatableConsidersAllFields() {
        let a = HealthKitProfileData(biologicalSex: .female, dateOfBirth: Date(timeIntervalSince1970: 0), bodyMassKg: 60, heightCm: 170)
        let b = HealthKitProfileData(biologicalSex: .female, dateOfBirth: Date(timeIntervalSince1970: 0), bodyMassKg: 60, heightCm: 170)
        XCTAssertEqual(a, b)

        let c = HealthKitProfileData(biologicalSex: .male, dateOfBirth: Date(timeIntervalSince1970: 0), bodyMassKg: 60, heightCm: 170)
        XCTAssertNotEqual(a, c)

        let allNil = HealthKitProfileData(biologicalSex: nil, dateOfBirth: nil, bodyMassKg: nil, heightCm: nil)
        XCTAssertNotEqual(a, allNil)
    }
}
