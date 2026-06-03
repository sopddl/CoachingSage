// CoachingSageTests/Adapter/AlternativeNameTests.swift
// Bug #8 — extraction de la durée embarquée dans le nom d'une alternative.
import XCTest
@testable import CoachingSage

final class AlternativeNameTests: XCTestCase {

    func test_extractsMinutes() {
        XCTAssertEqual(AlternativeName.embeddedDuration(in: "Sortie indoor-trainer FTP-Z1 35 min"), "35 min")
        XCTAssertEqual(AlternativeName.embeddedDuration(in: "Marche rapide 50 min"), "50 min")
        XCTAssertEqual(AlternativeName.embeddedDuration(in: "Tapis 45min"), "45min")
    }

    func test_extractsHours() {
        XCTAssertEqual(AlternativeName.embeddedDuration(in: "Sortie longue 1h30 continu"), "1h30")
        XCTAssertEqual(AlternativeName.embeddedDuration(in: "Home trainer 1h"), "1h")
        XCTAssertEqual(AlternativeName.embeddedDuration(in: "Rouleau 1 h 15"), "1h15")
    }

    func test_nilWhenNoDuration() {
        XCTAssertNil(AlternativeName.embeddedDuration(in: "Pompes diamant"))
        XCTAssertNil(AlternativeName.embeddedDuration(in: "Sortie continue FTP-Z1"))
    }
}
