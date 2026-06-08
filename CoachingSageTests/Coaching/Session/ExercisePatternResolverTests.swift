// CoachingSageTests/Coaching/Session/ExercisePatternResolverTests.swift
// Story 3.19 — couverture cascade `ExercisePatternResolver.resolve` sur le
// corpus 32 variantes templates v2 + keywords + sport fallback + .generic.
import XCTest
@testable import CoachingSage
import TemplateModel

final class ExercisePatternResolverTests: XCTestCase {

    // MARK: - Helpers

    private func ex(_ name: String) -> AdaptedExercise {
        AdaptedExercise(name: LocalizedText(fr: name), originalName: name)
    }

    private func resolve(_ name: String, sport: String = "strengthTraining") -> ExercisePattern {
        ExercisePatternResolver.resolve(ex(name), sportCode: sport)
    }

    // MARK: - Étape 3 — Table normalisation patterns biomécaniques

    func test_pattern_squat_simple() {
        XCTAssertEqual(resolve("Goblet squat (pattern squat)"), .squat)
    }

    func test_pattern_squat_unilateral() {
        XCTAssertEqual(resolve("Bulgarian split squat (pattern squat unilatéral)"), .squat)
    }

    func test_pattern_squat_equilibre() {
        XCTAssertEqual(resolve("Pistol assisted (pattern squat + équilibre)"), .squat)
    }

    func test_pattern_lower_maps_to_squat() {
        XCTAssertEqual(resolve("Front squat (pattern lower)"), .squat)
    }

    func test_pattern_hinge() {
        XCTAssertEqual(resolve("Romanian Deadlift haltères légers (pattern hinge)"), .hinge)
    }

    func test_pattern_hinge_hyp() {
        // Token « hinge hyp » → hinge. NB : exemple changé en RDL — « Hip thrust » est
        // désormais reclassé hipThrust (revue 2026-06-08, mistag template corrigé),
        // couvert par FocusReviewFixesTests.test_resolver_hipThrust_mistaggedHinge.
        XCTAssertEqual(resolve("Romanian deadlift barre (pattern hinge hyp)"), .hinge)
    }

    func test_pattern_moteur_asymetrique_maps_to_core() {
        XCTAssertEqual(resolve("Suitcase carry (pattern moteur asymétrique)"), .core)
    }

    func test_pattern_push_horizontal() {
        XCTAssertEqual(resolve("Pompe diamant (pattern push horizontal)"), .pushHorizontal)
    }

    func test_pattern_push_vertical_full_word() {
        XCTAssertEqual(resolve("Overhead press haltères (pattern push vertical)"), .pushVertical)
    }

    func test_pattern_push_v_short() {
        XCTAssertEqual(resolve("Pike push-up (pattern push V)"), .pushVertical)
    }

    func test_pattern_pull_horizontal() {
        XCTAssertEqual(resolve("Bent-over row (pattern pull horizontal)"), .pullHorizontal)
    }

    func test_pattern_pull_h_short() {
        XCTAssertEqual(resolve("Inverted row (pattern pull H)"), .pullHorizontal)
    }

    func test_pattern_pull_vertical() {
        XCTAssertEqual(resolve("Pull-up (pattern pull vertical)"), .pullVertical)
    }

    func test_pattern_pull_v_hyp() {
        XCTAssertEqual(resolve("Chin-up tempo (pattern pull V hyp)"), .pullVertical)
    }

    func test_pattern_pull_vertical_alternatif() {
        XCTAssertEqual(resolve("Chin-up alterné (pattern pull vertical alternatif)"), .pullVertical)
    }

    func test_pattern_pull_vertical_long_variant_partie1() {
        XCTAssertEqual(resolve("Pull-up combo (pattern pull vertical — partie 1)"), .pullVertical)
    }

    func test_pattern_pull_vertical_long_variant_partie2() {
        XCTAssertEqual(resolve("Combo (pattern pull vertical — partie 2 du combo)"), .pullVertical)
    }

    func test_pattern_pull_vertical_maintenu_cutback() {
        XCTAssertEqual(resolve("Hold (pattern pull vertical — maintenu en cutback)"), .pullVertical)
    }

    // MARK: - Étape 2 — Filtre hebdo / structurel → fallback

    func test_pattern_J1_J3_J5_falls_to_fallback() {
        // sportCode running → tombe en sport fallback runEndurance
        XCTAssertEqual(resolve("Cardio (pattern J1 / J3 / J5)", sport: "running"), .runEndurance)
    }

    func test_pattern_J1_J3_J5_J7_falls_to_fallback() {
        XCTAssertEqual(resolve("Cardio (pattern J1 / J3 / J5 / J7 ou J1 / J4 / J5 / J7 selon semaine)", sport: "running"),
                       .runEndurance)
    }

    func test_pattern_J1_cardio_J3_falls_to_fallback() {
        XCTAssertEqual(resolve("(pattern J1 cardio / J3 renforcement / J5 cardio = respecté dans ce plan)",
                                sport: "running"), .runEndurance)
    }

    func test_pattern_recommande_J_falls_to_fallback() {
        XCTAssertEqual(resolve("Plan (pattern recommandé : J1 run / J2 repos / J3 strength / J4 repos / J5 run / J6-J7 repos)",
                                sport: "running"), .runEndurance)
    }

