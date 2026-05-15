// CoachingSageTests/Coaching/Glossary/GlossaryTests.swift
// Phase A — couvre le matcher `Glossary.entry(forZone:)` sur les targetZone
// concrets utilisés par les 40 templates v2.
import XCTest
@testable import CoachingSage

final class GlossaryTests: XCTestCase {

    func testDanielsAllFamiliesMatch() {
        XCTAssertEqual(Glossary.entry(forZone: "Daniels-E")?.id, "daniels.e")
        XCTAssertEqual(Glossary.entry(forZone: "Daniels-M")?.id, "daniels.m")
        XCTAssertEqual(Glossary.entry(forZone: "Daniels-T")?.id, "daniels.t")
        XCTAssertEqual(Glossary.entry(forZone: "Daniels-I")?.id, "daniels.i")
        XCTAssertEqual(Glossary.entry(forZone: "Daniels-R")?.id, "daniels.r")
    }

    func testHeartRateZonesMatchGenericZones() {
        XCTAssertEqual(Glossary.entry(forZone: "Z1")?.id, "zones")
        XCTAssertEqual(Glossary.entry(forZone: "Z2")?.id, "zones")
        XCTAssertEqual(Glossary.entry(forZone: "Z3")?.id, "zones")
        XCTAssertEqual(Glossary.entry(forZone: "Z4")?.id, "zones")
        XCTAssertEqual(Glossary.entry(forZone: "Z2-cardiac")?.id, "zones")
    }

    func testSwimEnduranceZonesMatch() {
        XCTAssertEqual(Glossary.entry(forZone: "EN1")?.id, "en")
        XCTAssertEqual(Glossary.entry(forZone: "EN2")?.id, "en")
        XCTAssertEqual(Glossary.entry(forZone: "EN3")?.id, "en")
    }

    func testCSSVariantsMatch() {
        XCTAssertEqual(Glossary.entry(forZone: "CSS pace")?.id, "css")
        XCTAssertEqual(Glossary.entry(forZone: "CSS+5s/100m")?.id, "css")
    }

    func testFTPVariantsMatch() {
        XCTAssertEqual(Glossary.entry(forZone: "FTP-Z1")?.id, "ftp")
        XCTAssertEqual(Glossary.entry(forZone: "FTP-Z5")?.id, "ftp")
        XCTAssertEqual(Glossary.entry(forZone: "FTP-Z7")?.id, "ftp")
    }

    func testSweetSpotMatches() {
        XCTAssertEqual(Glossary.entry(forZone: "Sweet-Spot")?.id, "sweetspot")
    }

    func testRPEVariantsMatch() {
        XCTAssertEqual(Glossary.entry(forZone: "RPE 7-8")?.id, "rpe")
        XCTAssertEqual(Glossary.entry(forZone: "RPE 8-9 sprint")?.id, "rpe")
    }

    func testPercentRMMatches() {
        XCTAssertEqual(Glossary.entry(forZone: "%1RM 75-80%")?.id, "1rm")
        XCTAssertEqual(Glossary.entry(forZone: "%1RM 85-90%")?.id, "1rm")
    }

    func testProtocolMatches() {
        XCTAssertEqual(Glossary.entry(forZone: "AMRAP")?.id, "amrap")
        XCTAssertEqual(Glossary.entry(forZone: "EMOM")?.id, "emom")
        XCTAssertEqual(Glossary.entry(forZone: "EMOM RPE 7-8")?.id, "emom")
        XCTAssertEqual(Glossary.entry(forZone: "Tabata 20/10")?.id, "tabata")
    }

    func testRacePaceMatches() {
        XCTAssertEqual(Glossary.entry(forZone: "@HMP")?.id, "hmp")
        XCTAssertEqual(Glossary.entry(forZone: "@5K-pace")?.id, "race.pace")
        XCTAssertEqual(Glossary.entry(forZone: "@10K-pace")?.id, "race.pace")
    }

    func testUnknownZoneReturnsNil() {
        XCTAssertNil(Glossary.entry(forZone: nil))
        XCTAssertNil(Glossary.entry(forZone: ""))
        XCTAssertNil(Glossary.entry(forZone: "flow"))
        XCTAssertNil(Glossary.entry(forZone: "technique"))
        XCTAssertNil(Glossary.entry(forZone: "REC"))
    }
}
