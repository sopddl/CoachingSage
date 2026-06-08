// CoachingSageTests/Coaching/Session/FocusReviewFixesTests.swift
// Revue ui-reviewer 2026-06-07 (pilote dosage muscu) — fixs P1 :
// #1 échauffement placeholder = écran vide ; #3 illustration band pull-down assis.
import XCTest
import TemplateModel
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

    // Mistags template (revue 2026-06-08) : override haute-confiance dans le resolver.
    private func pattern(_ matchKey: String) -> ExercisePattern {
        ExercisePatternResolver.resolve(AdaptedExercise(name: LocalizedText(fr: matchKey), originalName: matchKey),
                                        sportCode: "strengthTraining")
    }

    func test_resolver_fente_mistaggedSquat_isLunge() {
        // « Fentes haltères (pattern squat unilatéral) » → AVANT: squat. Override → lunge.
        XCTAssertEqual(pattern("Fentes haltères (pattern squat unilatéral)"), .lunge)
    }

    func test_resolver_hipThrust_mistaggedHinge_isHipThrust() {
        // « Hip Thrust au sol poids du corps (pattern hinge) » → AVANT: hinge. Override → hipThrust.
        XCTAssertEqual(pattern("Hip Thrust au sol poids du corps (pattern hinge)"), .hipThrust)
        XCTAssertEqual(pattern("Hip Thrust haltère lourd (pattern hinge)"), .hipThrust)
    }

    func test_resolver_realDeadlift_stillHinge() {
        // Garde-fou : un VRAI hinge (RDL/deadlift) reste hinge (pas de faux positif).
        XCTAssertEqual(pattern("Deadlift conventionnel (barre)"), .hinge)
        XCTAssertEqual(pattern("Romanian Deadlift haltères (pattern hinge)"), .hinge)
    }
}
