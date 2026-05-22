// CoachingSageTests/Views/Components/GlossaryDiscoveryTooltipTests.swift
// Story 3.17 Phase 1 — couvre la logique UserDefaults du tooltip de découvrabilité.
import XCTest

final class GlossaryDiscoveryTooltipTests: XCTestCase {

    private var ud: UserDefaults!
    private let suiteName = "test.coaching.glossary.discovery.tooltip"

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

    func testShouldPresentTrueWhenNeverShown() {
        XCTAssertTrue(GlossaryDiscoveryTooltip.shouldPresent(userDefaults: ud))
    }

    func testShouldPresentFalseAfterMarkShown() {
        GlossaryDiscoveryTooltip.markShown(userDefaults: ud)
        XCTAssertFalse(GlossaryDiscoveryTooltip.shouldPresent(userDefaults: ud))
    }

    func testMarkShownIsIdempotent() {
        GlossaryDiscoveryTooltip.markShown(userDefaults: ud)
        GlossaryDiscoveryTooltip.markShown(userDefaults: ud)
        XCTAssertFalse(GlossaryDiscoveryTooltip.shouldPresent(userDefaults: ud))
        XCTAssertEqual(ud.bool(forKey: GlossaryDiscoveryTooltip.userDefaultsKey), true)
    }

    func testResetForTestingClearsFlag() {
        GlossaryDiscoveryTooltip.markShown(userDefaults: ud)
        XCTAssertFalse(GlossaryDiscoveryTooltip.shouldPresent(userDefaults: ud))
        GlossaryDiscoveryTooltip.resetForTesting(userDefaults: ud)
        XCTAssertTrue(GlossaryDiscoveryTooltip.shouldPresent(userDefaults: ud))
    }

    func testUserDefaultsKeyConstantIsStable() {
        // Garde-fou contre rename accidentel — la valeur du flag user est portée
        // par cette key entre versions. Toute évolution = migration manuelle.
        XCTAssertEqual(GlossaryDiscoveryTooltip.userDefaultsKey, "coaching.glossary.discovery.tooltip.shown")
    }
}
