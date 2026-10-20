import XCTest

final class FlowTests: XCTestCase {
    override func setUp(){continueAfterFailure=false}
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
        let app=XCUIApplication();app.launch()
        XCTAssertTrue(app.buttons["start"].waitForExistence(timeout:10));capture("home",app)
        app.buttons["關卡選擇"].tap();XCTAssertTrue(app.buttons["level-level_01"].waitForExistence(timeout:5));capture("levels-locked",app)
        app.buttons["level-level_01"].tap();XCTAssertTrue(app.buttons["beginLevel"].waitForExistence(timeout:5));capture("level-intro",app)
        app.buttons["beginLevel"].tap()
        if app.buttons["放棄目前這局並開始"].waitForExistence(timeout:2){app.buttons["放棄目前這局並開始"].tap()}
        XCTAssertTrue(app.buttons["知道了，繼續"].waitForExistence(timeout:5));capture("tutorial-first",app)
        app.buttons["知道了，繼續"].tap();app.buttons["quick-L1-1"].tap()
        for action in ["備料","下鍋","裝盤","出餐"]{perform(action,app)}
        capture("normal-play-after-service",app)
        app.buttons["pause"].tap();XCTAssertTrue(app.buttons["保存並回首頁"].waitForExistence(timeout:5));capture("paused",app)
        app.buttons["設定"].tap();XCTAssertTrue(app.switches["高對比資訊"].waitForExistence(timeout:5))
        reveal(app.switches["高對比資訊"],app,up:true);app.switches["高對比資訊"].tap()
        reveal(app.switches["大字介面"],app,up:true);app.switches["大字介面"].tap()
        reveal(app.switches["左手單手配置"],app,up:true);app.switches["左手單手配置"].tap()
        reveal(app.sliders["音樂音量"],app,up:false)
        app.sliders["音樂音量"].adjust(toNormalizedSliderPosition:0);capture("settings-large-contrast-left",app)
        app.buttons["完成"].tap();XCTAssertTrue(app.buttons["繼續營業"].waitForExistence(timeout:5))
        app.buttons["保存並回首頁"].tap();XCTAssertTrue(app.buttons["繼續遊玩"].waitForExistence(timeout:5))
        app.terminate();app.launch();XCTAssertTrue(app.buttons["繼續遊玩"].waitForExistence(timeout:10))
        app.buttons["繼續遊玩"].tap();XCTAssertTrue(app.buttons["繼續營業"].waitForExistence(timeout:5));capture("restored-paused",app)
    }
    func perform(_ label:String,_ app:XCUIApplication){
        let deadline=Date().addingTimeInterval(30)
        while Date()<deadline{
            if app.buttons["知道了，繼續"].exists{app.buttons["知道了，繼續"].tap()}
            let button=app.buttons["primaryCommand"]
            if button.exists && button.isEnabled && button.label==label{button.tap();return}
            RunLoop.current.run(until:Date().addingTimeInterval(0.2))
        }
        XCTFail("Expected legal UI action did not become available: \(label)")
    }
    func reveal(_ element:XCUIElement,_ app:XCUIApplication,up:Bool){
        for _ in 0..<4{if element.isHittable{return};if up{app.swipeUp()}else{app.swipeDown()}}
        XCTAssertTrue(element.isHittable)
    }
    func testDebugScenarioScreenshots(){
        for (name,large) in [("busy",false),("warning",false),("covered",false),("tidy",false),("scorched",false),("busy",true)]{
            let app=XCUIApplication();app.launchEnvironment["MFT_UI_SCENARIO"]=name;app.launch()
            if large{
                app.terminate();app.launchEnvironment["MFT_LARGE_TEXT"]="1";app.launchEnvironment["MFT_HIGH_CONTRAST"]="1";app.launchEnvironment["MFT_LEFT_HAND"]="1";app.launch()
            }
            XCTAssertTrue(app.staticTexts["測試情境：\(name)・不列正式成績"].waitForExistence(timeout:10))
            capture("DEBUG-\(name)\(large ? "-large-contrast-left":"-standard-right")",app);app.terminate()
        }
    }
}
