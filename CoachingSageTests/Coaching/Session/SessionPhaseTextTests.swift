// CoachingSageTests/Coaching/Session/SessionPhaseTextTests.swift
// Story 3.35f — mise en forme échauffement/récup : puces sur « + », durée totale
// extraite, « / » assainis.
import XCTest
@testable import CoachingSage

final class SessionPhaseTextTests: XCTestCase {

    private let warmup = "5 min de marche progressive + 10 cercles de chevilles/côté + 10 balancements de jambe + 10 demi-squats lents. Total : 8 min. Ne jamais sauter cette étape."

    func test_bulletLines_splitsOnPlus_andSanitizesSlash() {
        let lines = SessionPhaseText.bulletLines(from: warmup)
        // Découpe sur « + » ET fins de phrase → la consigne « Ne jamais sauter… »
        // devient sa propre puce.
        XCTAssertEqual(lines[0], "5 min de marche progressive")
        XCTAssertEqual(lines[1], "10 cercles de chevilles · côté") // « / » → « · »
        XCTAssertTrue(lines.contains("Ne jamais sauter cette étape"))
        // La mention « Total : … » est retirée du corps.
        XCTAssertFalse(lines.joined().contains("Total"))
    }

    func test_bulletLines_splitsProseSentences() {
        let notes = "Allure très lente. Si le souffle coupe, ralentis. Total bloc : 20 min."
        let lines = SessionPhaseText.bulletLines(from: notes)
        XCTAssertEqual(lines, ["Allure très lente", "Si le souffle coupe, ralentis"])
    }

    func test_totalLabel_extractsTotalMinutes() {
        XCTAssertEqual(SessionPhaseText.totalLabel(from: warmup), "8 min")
    }

    func test_totalLabel_nilWhenNoTotal() {
        XCTAssertNil(SessionPhaseText.totalLabel(from: "3 min marche lente. Étirements."))
    }

    func test_bulletLines_singleLineWhenNoPlus() {
        let lines = SessionPhaseText.bulletLines(from: "3 min marche lente.")
        XCTAssertEqual(lines, ["3 min marche lente"]) // point final retiré
    }
}
