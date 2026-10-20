import XCTest
import SpriteKit
@testable import MonsterFoodTruck

final class SceneLifecycleTests:XCTestCase{
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
