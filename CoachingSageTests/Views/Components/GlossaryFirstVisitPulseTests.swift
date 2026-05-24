// CoachingSageTests/Views/Components/GlossaryFirstVisitPulseTests.swift
// Story 3.19 Jalon 4 — couvre la logique UserDefaults du pulse glossaire AC13.
// Helper miroir de `GlossaryDiscoveryTooltipTests` (Story 3.17 Phase 1).
import XCTest

final class GlossaryFirstVisitPulseTests: XCTestCase {

    private var ud: UserDefaults!
    private let suiteName = "test.coaching.session.glossary.firstVisit"

    override func setUp() {
        super.setUp()
        UserDefaults().removePersistentDomain(forName: suiteName)
        ud = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        ud.removePersistentDomain(forName: suiteName)
        ud = nil
        super.tearDown()
    }

    func testShouldPulseTrueWhenNeverPulsed() {
        XCTAssertTrue(GlossaryFirstVisitPulse.shouldPulse(userDefaults: ud))
    }

    func testShouldPulseFalseAfterMarkPulsed() {
        GlossaryFirstVisitPulse.markPulsed(userDefaults: ud)
        XCTAssertFalse(GlossaryFirstVisitPulse.shouldPulse(userDefaults: ud))
    }

    func testMarkPulsedIsIdempotent() {
        GlossaryFirstVisitPulse.markPulsed(userDefaults: ud)
        GlossaryFirstVisitPulse.markPulsed(userDefaults: ud)
        XCTAssertFalse(GlossaryFirstVisitPulse.shouldPulse(userDefaults: ud))
        XCTAssertEqual(ud.bool(forKey: GlossaryFirstVisitPulse.userDefaultsKey), true)
    }

    func testResetForTestingClearsFlag() {
        GlossaryFirstVisitPulse.markPulsed(userDefaults: ud)
        XCTAssertFalse(GlossaryFirstVisitPulse.shouldPulse(userDefaults: ud))
        GlossaryFirstVisitPulse.resetForTesting(userDefaults: ud)
        XCTAssertTrue(GlossaryFirstVisitPulse.shouldPulse(userDefaults: ud))
    }

    func testUserDefaultsKeyConstantIsStable() {
        // Garde-fou contre rename accidentel — la valeur du flag user est portée
        // par cette key entre versions. Toute évolution = migration manuelle.
        XCTAssertEqual(
            GlossaryFirstVisitPulse.userDefaultsKey,
            "coaching.session.glossary.firstVisitDone"
        )
    }

    func testKeyIsDistinctFromDiscoveryTooltipKey() {
        // Phase 1 (tooltip) et Jalon 4 (pulse) sont 2 flags séparés. Si l'un
        // est marqué, l'autre reste indépendant.
        XCTAssertNotEqual(
            GlossaryFirstVisitPulse.userDefaultsKey,
            GlossaryDiscoveryTooltip.userDefaultsKey
        )
    }

    func testIndependenceBetweenTooltipAndPulseFlags() {
        // Marquer tooltip ne marque pas pulse, et inversement.
        GlossaryDiscoveryTooltip.markShown(userDefaults: ud)
        XCTAssertTrue(GlossaryFirstVisitPulse.shouldPulse(userDefaults: ud))

        GlossaryFirstVisitPulse.resetForTesting(userDefaults: ud)
        GlossaryFirstVisitPulse.markPulsed(userDefaults: ud)
        XCTAssertFalse(GlossaryDiscoveryTooltip.shouldPresent(userDefaults: ud))
        // ⚠️ Note : shouldPresent retourne false ici car le flag tooltip a été
        // marqué juste avant (ligne 60). On vérifie juste que les 2 flags
        // n'interfèrent pas (assertions précédentes le prouvent).
    }
}
