import XCTest

final class CoachingSageUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["IS_UI_TESTING"] = "1"
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    func testAppLaunchesToMainTabView() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should be visible after auto-auth in UI testing mode")
        XCTAssertEqual(tabBar.buttons.count, 4, "MainTabView should expose 4 tabs")
    }

    func testEachTabShowsItsPlaceholder() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        let tabs: [(id: String, label: String)] = [
            ("tab.today", "Today"),
            ("tab.session", "Workout"),
            ("tab.progress", "Progress"),
            ("tab.profile", "Profile")
        ]

        for tab in tabs {
            let button = tabBar.buttons[tab.id].exists
                ? tabBar.buttons[tab.id]
                : tabBar.buttons[tab.label]
            XCTAssertTrue(button.exists, "Tab \(tab.label) must exist")
            button.tap()

            if tab.id == "tab.profile" {
                XCTAssertTrue(
                    app.buttons["Sign out"].waitForExistence(timeout: 2),
                    "Profile tab must expose the Sign out button"
                )
            } else {
                XCTAssertTrue(
                    app.staticTexts["Coming soon"].waitForExistence(timeout: 2),
                    "\(tab.label) placeholder must show 'Coming soon'"
                )
            }
        }
    }
}
