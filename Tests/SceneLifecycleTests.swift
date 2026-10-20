import XCTest
import SpriteKit
@testable import MonsterFoodTruck

final class SceneLifecycleTests:XCTestCase{
    @MainActor func testSettingsWriteFailureStaysOpenAndCanRetryAfterIORecovery() async throws{
        let directory=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try Data("file blocking save directory".utf8).write(to:directory)
        defer{do{try FileManager.default.removeItem(at:directory)}catch{XCTFail("Fixture cleanup failed: \(error)")}}
        let model=AppModel(saveDirectory:directory)
        model.openSettings();model.updateSettings{$0.music=0.2};model.closeSettingsToHelp()
        let failed=await withCheckedContinuation{continuation in model.persist{continuation.resume(returning:$0)}}
        XCTAssertFalse(failed);XCTAssertTrue(model.settingsPresented);XCTAssertFalse(model.isClosingSettings)
        XCTAssertNotNil(model.message);XCTAssertEqual(model.screen,.home)
        try FileManager.default.removeItem(at:directory)
        model.closeSettingsToHelp()
        let recovered=await withCheckedContinuation{continuation in model.persist{continuation.resume(returning:$0)}}
        XCTAssertTrue(recovered);XCTAssertFalse(model.settingsPresented);XCTAssertNil(model.message)
        model.settingsDidDismiss();XCTAssertEqual(model.screen,.help)
        let saved=SaveStore(directory:directory,content:try XCTUnwrap(model.content)).load()
        XCTAssertEqual(saved.document.settings.music,0.2)
    }
    @MainActor func testPracticeNavigationAndRestartCannotChangeFormalAwards() async throws{
        let directory=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer{do{try FileManager.default.removeItem(at:directory)}catch{XCTFail("Fixture cleanup failed: \(error)")}}
        let model=AppModel(saveDirectory:directory)
        model.screen = .practiceIntroduction;model.screen = .home;model.startButton()
        XCTAssertEqual(model.screen,.introduction("level_01"))
        model.requestBegin("level_01");XCTAssertFalse(try XCTUnwrap(model.session).isPractice)
        model.begin("level_01",practice:true);model.confirmed(.restart)
        XCTAssertTrue(try XCTUnwrap(model.session).isPractice,"Restarting practice must not turn it into an awarding formal run")
        model.startButton();XCTAssertNotNil(model.confirmation)
        model.confirmation=nil
        model.begin("level_01");XCTAssertFalse(try XCTUnwrap(model.session).isPractice)
        try await withCheckedThrowingContinuation{(continuation:CheckedContinuation<Void,Error>) in
            model.persist{success in if success{continuation.resume()}else{continuation.resume(throwing:GameError.invalid("Practice fixture save failed"))}}
        }
        XCTAssertTrue(model.document.records.isEmpty)
    }
    @MainActor func testFirstTutorialSeedsOpaqueCharacterBeforeAnyResume() async throws{
        let directory=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer{do{try FileManager.default.removeItem(at:directory)}catch{XCTFail("Fixture cleanup failed: \(error)")}}
        let model=AppModel(saveDirectory:directory)
        XCTAssertNil(model.startupError)
        model.begin("level_01")
        XCTAssertNotNil(model.lesson);XCTAssertTrue(model.session?.isPaused == true);XCTAssertTrue(model.kitchen.isPaused)
        let sprite=try XCTUnwrap(model.kitchen.childNode(withName:"L1-1") as? SKSpriteNode)
        XCTAssertNotNil(sprite.texture);XCTAssertEqual(sprite.alpha,1,accuracy:0.0001)
        model.kitchen.size=CGSize(width:375,height:324)
        XCTAssertEqual(model.kitchen.children.filter{$0.name=="L1-1"}.count,1)
        XCTAssertEqual(sprite.alpha,1,accuracy:0.0001);model.tick();XCTAssertEqual(model.session?.time,0)
        try await withCheckedThrowingContinuation{(continuation:CheckedContinuation<Void,Error>) in
            model.persist{success in if success{continuation.resume()}else{continuation.resume(throwing:GameError.invalid("Tutorial fixture save failed"))}}
        }
        XCTAssertEqual(model.session?.time,0);XCTAssertTrue(model.session?.isPaused == true)
    }
}
