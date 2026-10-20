import XCTest

final class FlowTests: XCTestCase {
    override func setUp(){continueAfterFailure=false}
    override func tearDown(){
        if (testRun?.failureCount ?? 0)>0{
            let shot=XCTAttachment(screenshot:XCUIScreen.main.screenshot());shot.name="FAILED-actual-screen";shot.lifetime = .keepAlways;add(shot)
        }
    }
    func capture(_ name:String,_ app:XCUIApplication){
        let attachment=XCTAttachment(screenshot:app.screenshot());attachment.name=name;attachment.lifetime = .keepAlways;add(attachment)
        let viewport=XCTAttachment(string:"\(name): actual app viewport \(app.frame.width) × \(app.frame.height) pt; orientation \(XCUIDevice.shared.orientation.rawValue)")
        viewport.name=name+"-viewport";viewport.lifetime = .keepAlways;add(viewport)
    }
    func testLaunch() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["魔物餐車"].waitForExistence(timeout: 10))
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "P1-launch"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    func testNavigationTutorialPauseAndPersistence(){
        let app=XCUIApplication();app.launchEnvironment["MFT_REDUCE_MOTION"]="1";app.launchEnvironment["MFT_UI_SUITE"]="navigation";app.launch()
        XCTAssertTrue(app.buttons["start"].waitForExistence(timeout:10));capture("home",app)
        app.buttons["關卡選擇"].tap();XCTAssertTrue(app.buttons["level-level_01"].waitForExistence(timeout:5));capture("levels-locked",app)
        app.buttons["level-level_01"].tap();XCTAssertTrue(app.buttons["beginLevel"].waitForExistence(timeout:5));capture("level-intro",app)
        app.buttons["beginLevel"].tap()
        if app.buttons["放棄目前這局並開始"].waitForExistence(timeout:2){app.buttons["放棄目前這局並開始"].tap()}
        XCTAssertTrue(app.buttons["知道了，繼續"].waitForExistence(timeout:5));capture("tutorial-first",app)
        RunLoop.current.run(until:Date().addingTimeInterval(1))
        XCTAssertTrue(app.buttons["知道了，繼續"].exists);capture("tutorial-first-stable-1s",app)
        RunLoop.current.run(until:Date().addingTimeInterval(2))
        XCTAssertTrue(app.buttons["知道了，繼續"].exists);capture("tutorial-first-stable-3s",app)
        app.buttons["知道了，繼續"].tap();app.buttons["quick-L1-1"].tap()
        for action in ["備料","下鍋","裝盤","出餐"]{perform(action,app)}
        capture("normal-play-after-service",app)
        app.buttons["pause"].tap();XCTAssertTrue(app.buttons["保存並回首頁"].waitForExistence(timeout:5));capture("paused",app)
        app.buttons["設定"].tap();XCTAssertTrue(app.navigationBars["餐車設定"].waitForExistence(timeout:5))
        reveal(app.switches["高對比資訊"],app,up:true);app.switches["高對比資訊"].tap()
        XCTAssertEqual(app.switches["高對比資訊"].value as? String,"1")
        reveal(app.switches["大字介面"],app,up:true);app.switches["大字介面"].tap()
        XCTAssertEqual(app.switches["大字介面"].value as? String,"1")
        reveal(app.switches["左手單手配置"],app,up:true);app.switches["左手單手配置"].tap()
        XCTAssertEqual(app.switches["左手單手配置"].value as? String,"1")
        reveal(app.sliders["音樂音量"],app,up:false)
        app.sliders["音樂音量"].adjust(toNormalizedSliderPosition:0);capture("settings-large-contrast-left",app)
        app.buttons["完成"].tap();XCTAssertTrue(app.buttons["繼續營業"].waitForExistence(timeout:5))
        app.buttons["保存並回首頁"].tap();XCTAssertTrue(app.buttons["繼續遊玩"].waitForExistence(timeout:5))
        app.terminate();app.launch();XCTAssertTrue(app.buttons["繼續遊玩"].waitForExistence(timeout:10))
        app.buttons["繼續遊玩"].tap();XCTAssertTrue(app.buttons["繼續營業"].waitForExistence(timeout:5));capture("restored-paused",app)
        app.buttons["繼續營業"].tap()
        for id in ["L1-2","L1-3"]{
            XCTAssertTrue(app.buttons["quick-\(id)"].waitForExistence(timeout:25))
            app.buttons["quick-\(id)"].tap()
            for action in ["備料","下鍋","裝盤"]{perform(action,app)}
            XCTAssertTrue(app.buttons["香草芽"].waitForExistence(timeout:5));app.buttons["香草芽"].tap()
            perform("出餐",app)
        }
        XCTAssertTrue(app.staticTexts["通過・紀錄已儲存"].waitForExistence(timeout:10))
        capture("actual-taps-level-one-result",app)
        app.buttons["下一關"].tap();XCTAssertTrue(app.buttons["beginLevel"].waitForExistence(timeout:5))
        app.buttons["返回選關"].tap();XCTAssertTrue(app.buttons["level-level_02"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["level-level_02"].isEnabled);capture("actual-taps-level-two-unlocked",app)
        verifySettingsAndReset(app)
    }
    func verifySettingsAndReset(_ app:XCUIApplication){
        app.buttons["首頁"].tap();app.buttons["設定"].tap()
        reveal(app.sliders["音效音量"],app,up:false);app.sliders["音效音量"].adjust(toNormalizedSliderPosition:0)
        app.switches["觸覺回饋"].tap();XCTAssertEqual(app.switches["觸覺回饋"].value as? String,"0");app.buttons["舒緩"].tap()
        reveal(app.switches["減少動態效果"],app,up:true);app.switches["減少動態效果"].tap()
        XCTAssertEqual(app.switches["減少動態效果"].value as? String,"0");capture("actual-settings-before-process-restart",app)
        app.buttons["完成"].tap()
        let closed=XCTNSPredicateExpectation(predicate:NSPredicate(format:"exists == false"),object:app.navigationBars["餐車設定"])
        XCTAssertEqual(XCTWaiter.wait(for:[closed],timeout:5),.completed)
        app.terminate();app.launchEnvironment.removeValue(forKey:"MFT_REDUCE_MOTION");app.launch()
        app.buttons["設定"].tap();XCTAssertTrue(app.staticTexts["音樂音量 0%"].waitForExistence(timeout:5))
        XCTAssertTrue(app.staticTexts["音效音量 0%"].exists);XCTAssertEqual(app.switches["觸覺回饋"].value as? String,"0")
        reveal(app.switches["減少動態效果"],app,up:true);XCTAssertEqual(app.switches["減少動態效果"].value as? String,"0")
        capture("actual-settings-after-process-restart",app)
        reveal(app.buttons["恢復預設設定"],app,up:true);app.buttons["恢復預設設定"].tap()
        XCTAssertTrue(app.buttons["還原設定"].waitForExistence(timeout:5));app.buttons["取消"].tap()
        app.buttons["設定"].tap();XCTAssertTrue(app.staticTexts["音樂音量 0%"].waitForExistence(timeout:5))
        reveal(app.buttons["恢復預設設定"],app,up:true);app.buttons["恢復預設設定"].tap();app.buttons["還原設定"].tap()
        assertSecondLevel(app,unlocked:true)
        app.buttons["首頁"].tap();app.buttons["設定"].tap()
        XCTAssertTrue(app.staticTexts["音樂音量 55%"].waitForExistence(timeout:5));XCTAssertTrue(app.staticTexts["音效音量 75%"].exists)
        reveal(app.buttons["清除遊戲進度"],app,up:true);app.buttons["清除遊戲進度"].tap();app.buttons["取消"].tap()
        assertSecondLevel(app,unlocked:true)
        for shouldConfirm in [false,true]{
            app.buttons["首頁"].tap();app.buttons["設定"].tap()
            reveal(app.buttons["清除遊戲進度"],app,up:true);app.buttons["清除遊戲進度"].tap()
            app.buttons["繼續確認"].tap();XCTAssertTrue(app.buttons["確認清除全部遊戲進度"].waitForExistence(timeout:5))
            app.buttons[shouldConfirm ? "確認清除全部遊戲進度":"取消"].tap()
            assertSecondLevel(app,unlocked:!shouldConfirm)
        }
        capture("actual-progress-cleared-levels-locked",app)
        app.buttons["首頁"].tap();app.buttons["結束遊玩"].tap()
        XCTAssertTrue(app.staticTexts["進度已儲存"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["返回首頁"].exists);capture("actual-end-play-saved",app)
        app.buttons["返回首頁"].tap();XCTAssertTrue(app.buttons["start"].waitForExistence(timeout:5))
    }
    func assertSecondLevel(_ app:XCUIApplication,unlocked:Bool){
        XCTAssertTrue(app.buttons["關卡選擇"].waitForExistence(timeout:5));app.buttons["關卡選擇"].tap()
        XCTAssertTrue(app.buttons["level-level_02"].waitForExistence(timeout:5));XCTAssertEqual(app.buttons["level-level_02"].isEnabled,unlocked)
    }
    func perform(_ label:String,_ app:XCUIApplication){
        let deadline=Date().addingTimeInterval(30)
        var attempted=false
        while Date()<deadline{
            if app.buttons["知道了，繼續"].exists{app.buttons["知道了，繼續"].tap();continue}
            let button=app.buttons["primaryCommand"]
            if attempted && button.exists && button.label != label{return}
            if attempted && label=="出餐" && !button.exists{return}
            if button.exists && button.isEnabled && button.isHittable && button.label==label{button.tap();attempted=true}
            RunLoop.current.run(until:Date().addingTimeInterval(0.2))
        }
        capture("FAILED-action-\(label)",app)
        let tree=XCTAttachment(string:app.debugDescription);tree.name="FAILED-action-hierarchy";tree.lifetime = .keepAlways;add(tree)
        XCTFail("Expected legal UI action did not become available: \(label)")
    }
    func reveal(_ element:XCUIElement,_ app:XCUIApplication,up:Bool){
        // SwiftUI can report a partially offscreen Form row as hittable. Require
        // its tap centre to clear the sheet toolbar and bottom safe area too.
        for _ in 0..<6{
            let frame=element.frame,viewport=app.frame
            let above=frame.midY<viewport.minY+150,below=frame.midY>viewport.maxY-100
            if element.isHittable && !above && !below{return}
            if above{app.swipeDown()}else if below || up{app.swipeUp()}else{app.swipeDown()}
        }
        let frame=element.frame
        XCTAssertTrue(element.isHittable && frame.midY>=app.frame.minY+150 && frame.midY<=app.frame.maxY-100,"Control centre remains outside visible form: \(frame)")
    }
    func testHomeLayouts(){
        let app=XCUIApplication();app.launchEnvironment["MFT_UI_SUITE"]="layout";app.launch()
        XCTAssertTrue(app.buttons["start"].waitForExistence(timeout:10));capture("layout-home-standard",app)
        app.buttons["關於"].tap();XCTAssertTrue(app.staticTexts["關於餐車"].waitForExistence(timeout:5));capture("layout-about-local-version-and-sources",app)
        app.buttons["首頁"].tap();app.buttons["遊戲說明"].tap()
        XCTAssertTrue(app.staticTexts["餐車小手冊"].waitForExistence(timeout:5));capture("layout-offline-instructions",app)
        app.buttons["首頁"].tap()
        app.buttons["設定"].tap();XCTAssertTrue(app.navigationBars["餐車設定"].waitForExistence(timeout:5))
        for label in ["高對比資訊","大字介面","左手單手配置"]{reveal(app.switches[label],app,up:true);app.switches[label].tap();XCTAssertEqual(app.switches[label].value as? String,"1")}
        app.buttons["完成"].tap();capture("layout-home-large-contrast-left",app)
        app.buttons["關卡選擇"].tap();XCTAssertTrue(app.buttons["level-level_01"].waitForExistence(timeout:5));capture("layout-levels-large-contrast",app)
        app.buttons["level-level_01"].tap();XCTAssertTrue(app.buttons["beginLevel"].waitForExistence(timeout:5));capture("layout-intro-large-contrast",app)
    }
    func testDebugScenarioScreenshots(){
        for (name,large) in [("busy",false),("warning",false),("covered",false),("tidy",false),("scorched",false),("busy",true),("rig-prototype",false),("kitchen-prototype",false),("kitchen-prototype",true)]{
            let scenario=name=="rig-prototype" || name=="kitchen-prototype" ? "busy":name
            let app=XCUIApplication();app.launchEnvironment["MFT_UI_SCENARIO"]=scenario
            if name=="rig-prototype" || name=="kitchen-prototype"{app.launchEnvironment["MFT_DRAGON_RIG"]="1"}
            if name=="kitchen-prototype"{app.launchEnvironment["MFT_KITCHEN_LAYERS"]="1"}
            if large{
                app.launchEnvironment["MFT_LARGE_TEXT"]="1";app.launchEnvironment["MFT_HIGH_CONTRAST"]="1";app.launchEnvironment["MFT_LEFT_HAND"]="1"
            }
            app.launch()
            XCTAssertTrue(app.staticTexts["測試情境：\(scenario)・不列正式成績"].waitForExistence(timeout:10))
            capture("DEBUG-\(name)\(large ? "-large-contrast-left":"-standard-right")",app);app.terminate()
        }
    }
}
