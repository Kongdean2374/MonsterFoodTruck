import XCTest
@testable import MonsterFoodTruck

final class SaveStoreTests: XCTestCase {
    func testOrderedWritesBackupAndSettlementTransaction() throws {
        let c=try GameContent.load()
        let dir=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { do {try FileManager.default.removeItem(at:dir)}catch {XCTFail("Fixture cleanup failed: \(error)")} }
        let store=SaveStore(directory:dir,content:c)
        var doc=SaveDocument();doc.revision=1;doc.session=GameSession(level:c.levels[0],mode:.normal,content:c)
        let first=expectation(description:"first write")
        store.write(doc){result in if case let .failure(error)=result {XCTFail("\(error)")};first.fulfill()}
        wait(for:[first],timeout:5)
        doc.revision=2;doc.records[c.levels[0].id]=LevelRecord(normal:3,gentle:0);doc.session=nil
        let second=expectation(description:"settlement")
        store.write(doc){result in if case let .failure(error)=result {XCTFail("\(error)")};second.fulfill()}
        wait(for:[second],timeout:5)
        let saved=store.load().document
        XCTAssertEqual(saved.records[c.levels[0].id]?.best,3);XCTAssertNil(saved.session)
        var old=doc;old.revision=1
        let stale=expectation(description:"stale rejected")
        store.write(old){result in if case .success=result {XCTFail("Stale write accepted")};stale.fulfill()}
        wait(for:[stale],timeout:5)
        try Data("corrupt".utf8).write(to:dir.appendingPathComponent("save-v1.json"))
        let restored=store.load()
        XCTAssertNotNil(restored.notice);XCTAssertEqual(restored.document.revision,1)
        XCTAssertTrue(restored.document.session?.isPaused == true)
    }
    func testSettingsResetKeepsStarsAndRecordsNeverFall() throws {
        var doc=SaveDocument();var record=LevelRecord()
        record.record(3,mode:.gentle);record.record(1,mode:.gentle)
        doc.records["level_01"]=record;doc.settings.music=0
        doc.settings=GameSettings()
        XCTAssertEqual(doc.totalStars,3);XCTAssertEqual(doc.records["level_01"]?.gentle,3)
        try doc.validate(content:GameContent.load())
    }
}
