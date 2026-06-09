// CoachingSageTests/Coaching/Session/BodyweightProgressionCatalogTests.swift
// Chantier charge muscu V2 — TRANCHE 4. Sélection de variante poids du corps par niveau.
import XCTest
import TemplateModel
@testable import CoachingSage

final class BodyweightProgressionCatalogTests: XCTestCase {

    func test_catalogedPattern_returnsVariant() {
        XCTAssertNotNil(BodyweightProgressionCatalog.variant(for: .pushHorizontal, level: 1))
        XCTAssertNotNil(BodyweightProgressionCatalog.variant(for: .squat, level: 5))
    }

    func test_uncatalogedPattern_returnsNil() {
        // Pas de variante poids-du-corps pour yoga → fallback consigne générique (V-2).
        XCTAssertNil(BodyweightProgressionCatalog.variant(for: .yoga, level: 3))
    }

    func test_lowLevel_easyVariant_highLevel_hardVariant() {
        XCTAssertEqual(BodyweightProgressionCatalog.variant(for: .pushHorizontal, level: 1)?.fr, "sur les genoux")
        XCTAssertEqual(BodyweightProgressionCatalog.variant(for: .pushHorizontal, level: 5)?.fr, "pieds surélevés")
    }

    func test_outOfRangeLevel_clamped() {
        XCTAssertNotNil(BodyweightProgressionCatalog.variant(for: .squat, level: 99))
        XCTAssertNotNil(BodyweightProgressionCatalog.variant(for: .squat, level: -5))
    }
}
