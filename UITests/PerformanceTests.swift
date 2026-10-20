import XCTest

/// Twenty real scene entries. No injected orders, clocks, scores or completion.
final class PerformanceTests:XCTestCase {
    override func setUp(){continueAfterFailure=false}
    override func tearDown(){
        if (testRun?.failureCount ?? 0)>0{
            let shot=XCTAttachment(screenshot:XCUIScreen.main.screenshot());shot.name="FAILED-performance-actual-screen";shot.lifetime = .keepAlways;add(shot)
        }
    }
    func testTwentyRealSceneEntriesKeepNodesAndAudioBounded(){
        let app=XCUIApplication();app.launchEnvironment["MFT_UI_SUITE"]="performance";app.launchEnvironment["MFT_PERFORMANCE"]="1"
        let launchedAt=Date();app.launch()
        XCTAssertTrue(app.buttons["start"].waitForExistence(timeout:10))
        let launchNote=XCTAttachment(string:"Fresh isolated save directory; first process launch to home accessibility availability: \(Date().timeIntervalSince(launchedAt))s including XCTest overhead. OS filesystem cache not controlled. Simulator measurement, not physical-device cold launch.")
        launchNote.name="performance-launch-method";launchNote.lifetime = .keepAlways;add(launchNote)
        var allocatedAudio:String?
        for entry in 1...20{
            app.buttons["start"].tap();XCTAssertTrue(app.buttons["beginLevel"].waitForExistence(timeout:5));app.buttons["beginLevel"].tap()
            if entry==1{XCTAssertTrue(app.buttons["略過教學"].waitForExistence(timeout:5));app.buttons["略過教學"].tap()}
            XCTAssertTrue(app.buttons["customer-L1-1"].waitForExistence(timeout:5))
            RunLoop.current.run(until:Date().addingTimeInterval(2))
            app.buttons["primaryCommand"].tap()
            RunLoop.current.run(until:Date().addingTimeInterval(2))
            let value=app.staticTexts["performance-diagnostic"].value as? String ?? ""
            XCTAssertTrue(value.contains("entries=\(entry);nodes=1;"),"Unexpected actual node state: \(value)")
            XCTAssertTrue(value.hasSuffix("error=none"),"Diagnostic export failed: \(value)")
            let audio=value.components(separatedBy:";audio=").last?.components(separatedBy:";").first ?? "missing"
            if let allocatedAudio{XCTAssertEqual(audio,allocatedAudio,"Audio players grew during scene reentry")}else{allocatedAudio=audio;XCTAssertGreaterThan(Int(audio) ?? 0,0)}
            app.buttons["pause"].tap();XCTAssertTrue(app.buttons["保存並回首頁"].waitForExistence(timeout:5))
            if entry==1 || entry==20{
                let shot=XCTAttachment(screenshot:app.screenshot());shot.name="performance-real-entry-\(entry)-paused";shot.lifetime = .keepAlways;add(shot)
            }
            app.buttons["放棄本局"].tap();app.buttons["確認放棄本局"].tap()
            XCTAssertTrue(app.buttons["start"].waitForExistence(timeout:5))
        }
    }
}
