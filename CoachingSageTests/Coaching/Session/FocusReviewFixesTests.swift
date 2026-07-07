// CoachingSageTests/Coaching/Session/FocusReviewFixesTests.swift
// Revue ui-reviewer 2026-06-07 (pilote dosage muscu) — fixs P1 :
// #1 échauffement placeholder = écran vide ; #3 illustration band pull-down assis.
import XCTest
import TemplateModel

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

    // Revue dessins TOUS SPORTS 2026-06-08 — mauvais mappings attrapés au dump par sport.
    func test_resolver_yogaFalseFriends_renderYoga() {
        // « Sauterelle » contenait « saut » → plyo à tort ; Bakasana → pull horizontal à tort.
        XCTAssertEqual(pattern("Salabhasana (Sauterelle)"), .yoga)
        XCTAssertEqual(pattern("Salabhasana (Sauterelle) 3 variantes"), .yoga)
        XCTAssertEqual(pattern("Bakasana (Crow) — préparation avec briques sous pieds"), .yoga)
    }
    func test_resolver_fifaBench_isPlankNotBenchPress() {
        // FIFA 11+ « Bench » = gainage planche ; « Sideways Bench » = side plank.
        XCTAssertEqual(pattern("FIFA 11+ — Bench statique"), .forearmPlank)
        XCTAssertEqual(pattern("FIFA 11+ — Bench dynamique avancée"), .forearmPlank)
        XCTAssertEqual(pattern("FIFA 11+ — Sideways Bench"), .core)
        // Garde-fou non-régression : le VRAI développé couché reste pushHorizontal.
        XCTAssertEqual(pattern("Bench press DB ou barbell"), .pushHorizontal)
        XCTAssertEqual(pattern("Incline DB bench press 30°"), .pushHorizontal)
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

    // « 3 fois le même » (Sophie 2026-06-08) — mouvements différents ne doivent plus partager
    // un dessin faux.
    func test_resolver_yraise_notPullup() {
        // Y-raise taggé « pull vertical » → ne doit PAS rendre une traction.
        XCTAssertEqual(pattern("Y-raise allongé (pattern pull vertical)"), .ytwActivation)
    }

    func test_resolver_pullover_dedicatedDrawing() {
        // Pullover (allongé) taggé « pull vertical » → dessin dédié pullover (créé 2026-06-08),
        // surtout PAS une traction trompeuse.
        XCTAssertEqual(pattern("Dumbbell Pullover (pattern pull vertical)"), .pullover)
    }

    func test_hipThrust_floorVsBench_differ() {
        // Le pont AU SOL (poids du corps) ≠ hip thrust au banc → variantes distinctes.
        XCTAssertEqual(HipThrustIllustration.resolveVariant(from: "Hip Thrust au sol poids du corps"), .gluteBridge)
        XCTAssertEqual(HipThrustIllustration.resolveVariant(from: "Hip thrust barre"), .barbellThrust)
    }

    // Dessins dédiés créés 2026-06-08 (étaient « génériques » avant) : triceps overhead &
    // woodchopper ont leur propre illustration, distincte de leur pair (pushdown / pallof).
    func test_resolver_overheadTriceps_dedicatedDrawing() {
        XCTAssertEqual(pattern("Overhead DB triceps extension"), .tricepsOverhead)
        XCTAssertEqual(pattern("Triceps Pushdown câble"), .tricepsPushdown) // l'autre reste juste
    }
    func test_resolver_woodchopper_dedicatedDrawing() {
        XCTAssertEqual(pattern("Cable woodchopper (core — EN FIN)"), .woodchopper)
        XCTAssertEqual(pattern("Pallof Press câble (core — EN FIN)"), .pallofPress) // l'autre reste juste
    }

    // Fixes cross-sport (workflow 9 sports 2026-06-08) : pattern existait, keyword manquait.
    func test_resolver_crossSport_keywordFixes() {
        XCTAssertEqual(pattern("Wall sit partiel"), .squat)
        XCTAssertEqual(pattern("External rotation à la bande"), .ytwActivation)
        XCTAssertEqual(pattern("Lateral bound"), .plyo)
    }

    // Bug HIIT work:rest (2026-06-08) : « 30 sec work + 20 sec rest » doit donner (30, 20)
    // → circuitPhases (repos distinct), pas 2 phases work.
    func test_hiit_workRest_plusFormat() {
        let ex = AdaptedExercise(name: LocalizedText(fr: "Tabata"), originalName: "tabata",
                                 sets: 8, duration: "30 sec work + 20 sec rest")
        let wr = SessionTimerPhaseBuilder.workRest(from: ex)
        XCTAssertEqual(wr?.work, 30)
        XCTAssertEqual(wr?.rest, 20)
    }
    func test_hiit_workRest_slashFormat_stillWorks() {
        let ex = AdaptedExercise(name: LocalizedText(fr: "40/20"), originalName: "x",
                                 sets: 8, duration: "40/20")
        let wr = SessionTimerPhaseBuilder.workRest(from: ex)
        XCTAssertEqual(wr?.work, 40)
        XCTAssertEqual(wr?.rest, 20)
    }
}
