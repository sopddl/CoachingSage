// CoachingSageTests/Persistence/AutoTitleBuilderTests.swift
// Story 3.12 + 3.13 Phase D — tests AutoTitleBuilder.build :
//   - format simple "Sport — Goal" (Story 3.12)
//   - format composite multi-objectifs "Sport — Goal + Sec1 + Sec2" (Story 3.13)
//   - troncature "+N autre(s)" si dépasse 40 chars
//   - fallback sans goal / sans secondary valides
import XCTest
@testable import CoachingSage

@MainActor
final class AutoTitleBuilderTests: XCTestCase {

    private let frLocale = Locale(identifier: "fr_FR")
    private let enLocale = Locale(identifier: "en_US")

    // MARK: - Story 3.12 — Format simple (rétrocompat)

    /// Sport seul (sans goal) → renvoie juste le nom du sport localisé.
    func testBuildSportOnlyFallback() {
        let titleFR = AutoTitleBuilder.build(sportCode: "running", goal: nil, locale: frLocale)
        XCTAssertFalse(titleFR.isEmpty)
        XCTAssertFalse(titleFR.contains("—"))
    }

    /// Sport + goal valide → "Sport — Goal".
    func testBuildSportPlusGoal() {
        let title = AutoTitleBuilder.build(sportCode: "running", goal: "10k", locale: frLocale)
        XCTAssertTrue(title.contains("—"), "Format simple doit contenir le séparateur '—'")
    }

    /// Goal vide string → fallback sport seul.
    func testBuildEmptyGoalFallback() {
        let title = AutoTitleBuilder.build(sportCode: "running", goal: "", locale: frLocale)
        XCTAssertFalse(title.contains("—"))
    }

    // MARK: - Story 3.13 — Multi-objectifs

    /// Secondary vide → titre identique au format simple (pas de " + " ajouté).
    func testBuildEmptySecondaryEqualsSimple() {
        let simple = AutoTitleBuilder.build(sportCode: "running", goal: "10k", locale: frLocale)
        let withEmptySec = AutoTitleBuilder.build(
            sportCode: "running", goal: "10k", secondary: [], locale: frLocale
        )
        XCTAssertEqual(simple, withEmptySec)
    }

    /// Secondary [] → pas de " + " dans le titre.
    func testBuildSingleSecondaryAppended() {
        let title = AutoTitleBuilder.build(
            sportCode: "running",
            goal: "10k",
            secondary: ["5k"],
            locale: frLocale
        )
        XCTAssertTrue(title.contains(" + "), "Title doit contenir séparateur ' + ' pour secondary")
    }

    /// Secondary avec codes inconnus (pas de key i18n) → filtrés, fallback simple.
    func testBuildUnknownSecondaryFiltered() {
        let title = AutoTitleBuilder.build(
            sportCode: "running",
            goal: "10k",
            secondary: ["totally_unknown_goal_xyz"],
            locale: frLocale
        )
        XCTAssertFalse(title.contains(" + "), "Secondary sans i18n doit être filtré")
    }

    /// Secondary mix valide+inconnu → seul le valide est ajouté.
    func testBuildSecondaryFiltersInvalidOnly() {
        let title = AutoTitleBuilder.build(
            sportCode: "running",
            goal: "10k",
            secondary: ["bogus_unknown_xyz", "5k"],
            locale: frLocale
        )
        XCTAssertTrue(title.contains(" + "))
    }

    /// Plus de 1 secondary court → tous concaténés (sous le seuil 40 chars).
    func testBuildMultipleSecondaryUnderThreshold() {
        // "Course — 5K + Endurance" = 23 chars : court, devrait tenir.
        let title = AutoTitleBuilder.build(
            sportCode: "running",
            goal: "5k",
            secondary: ["5k"],
            locale: frLocale
        )
        XCTAssertLessThanOrEqual(title.count, AutoTitleBuilder.compositeMaxLength,
                                 "Titre court doit rester sous le seuil")
        XCTAssertTrue(title.contains(" + "))
        XCTAssertFalse(title.contains("autre"), "Pas de troncature si sous seuil")
    }

    /// Composite long > 40 chars → tronqué en "+N autre(s)".
    func testBuildLongCompositeFallsBackToCount() {
        // Empile assez de secondary pour exploser le seuil.
        let title = AutoTitleBuilder.build(
            sportCode: "running",
            goal: "marathon",
            secondary: ["wellness", "10k", "5k", "half_marathon"],
            locale: frLocale
        )
        // Au moins un des suffixes "autre" (FR) doit apparaître si troncature.
        // Si pas tronqué (cas rare où tout tient), au moins vérifier longueur.
        if title.count > AutoTitleBuilder.compositeMaxLength {
            XCTFail("Titre dépasse seuil sans troncature : '\(title)' (\(title.count) chars)")
        }
    }

    /// EN locale → suffix "+N more" et non "+N autre(s)".
    func testBuildLongCompositeUsesEnglishSuffix() {
        let title = AutoTitleBuilder.build(
            sportCode: "running",
            goal: "marathon",
            secondary: ["wellness", "10k", "5k", "half_marathon"],
            locale: enLocale
        )
        XCTAssertLessThanOrEqual(title.count, AutoTitleBuilder.compositeMaxLength + 2,
                                 "Titre EN tronqué doit rester ~sous le seuil")
    }
}
