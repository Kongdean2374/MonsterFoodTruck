import XCTest

/// External evidence harness over the unmodified 66c2929 App, not a new product.
/// Movies are visual evidence for independent review, not automatic art approval.
final class ArtReviewTests:XCTestCase {
    override func setUp(){continueAfterFailure=false}
    override func tearDown(){
        if (testRun?.failureCount ?? 0)>0{
            capture("FAILED-short-capture",XCUIApplication())
            let tree=XCTAttachment(string:XCUIApplication().debugDescription);tree.name="FAILED-accessibility";tree.lifetime = .keepAlways;add(tree)
        }
    }
    func testDarkContinuousMotion(){rig("dark")}
    func testLightContinuousMotion(){rig("light")}
    private func rig(_ background:String){
        let app=XCUIApplication();app.launchEnvironment["MFT_ART_REVIEW"]=background;app.launchEnvironment["MFT_UI_SUITE"]="art-review";app.launch()
        let play=app.buttons["播放部件動作"]
        XCTAssertTrue(play.waitForExistence(timeout:10));capture("rig-\(background)-before",app)
        for cycle in 1...3{
            mark("rig-\(background)-cycle-\(cycle)-before-real-tap")
            play.tap()
            // Each existing App demo is 2.4 s. Continuous external native video
            // covers the full cycle, including the fast intervening frames.
            RunLoop.current.run(until:Date().addingTimeInterval(4))
            mark("rig-\(background)-cycle-\(cycle)-after")
        }
        capture("rig-\(background)-after-three-cycles",app)
        XCTAssertTrue(play.exists);app.terminate()
    }
    func testSoupTransitions(){meal(level:"level_01",order:"L1-1",damaged:false)}
    func testStewRecoveryTransitions(){meal(level:"level_05",order:"L5-1",damaged:true)}
    func testCrispTransitions(){meal(level:"level_04",order:"L4-1",damaged:false)}
    private func meal(level:String,order:String,damaged:Bool){
        let app=XCUIApplication();app.launchEnvironment["MFT_USE_REPLAY_SAVE"]="1";app.launch()
        XCTAssertTrue(app.buttons["關卡選擇"].waitForExistence(timeout:10));app.buttons["關卡選擇"].tap()
        let card=app.buttons["level-\(level)"]
        for _ in 0..<6{if card.exists && card.isHittable && card.frame.maxY<app.frame.maxY-44{break};app.swipeUp()}
        XCTAssertTrue(card.exists && card.isEnabled && card.isHittable);card.tap()
        XCTAssertTrue(app.buttons["beginLevel"].waitForExistence(timeout:5));app.buttons["beginLevel"].tap()
        if app.buttons["放棄目前這局並開始"].waitForExistence(timeout:2){app.buttons["放棄目前這局並開始"].tap()}
        if app.buttons["略過教學"].exists{app.buttons["略過教學"].tap()}
        XCTAssertTrue(app.buttons["quick-\(order)"].waitForExistence(timeout:5));app.buttons["quick-\(order)"].tap()
        mark("\(order)-actual-game-start");perform("備料",app);perform("下鍋",app)
        if damaged{
            let ready=app.buttons.matching(NSPredicate(format:"identifier == %@ AND label == %@","primaryCommand","裝盤")).firstMatch
            XCTAssertTrue(ready.waitForExistence(timeout:25));mark("\(order)-cooked-ready-before-natural-scorch")
            RunLoop.current.run(until:Date().addingTimeInterval(8))
            XCTAssertTrue(app.buttons.matching(NSPredicate(format:"label CONTAINS %@","焦邊・先裝盤")).firstMatch.exists)
        }
        perform("裝盤",app)
        if damaged{
            let bitten=app.buttons.matching(NSPredicate(format:"label CONTAINS %@","被偷嚐・待整理")).firstMatch
            XCTAssertTrue(bitten.waitForExistence(timeout:12),"Wait for the real pending theft; do not inject damage")
            XCTAssertFalse(app.buttons["香草芽"].exists);mark("\(order)-actual-bite-before-repair")
            perform("整理 3 秒",app)
            XCTAssertTrue(app.buttons.matching(NSPredicate(format:"value == %@","已整理・偏好失效")).firstMatch.waitForExistence(timeout:5))
        }
        XCTAssertTrue(app.buttons["蓋上"].waitForExistence(timeout:5));app.buttons["蓋上"].tap()
        XCTAssertTrue(app.buttons["取下"].waitForExistence(timeout:5));XCTAssertFalse(app.buttons["香草芽"].exists)
        mark("\(order)-covered");app.buttons["取下"].tap()
        let herb=app.buttons["香草芽"];XCTAssertTrue(herb.waitForExistence(timeout:5));XCTAssertTrue(herb.isHittable);herb.tap()
        perform("出餐",app)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format:"label BEGINSWITH %@","已服務 1／")).firstMatch.waitForExistence(timeout:5))
        capture("\(order)-one-real-customer-served",app);mark("\(order)-served-before-save")
        app.buttons["pause"].tap();XCTAssertTrue(app.buttons["保存並回首頁"].waitForExistence(timeout:5));app.buttons["保存並回首頁"].tap()
        XCTAssertTrue(app.buttons["繼續遊玩"].waitForExistence(timeout:10));app.terminate()
    }
    private func perform(_ expected:String,_ app:XCUIApplication){
        let deadline=Date().addingTimeInterval(35);var tapped=false
        while Date()<deadline{
            if app.buttons["知道了，繼續"].exists{app.buttons["知道了，繼續"].tap();continue}
            let button=app.buttons["primaryCommand"],exists=button.exists
            let actual=exists ? button.label:"absent"
            if tapped && (!exists || actual != expected){return}
            if !tapped && exists && actual==expected && button.isEnabled && button.isHittable{
                mark("real-command-\(expected)");button.tap();tapped=true
            }
            RunLoop.current.run(until:Date().addingTimeInterval(0.15))
        }
        XCTFail("Actual capture action did not complete: \(expected)")
    }
    private func mark(_ text:String){
        let note=XCTAttachment(string:"\(Date().timeIntervalSince1970): \(text). Wall time aids navigation only; video frame index uses actual presentation timestamps.")
        note.name=text;note.lifetime = .keepAlways;add(note)
    }
    private func capture(_ name:String,_ app:XCUIApplication){
        let shot=XCTAttachment(screenshot:XCUIScreen.main.screenshot());shot.name=name;shot.lifetime = .keepAlways;add(shot)
    }
}
