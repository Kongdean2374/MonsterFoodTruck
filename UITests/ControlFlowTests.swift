import XCTest

/// Extended real-tap flow: no injected customers, state, scores or accelerated clock.
final class ControlFlowTests:XCTestCase{
    override func setUp(){continueAfterFailure=false}
    override func tearDown(){
        if testRun?.hasSucceeded == false{
            let shot=XCTAttachment(screenshot:XCUIScreen.main.screenshot());shot.name="FAILED-controls-actual-screen";shot.lifetime = .keepAlways;add(shot)
        }
    }
    func testBackgroundFailureRetryAndConfirmationPaths(){
        let app=XCUIApplication();app.launchEnvironment["MFT_UI_SUITE"]="controls";app.launchEnvironment["MFT_REDUCE_MOTION"]="1";app.launch()
        XCTAssertTrue(app.buttons["start"].waitForExistence(timeout:10));app.buttons["start"].tap()
        app.buttons["beginLevel"].tap();XCTAssertTrue(app.buttons["略過教學"].waitForExistence(timeout:5));app.buttons["略過教學"].tap()
        let customer=app.buttons["customer-L1-1"];XCTAssertTrue(customer.waitForExistence(timeout:5))
        let before=remaining(customer.label)
        XCUIDevice.shared.press(.home)
        RunLoop.current.run(until:Date().addingTimeInterval(5))
        app.activate();XCTAssertTrue(app.buttons["繼續營業"].waitForExistence(timeout:10));capture("actual-background-requires-resume",app)
        app.buttons["繼續營業"].tap();XCTAssertTrue(customer.waitForExistence(timeout:5))
        let after=remaining(customer.label);XCTAssertGreaterThanOrEqual(before-after,0);XCTAssertLessThanOrEqual(before-after,3,"Five background seconds must not consume patience")
        // Intentionally serve nothing, letting the real fixed script and patience finish.
        XCTAssertTrue(app.staticTexts["未通過"].waitForExistence(timeout:125))
        XCTAssertFalse(app.buttons["下一關"].exists);capture("actual-no-input-failure-result",app)
        app.buttons["再玩一次"].tap();XCTAssertTrue(customer.waitForExistence(timeout:5))
        XCTAssertTrue(customer.label.contains("苔角鹿，星火濃湯"));XCTAssertGreaterThan(remaining(customer.label),60)
        app.buttons["pause"].tap();app.buttons["重新開始本關"].tap();app.buttons["取消"].tap()
        XCTAssertTrue(app.buttons["繼續營業"].waitForExistence(timeout:5))
        app.buttons["設定"].tap();app.buttons["舒緩"].tap()
        XCTAssertTrue(app.staticTexts["目前這局固定為「一般」；更改僅套用下一局。"].exists)
        app.buttons["完成"].tap();XCTAssertTrue(app.buttons["繼續營業"].waitForExistence(timeout:5))
        app.buttons["重新開始本關"].tap();app.buttons["確認重新開始"].tap()
        XCTAssertTrue(app.staticTexts["已服務 0／3 ・舒緩"].waitForExistence(timeout:5));capture("actual-restart-next-mode",app)
        app.buttons["pause"].tap();app.buttons["放棄本局"].tap();app.buttons["取消"].tap()
        XCTAssertTrue(app.buttons["繼續營業"].waitForExistence(timeout:5))
        app.buttons["放棄本局"].tap();app.buttons["確認放棄本局"].tap()
        XCTAssertTrue(app.buttons["start"].waitForExistence(timeout:5));XCTAssertFalse(app.buttons["繼續遊玩"].exists)
        capture("actual-abandon-confirmed-home",app)
    }
    private func remaining(_ label:String)->Int{
        let tail=label.components(separatedBy:"耐心剩").last ?? ""
        guard let value=Int(tail.components(separatedBy:"秒").first ?? "") else{XCTFail("Missing real patience accessibility value: \(label)");return -1000}
        return value
    }
    private func capture(_ name:String,_ app:XCUIApplication){
        let shot=XCTAttachment(screenshot:app.screenshot());shot.name=name;shot.lifetime = .keepAlways;add(shot)
    }
}
