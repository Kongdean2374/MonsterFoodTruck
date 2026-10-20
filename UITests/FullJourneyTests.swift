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
        _=revealLevel("level_06",app)
        XCTAssertTrue(app.buttons["level-level_06"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["level-level_06"].isEnabled)
        capture("normal-all-levels-unlocked",app)
        app.terminate();app.launchEnvironment.removeValue(forKey:"MFT_REPLAY_RESET");app.launch()
        app.buttons["關卡選擇"].tap()
        _=revealLevel("level_06",app)
        XCTAssertTrue(app.buttons["level-level_06"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["level-level_06"].isEnabled,"Real saved unlock must survive process restart")
        capture("normal-restarted-unlocks",app)
        verifyRealLateLevelClocheTaps(app)
    }
    private func verifyRealLateLevelClocheTaps(_ app:XCUIApplication){
        app.terminate();app.launchEnvironment.removeValue(forKey:"MFT_NORMAL_REPLAY");app.launchEnvironment["MFT_USE_REPLAY_SAVE"]="1";app.launch()
        XCTAssertTrue(app.buttons["關卡選擇"].waitForExistence(timeout:10));app.buttons["關卡選擇"].tap()
        let level=revealLevel("level_05",app)
        XCTAssertTrue(level.isHittable);level.tap();app.buttons["beginLevel"].tap()
        XCTAssertTrue(app.buttons["quick-L5-1"].waitForExistence(timeout:10))
        app.buttons["quick-L5-1"].tap();perform("備料",app);perform("下鍋",app)
        XCTAssertTrue(app.buttons["quick-L5-2"].waitForExistence(timeout:10));app.buttons["quick-L5-2"].tap();perform("備料",app);perform("下鍋",app)
        XCTAssertTrue(app.buttons["quick-L5-3"].waitForExistence(timeout:10));app.buttons["quick-L5-3"].tap();perform("備料",app)
        app.buttons["quick-L5-2"].tap();perform("裝盤",app)
        app.buttons["蓋上"].tap();XCTAssertTrue(app.buttons["取下"].waitForExistence(timeout:5));captureRealTaps("actual-late-covered-dragon",app)
        XCTAssertFalse(app.buttons["香草芽"].exists,"Covered meals must not offer garnishing")
        app.buttons["取下"].tap();XCTAssertTrue(app.buttons["蓋上"].waitForExistence(timeout:5));app.buttons["蓋上"].tap();perform("出餐",app)
        app.buttons["quick-L5-1"].tap();perform("裝盤",app)
        app.buttons["蓋上"].tap();XCTAssertTrue(app.buttons["取下"].waitForExistence(timeout:5));captureRealTaps("actual-late-cloche-reused-on-deer",app)
        app.buttons["取下"].tap();app.buttons["香草芽"].tap();perform("出餐",app)
        XCTAssertTrue(app.staticTexts["已服務 2／7 ・一般"].waitForExistence(timeout:5));captureRealTaps("actual-late-two-served-with-cloche",app)
        app.buttons["pause"].tap();app.buttons["保存並回首頁"].tap();XCTAssertTrue(app.buttons["繼續遊玩"].waitForExistence(timeout:5))
    }
    private func revealLevel(_ id:String,_ app:XCUIApplication)->XCUIElement{
        let level=app.buttons["level-\(id)"]
        for _ in 0..<6{
            if level.exists && level.isHittable && level.frame.maxY<app.frame.maxY-44{return level}
            app.swipeUp()
        }
        XCTAssertTrue(level.exists && level.isHittable,"Level card must be visible before inspecting its saved unlock: \(id)")
        return level
    }
    private func perform(_ label:String,_ app:XCUIApplication){
        let deadline=Date().addingTimeInterval(35);var tapped=false
        while Date()<deadline{
            if app.buttons["知道了，繼續"].exists{app.buttons["知道了，繼續"].tap();continue}
            let button=app.buttons["primaryCommand"]
            if tapped && (!button.exists || button.label != label){return}
            if button.exists && button.isEnabled && button.isHittable && button.label==label{button.tap();tapped=true}
            RunLoop.current.run(until:Date().addingTimeInterval(0.2))
        }
        XCTFail("Real late-level tap action failed: \(label)")
    }
    private func captureRealTaps(_ name:String,_ app:XCUIApplication){
        let shot=XCTAttachment(screenshot:app.screenshot());shot.name=name;shot.lifetime = .keepAlways;add(shot)
        let note=XCTAttachment(string:"Actual taps at normal game time, no command driver/state injection. Unlocks restored from the six runtime sessions completed earlier in this same test. This bounded cloche check is not a full human playtest.")
        note.name=name+"-method";note.lifetime = .keepAlways;add(note)
    }
    func testPracticeReplayDoesNotUnlockFormalProgress(){
        let app=XCUIApplication();app.launchEnvironment["MFT_NORMAL_REPLAY"]="1";app.launchEnvironment["MFT_REPLAY_RESET"]="1";app.launchEnvironment["MFT_PRACTICE_STORAGE"]="1";app.launch()
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
