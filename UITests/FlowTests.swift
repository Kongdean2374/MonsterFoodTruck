import XCTest

final class FlowTests: XCTestCase {
    func testLaunch() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["魔物餐車"].waitForExistence(timeout: 10))
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "P1-launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
