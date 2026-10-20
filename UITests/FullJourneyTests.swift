import XCTest

/// Extended evidence suite. Invoked explicitly by full QA, independently of short CI.
/// The app's DEBUG driver submits normal validated commands against foreground time.
final class FullJourneyTests:XCTestCase {
    override func setUp(){continueAfterFailure=false}
    override func tearDown(){
        if (testRun?.failureCount ?? 0)>0{
            let shot=XCTAttachment(screenshot:XCUIScreen.main.screenshot());shot.name="FAILED-journey-actual-screen";shot.lifetime = .keepAlways;add(shot)
        }
    }
    func testSixLevelsAtNormalSpeed(){
        let app=XCUIApplication()
        app.launchEnvironment["MFT_NORMAL_REPLAY"]="1"
        app.launchEnvironment["MFT_REPLAY_RESET"]="1"
        app.launch()
        XCTAssertTrue(app.buttons["start"].waitForExistence(timeout:10))
        app.buttons["start"].tap()
        for level in 1...6{
            XCTAssertTrue(app.buttons["beginLevel"].waitForExistence(timeout:10),"Introduction missing for level \(level)")
            capture("normal-L\(level)-intro",app)
            app.buttons["beginLevel"].tap()
            XCTAssertTrue(app.staticTexts["一般模式・正常命令重播（非手動試玩）"].waitForExistence(timeout:10))
            let next=app.buttons[level==6 ? "六關完成，收店囉":"下一關"]
            XCTAssertTrue(next.waitForExistence(timeout:170),"Level \(level) failed to finish and save through real commands")
            XCTAssertTrue(app.staticTexts["通過・紀錄已儲存"].exists)
            capture("normal-L\(level)-result",app)
            next.tap()
        }
        XCTAssertTrue(app.staticTexts["六關已完成，可返回挑戰三星。"].waitForExistence(timeout:10))
        capture("normal-six-level-completion",app)
        app.buttons["返回挑戰三星"].tap()
        XCTAssertTrue(app.buttons["level-level_06"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["level-level_06"].isEnabled)
        capture("normal-all-levels-unlocked",app)
        app.terminate();app.launchEnvironment.removeValue(forKey:"MFT_REPLAY_RESET");app.launch()
        app.buttons["關卡選擇"].tap()
        XCTAssertTrue(app.buttons["level-level_06"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["level-level_06"].isEnabled,"Real saved unlock must survive process restart")
        capture("normal-restarted-unlocks",app)
    }
    func testPracticeReplayDoesNotUnlockFormalProgress(){
        let app=XCUIApplication();app.launchEnvironment["MFT_NORMAL_REPLAY"]="1";app.launchEnvironment["MFT_REPLAY_RESET"]="1";app.launch()
        XCTAssertTrue(app.buttons["遊戲說明"].waitForExistence(timeout:10));app.buttons["遊戲說明"].tap()
        let practice=app.buttons["重看第一關教學"]
        for _ in 0..<5{if practice.isHittable && practice.frame.midY<app.frame.maxY-100{break};app.swipeUp()}
        XCTAssertTrue(practice.waitForExistence(timeout:5));practice.tap()
        app.buttons["beginLevel"].tap()
        XCTAssertTrue(app.staticTexts["教學重看・不更新正式紀錄"].waitForExistence(timeout:170))
        XCTAssertFalse(app.buttons["下一關"].exists);XCTAssertTrue(app.buttons["正式開始第一關"].exists)
        capture("practice-engineering-replay-no-formal-award",app)
        app.buttons["關卡選擇"].tap();XCTAssertTrue(app.buttons["level-level_02"].waitForExistence(timeout:5))
        XCTAssertFalse(app.buttons["level-level_02"].isEnabled);capture("practice-does-not-unlock-level-two",app)
    }
    private func capture(_ name:String,_ app:XCUIApplication){
        let shot=XCTAttachment(screenshot:app.screenshot());shot.name=name;shot.lifetime = .keepAlways;add(shot)
        let note=XCTAttachment(string:"Normal-mode engineering command replay; real foreground game clock, no timing or score override. Not human playtesting. Actual viewport \(app.frame.width) × \(app.frame.height) pt.")
        note.name=name+"-method";note.lifetime = .keepAlways;add(note)
    }
}
