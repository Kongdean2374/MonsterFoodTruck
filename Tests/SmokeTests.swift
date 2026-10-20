import XCTest
import UIKit
@testable import MonsterFoodTruck

final class SmokeTests: XCTestCase {
    func testBundleIdentity() {
        XCTAssertEqual(Bundle.main.bundleIdentifier, "cc.chaihome.monsterfoodtruck")
        XCTAssertNotNil(UIImage(named:"LaunchMark",in:Bundle.main,compatibleWith:nil),"Compiled offline launch artwork must resolve from the real app catalog")
    }
}
