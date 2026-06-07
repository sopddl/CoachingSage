// CoachingSageTests/Coaching/Session/FocusReviewFixesTests.swift
// Revue ui-reviewer 2026-06-07 (pilote dosage muscu) — fixs P1 :
// #1 échauffement placeholder = écran vide ; #3 illustration band pull-down assis.
import XCTest
@testable import CoachingSage

@MainActor
final class FocusReviewFixesTests: XCTestCase {

    // #1 — placeholder « Échauffement standard 7 min. » → fallback (pas d'écran vide).
    func test_placeholderGuidance_detected() {
        XCTAssertTrue(SessionFocusView.isPlaceholderGuidance(["Échauffement standard 7 min"]))
        XCTAssertTrue(SessionFocusView.isPlaceholderGuidance(["Étirements 5 min standards"]))
        XCTAssertTrue(SessionFocusView.isPlaceholderGuidance([]))
    }

    func test_realGuidance_notPlaceholder() {
        XCTAssertFalse(SessionFocusView.isPlaceholderGuidance(["10 cercles d'épaules avant"]))
        XCTAssertFalse(SessionFocusView.isPlaceholderGuidance(["5 min vélo facile", "mobilité épaules"]))
    }

    // #3 — band pull-down assis doit rendre la variante ASSISE (.pulldown), pas debout.
    func test_pullVertical_seatedBandPullDown_isPulldown() {
        XCTAssertEqual(PullVerticalIllustration.resolveVariant(from: "Band pull-down assis"), .pulldown)
        XCTAssertEqual(PullVerticalIllustration.resolveVariant(from: "Seated band pull-down"), .pulldown)
        XCTAssertEqual(PullVerticalIllustration.resolveVariant(from: "Tirage poulie haute"), .pulldown)
    }

    func test_pullVertical_pullup_stillStanding() {
        XCTAssertEqual(PullVerticalIllustration.resolveVariant(from: "Traction barre fixe"), .pullup)
        XCTAssertEqual(PullVerticalIllustration.resolveVariant(from: nil), .pullup)
    }
}
