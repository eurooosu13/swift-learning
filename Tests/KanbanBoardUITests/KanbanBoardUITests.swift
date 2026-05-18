import XCTest

@MainActor
final class KanbanBoardUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testFullCRUDFlowAndRelaunchPersistence() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting-reset-store"]
        app.launch()

        app.buttons["add-card-button"].click()
        app.textFields["card-title-field"].click()
        app.textFields["card-title-field"].typeText("Learn SwiftUI Testing")
        app.textFields["card-notes-field"].click()
        app.textFields["card-notes-field"].typeText("Drive the board through XCUITest")
        app.textFields["card-tags-field"].click()
        app.textFields["card-tags-field"].typeText("ui,test")
        app.buttons["save-card-button"].click()

        XCTAssertTrue(app.staticTexts["Learn SwiftUI Testing"].waitForExistence(timeout: 3))

        app.buttons["edit-card-button-Learn SwiftUI Testing"].click()
        let titleField = app.textFields["card-title-field"]
        titleField.click()
        titleField.typeKey("a", modifierFlags: .command)
        titleField.typeText("Learn SwiftData UI Testing")
        app.buttons["save-card-button"].click()

        XCTAssertTrue(app.staticTexts["Learn SwiftData UI Testing"].waitForExistence(timeout: 3))

        app.buttons["advance-card-button-Learn SwiftData UI Testing"].click()
        app.buttons["advance-card-button-Learn SwiftData UI Testing"].click()
        XCTAssertTrue(app.descendants(matching: .any)["card-done-Learn SwiftData UI Testing"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Learn SwiftData UI Testing"].exists)

        let searchField = app.textFields["search-field"]
        searchField.click()
        searchField.typeText("SwiftData")
        XCTAssertTrue(app.staticTexts["Learn SwiftData UI Testing"].exists)

        app.terminate()
        app.launchArguments = []
        app.launch()
        XCTAssertTrue(app.staticTexts["Learn SwiftData UI Testing"].waitForExistence(timeout: 3))

        app.buttons["delete-card-button-Learn SwiftData UI Testing"].click()
        XCTAssertFalse(app.staticTexts["Learn SwiftData UI Testing"].waitForExistence(timeout: 1))
    }
}
