// CoachingSageUITests/SyncBannerUITests.swift
// Story 1.3 — vérifie que le banner sync apparaît quand SyncService est forcé en .syncing.
import XCTest

final class SyncBannerUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["IS_UI_TESTING"] = "1"
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
    }

    func testSyncBannerAppearsOnSyncing() throws {
        app.launchEnvironment["UI_TEST_SYNC_STATUS"] = "syncing"
        app.launch()

        let banner = app.otherElements["sync_in_progress_banner"]
        XCTAssertTrue(
            banner.waitForExistence(timeout: 5),
            "sync_in_progress_banner doit apparaître quand UI_TEST_SYNC_STATUS=syncing"
        )
    }
}