    func test_pattern_J_inchange_falls_to_fallback() {
        XCTAssertEqual(resolve("(pattern J1/J3/J5 inchangé)", sport: "running"), .runEndurance)
    }

    func test_pattern_J_recommande_falls_to_fallback() {
        XCTAssertEqual(resolve("(pattern J1/J3/J5 recommandé)", sport: "running"), .runEndurance)
    }

    func test_pattern_long_weekly_run_plan_falls_to_fallback() {
        // Le pattern hebdo est filtré (étape 2), puis le name contient "tempo" / "VO2max"
        // → étape 5 sport fallback running → .runInterval. L'important est qu'on n'ait
        // PAS matché .squat / .hinge / .pull erronément.
        let name = "Plan (pattern : J1 run / J2 force / J3 tempo / J4 repos / J5 VO2max / J6 repos / J7 long run)"
        let result = resolve(name, sport: "running")
        XCTAssertTrue([.runInterval, .runEndurance, .runDrills].contains(result),
                      "Expected running fallback pattern, got \(result)")
    }

    func test_pattern_complexity_falls_to_fallback() {
        XCTAssertEqual(resolve("Drill (pattern de complexité croissante)", sport: "football"), .generic)
    }

    func test_pattern_in_in_out_out_falls_to_fallback() {
        XCTAssertEqual(resolve("Footwork (pattern 'in-in-out-out')", sport: "tennis"), .generic)
    }

    func test_pattern_piege_croise_falls_to_fallback() {
        XCTAssertEqual(resolve("Drill (pattern en 3 touches, piège croisé-couloir)", sport: "football"), .generic)
    }

    func test_pattern_condense_falls_to_fallback() {
        XCTAssertEqual(resolve("Semaine (pattern W8 intentionnellement condensé)", sport: "running"),
                       .runEndurance)
    }

    // MARK: - Étape 4 — Keyword fallback (pas de "(pattern X)" dans name)

    func test_keyword_deadlift_maps_to_hinge() {
        XCTAssertEqual(resolve("Romanian Deadlift haltères"), .hinge)
    }

    func test_keyword_pullup_maps_to_pullVertical() {
        XCTAssertEqual(resolve("Pull-up assisted bande"), .pullVertical)
    }

    func test_keyword_chinup_maps_to_pullVertical() {
        XCTAssertEqual(resolve("Chin-up tempo 3-1-3"), .pullVertical)
    }

    func test_keyword_row_maps_to_pullHorizontal() {
        XCTAssertEqual(resolve("Bent-over row barre"), .pullHorizontal)
    }

    func test_keyword_pompe_maps_to_pushHorizontal() {
        XCTAssertEqual(resolve("Pompe diamant 3×8"), .pushHorizontal)
    }

    func test_keyword_overhead_maps_to_pushVertical() {
        XCTAssertEqual(resolve("Overhead press haltères 8 reps"), .pushVertical)
    }

    func test_keyword_squat_maps_to_squat() {
        XCTAssertEqual(resolve("Goblet squat 3×10"), .squat)
    }

    func test_keyword_lunge_maps_to_lunge() {
        XCTAssertEqual(resolve("Fente avant alternée"), .lunge)
    }

    func test_keyword_plank_maps_to_core() {
        XCTAssertEqual(resolve("Plank latéral 30s"), .core)
    }

    func test_keyword_burpee_maps_to_plyo() {
        XCTAssertEqual(resolve("Burpee 10 reps explosives"), .plyo)
    }

    func test_keyword_stretch_maps_to_mobility() {
        XCTAssertEqual(resolve("Étirement adducteurs"), .mobility)
    }

    // MARK: - Étape 5 — Sport fallback

    func test_sport_running_endurance_default() {
        XCTAssertEqual(resolve("Sortie longue Z2", sport: "running"), .runEndurance)
    }

    func test_sport_running_interval_keyword() {
        XCTAssertEqual(resolve("Fractionné 8 × 400m", sport: "running"), .runInterval)
    }

    func test_sport_running_drills_keyword() {
        XCTAssertEqual(resolve("Drills skipping + montées de genoux", sport: "running"), .runDrills)
    }

    func test_sport_swimming_drill_keyword() {
        XCTAssertEqual(resolve("Drill rattrapé 4×50m", sport: "swimming"), .swimDrill)
    }

    func test_sport_swimming_endurance_default() {
        XCTAssertEqual(resolve("Crawl continu 1000m Z2", sport: "swimming"), .swimEndurance)
    }

    func test_sport_cycling_interval_keyword() {
        XCTAssertEqual(resolve("Fractionné SFR 6×3min", sport: "cycling"), .cycleInterval)
    }

    func test_sport_cycling_endurance_default() {
        XCTAssertEqual(resolve("Sortie longue endurance", sport: "cycling"), .cycleEndurance)
    }

    // MARK: - Étape 6 — Fallback ultime .generic

    func test_unknown_sport_returns_generic() {
        XCTAssertEqual(resolve("Exo bidon non identifié", sport: "tennis"), .generic)
    }

    func test_empty_name_unknown_sport_returns_generic() {
        XCTAssertEqual(resolve("", sport: "football"), .generic)
    }
}
