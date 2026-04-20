import XCTest

final class CoachingSageUITests: XCTestCase {
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launchEnvironment["IS_UI_TESTING"] = "1"
        app.launch()
        // Mode UI testing : isAuthenticated forcé à true → texte placeholder du Story 1.1a.
        XCTAssertTrue(app.staticTexts["CoachingSage"].waitForExistence(timeout: 5))
    }
}
