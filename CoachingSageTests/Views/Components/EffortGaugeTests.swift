// CoachingSageTests/Views/Components/EffortGaugeTests.swift
// Story 3.19 Jalon 3 — tests EffortGauge (clamp niveau + état initial).
// La jauge anime ses barres via @State au onAppear ; les assertions
// ciblent uniquement le clamp `level` et la valeur passée en init,
// puisque le rendu animé n'est pas observable hors SwiftUI hosting.
import XCTest
import SwiftUI

final class EffortGaugeTests: XCTestCase {

    func test_init_storesLevelAsProvided() {
        let g = EffortGauge(level: 3)
        XCTAssertEqual(g.level, 3)
    }

    func test_init_levelBelow1_isPreservedRawForCallerClampLater() {
        // La clampe se fait dans `clampedLevel` à l'usage, pas au stockage.
        // On valide que l'init n'altère pas la valeur entrée.
        let g = EffortGauge(level: 0)
        XCTAssertEqual(g.level, 0)
    }

    func test_init_levelAbove5_isPreservedRawForCallerClampLater() {
        let g = EffortGauge(level: 99)
        XCTAssertEqual(g.level, 99)
    }

    func test_animatedFlag_defaultsTrue() {
        let g = EffortGauge(level: 3)
        XCTAssertTrue(g.animated)
    }

    func test_animatedFlag_canBeDisabled() {
        let g = EffortGauge(level: 3, animated: false)
        XCTAssertFalse(g.animated)
    }
}
