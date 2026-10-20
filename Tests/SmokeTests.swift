import XCTest
@testable import MonsterFoodTruck

final class SmokeTests: XCTestCase {
    func testBundleIdentity() {
        XCTAssertEqual(Bundle.main.bundleIdentifier, "cc.chaihome.monsterfoodtruck")
    }
}
