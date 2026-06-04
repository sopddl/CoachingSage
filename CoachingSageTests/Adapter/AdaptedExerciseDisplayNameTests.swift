// CoachingSageTests/Adapter/AdaptedExerciseDisplayNameTests.swift
// Story 3.19 Jalon 5 — sanitize `(pattern xxx)` du `name` exo affiché user.
// 14 templates strength embarquent ce suffixe pour l'étape 1 regex du resolver,
// mais il ne doit jamais apparaître à l'écran (P1 ui-reviewer 2026-05-24).
import XCTest

final class AdaptedExerciseDisplayNameTests: XCTestCase {

    func testDisplayNameStripsSinglePatternSuffix() {
        let exo = AdaptedExercise(name: "Goblet squat (pattern squat)", originalName: "Goblet squat")
        XCTAssertEqual(exo.displayName(Locale(identifier: "fr")), "Goblet squat")
    }

    func testDisplayNameStripsMultiWordPatternSuffix() {
        let exo = AdaptedExercise(name: "Pompe diamant (pattern push horizontal)", originalName: "Pompe diamant")
        XCTAssertEqual(exo.displayName(Locale(identifier: "fr")), "Pompe diamant")
    }

    func testDisplayNameStripsColonVariantPatternSuffix() {
        let exo = AdaptedExercise(name: "RDL haltères (pattern: hinge)", originalName: "RDL haltères")
        XCTAssertEqual(exo.displayName(Locale(identifier: "fr")), "RDL haltères")
    }

    func testDisplayNamePreservesNameWithoutSuffix() {
        let exo = AdaptedExercise(name: "Footing endurance", originalName: "Footing endurance")
        XCTAssertEqual(exo.displayName(Locale(identifier: "fr")), "Footing endurance")
    }

    func testDisplayNameTrimsResidualWhitespace() {
        let exo = AdaptedExercise(name: "Squat   (pattern squat)   ", originalName: "Squat")
        XCTAssertEqual(exo.displayName(Locale(identifier: "fr")), "Squat")
    }

    func testNameStaysIntactForResolverConsumption() {
        // Sanity : `displayName` ne mute pas `name`. La résolution regex étape 1
        // de `ExercisePatternResolver` continue de matcher.
        let exo = AdaptedExercise(name: "Goblet squat (pattern squat)", originalName: "Goblet squat")
        XCTAssertEqual(exo.name, "Goblet squat (pattern squat)")
    }
}
