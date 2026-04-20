import XCTest

final class CoachingSageUITests: XCTestCase {
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["CoachingSage — bootstrap Epic 1"].waitForExistence(timeout: 5))
    }
}
