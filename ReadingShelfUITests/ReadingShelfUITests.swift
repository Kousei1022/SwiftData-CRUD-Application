import XCTest

final class ReadingShelfUITests: XCTestCase {
    func testCreateReadUpdateDeleteBook() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        let addButton = app.buttons["addBookButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        attachScreenshot(of: app, named: "01-empty-library")

        addButton.tap()
        let titleField = app.textFields["bookTitleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("The Quiet Archive")
        let authorField = app.textFields["bookAuthorField"]
        authorField.tap()
        authorField.typeText("Morgan Reed")
        app.buttons["saveBookButton"].tap()

        let bookRow = app.buttons["book-row-The Quiet Archive"]
        XCTAssertTrue(bookRow.waitForExistence(timeout: 5))
        attachScreenshot(of: app, named: "02-create-book")

        bookRow.tap()
        XCTAssertTrue(app.staticTexts["detailBookTitle"].waitForExistence(timeout: 3))
        attachScreenshot(of: app, named: "03-read-book-details")

        app.buttons["editBookButton"].tap()
        let editTitleField = app.textFields["bookTitleField"]
        XCTAssertTrue(editTitleField.waitForExistence(timeout: 3))
        editTitleField.tap()
        editTitleField.press(forDuration: 1.1)
        if app.menuItems["Select All"].waitForExistence(timeout: 1) {
            app.menuItems["Select All"].tap()
        } else {
            let currentValue = editTitleField.value as? String ?? "The Quiet Archive"
            for _ in currentValue {
                editTitleField.typeText(XCUIKeyboardKey.delete.rawValue)
            }
        }
        editTitleField.typeText("The Open Archive")
        app.buttons["saveBookButton"].tap()
        XCTAssertTrue(app.staticTexts["The Open Archive"].waitForExistence(timeout: 3))
        attachScreenshot(of: app, named: "04-update-book")

        app.buttons["deleteBookButton"].tap()
        let confirmDeleteButton = app.buttons.matching(identifier: "confirmDeleteBookButton").firstMatch
        XCTAssertTrue(confirmDeleteButton.waitForExistence(timeout: 3))
        confirmDeleteButton.tap()
        XCTAssertTrue(app.staticTexts["A shelf with room to grow"].waitForExistence(timeout: 3))
        attachScreenshot(of: app, named: "05-delete-book")
    }

    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}