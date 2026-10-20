import XCTest

/// Actual app rendering of assets; this is not a normal gameplay test or art verdict.
final class ArtReviewTests:XCTestCase {
    override func setUp(){continueAfterFailure=false}
    func testDarkAndLightActualSizePartsAndMotionEvidence(){
        for background in ["dark","light"]{
            let app=XCUIApplication();app.launchEnvironment["MFT_ART_REVIEW"]=background;app.launchEnvironment["MFT_UI_SUITE"]="art-review";app.launch()
            XCTAssertTrue(app.buttons["播放部件動作"].waitForExistence(timeout:10))
            capture("ART-\(background)-five-poses-game-size",app)
            app.buttons["播放部件動作"].tap()
            RunLoop.current.run(until:Date().addingTimeInterval(0.25));capture("ART-\(background)-motion-reach",app)
            RunLoop.current.run(until:Date().addingTimeInterval(1));capture("ART-\(background)-motion-receive",app)
            RunLoop.current.run(until:Date().addingTimeInterval(1.8));capture("ART-\(background)-motion-return-to-anchor",app)
            app.terminate()
        }
    }
    private func capture(_ name:String,_ app:XCUIApplication){
        let shot=XCTAttachment(screenshot:app.screenshot());shot.name=name;shot.lifetime = .keepAlways;add(shot)
    }
}
