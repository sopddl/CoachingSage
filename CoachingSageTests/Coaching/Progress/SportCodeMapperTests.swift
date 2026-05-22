// CoachingSageTests/Coaching/Progress/SportCodeMapperTests.swift
// Story 3.9 — mapping app SportCode ↔ HKWorkoutActivityType (bloc Volume par sport).
import XCTest
import HealthKit

final class SportCodeMapperTests: XCTestCase {

    func testEverySportCodeMapsToHKActivityType() {
        // V1 : tous les 10 SportCode doivent renvoyer un HKWorkoutActivityType
        // (même si triathlon → .other faute de type dédié côté HK).
        for sport in SportCode.allCases {
            let type = SportCodeMapper.toHKWorkoutActivityType(sport)
            XCTAssertNotNil(HKWorkoutActivityType(rawValue: type.rawValue), "SportCode \(sport) → activityType invalide")
        }
    }

    func testCommonHKTypesMapToSportCode() {
        XCTAssertEqual(SportCodeMapper.fromHKWorkoutActivityType(HKWorkoutActivityType.running.rawValue), .running)
        XCTAssertEqual(SportCodeMapper.fromHKWorkoutActivityType(HKWorkoutActivityType.cycling.rawValue), .cycling)
        XCTAssertEqual(SportCodeMapper.fromHKWorkoutActivityType(HKWorkoutActivityType.swimming.rawValue), .swimming)
        XCTAssertEqual(SportCodeMapper.fromHKWorkoutActivityType(HKWorkoutActivityType.yoga.rawValue), .yoga)
    }

    func testStrengthTrainingFamiliesAllMapToStrengthTraining() {
        let families: [HKWorkoutActivityType] = [
            .traditionalStrengthTraining,
            .functionalStrengthTraining,
            .coreTraining,
            .crossTraining
        ]
        for type in families {
            XCTAssertEqual(SportCodeMapper.fromHKWorkoutActivityType(type.rawValue), .strengthTraining)
        }
    }

    func testHikingAndWalkingMapToHiking() {
        XCTAssertEqual(SportCodeMapper.fromHKWorkoutActivityType(HKWorkoutActivityType.hiking.rawValue), .hiking)
        XCTAssertEqual(SportCodeMapper.fromHKWorkoutActivityType(HKWorkoutActivityType.walking.rawValue), .hiking)
    }

    func testUnknownHKTypeReturnsNil() {
        // .americanFootball n'est pas couvert V1 (pas dans SportCode).
        XCTAssertNil(SportCodeMapper.fromHKWorkoutActivityType(HKWorkoutActivityType.americanFootball.rawValue))
    }

    func testInvalidRawValueReturnsNil() {
        // 99999 ne correspond à aucun HKWorkoutActivityType.
        XCTAssertNil(SportCodeMapper.fromHKWorkoutActivityType(99999))
    }
}
