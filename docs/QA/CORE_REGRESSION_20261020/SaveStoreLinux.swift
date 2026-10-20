import XCTest
import Foundation

final class SaveStoreTests: XCTestCase {
    func save(_ document:SaveDocument,_ store:SaveStore) async throws{
        try await withCheckedThrowingContinuation{(continuation:CheckedContinuation<Void,Error>) in store.write(document){continuation.resume(with:$0)}}
    }
    func testIncompatibleContentSessionKeepsSettingsAndPermanentProgressWritable() async throws{
        let content=try JSONDecoder().decode(GameContent.self,from:Data(contentsOf:URL(fileURLWithPath:"MonsterFoodTruck/Resources/Content.json"))),directory=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
        defer{do{try FileManager.default.removeItem(at:directory)}catch{XCTFail("Fixture cleanup failed: \(error)")}}
        var document=SaveDocument();document.revision=10;document.settings.music=0;document.settings.haptics=false;document.settings.leftHanded=true;document.settings.nextMode = .gentle
        document.records[content.levels[0].id]=LevelRecord(normal:3,gentle:2);document.session=GameSession(level:content.levels[0],mode:.normal,content:content)
        var object=try XCTUnwrap(JSONSerialization.jsonObject(with:JSONEncoder().encode(document)) as? [String:Any])
        var oldSession=try XCTUnwrap(object["session"] as? [String:Any]);oldSession["contentVersion"]=content.version-1;object["session"]=oldSession
        try JSONSerialization.data(withJSONObject:object).write(to:directory.appendingPathComponent("save-v1.json"))
        let store=SaveStore(directory:directory,content:content),loaded=store.load()
        XCTAssertNil(loaded.document.session);XCTAssertEqual(loaded.document.totalStars,3);XCTAssertEqual(loaded.document.settings,document.settings)
        XCTAssertTrue(loaded.notice?.contains("資料不相容") == true);XCTAssertFalse(loaded.preserveUnreadableFiles)
        var next=loaded.document;next.revision+=1;next.settings.music=0.2;try await save(next,store)
        let persisted=store.load().document
        XCTAssertEqual(persisted.totalStars,3);XCTAssertNil(persisted.session);XCTAssertEqual(persisted.settings.music,0.2)
        XCTAssertFalse(persisted.settings.haptics);XCTAssertTrue(persisted.settings.leftHanded);XCTAssertEqual(persisted.settings.nextMode,.gentle)
    }
    func testCorruptSessionPreservesProgressAndFallsBackIndependently() async throws{
        let content=try JSONDecoder().decode(GameContent.self,from:Data(contentsOf:URL(fileURLWithPath:"MonsterFoodTruck/Resources/Content.json")))
        let dir=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer{do{try FileManager.default.removeItem(at:dir)}catch{XCTFail("Fixture cleanup failed: \(error)")}}
        let store=SaveStore(directory:dir,content:content)
        var document=SaveDocument();document.revision=1;document.session=GameSession(level:content.levels[0],mode:.normal,content:content)
        try await save(document,store)
        document.revision=2;document.settings.music=0.2;document.records[content.levels[0].id]=LevelRecord(normal:3,gentle:0)
        try await save(document,store)
        var object=try XCTUnwrap(JSONSerialization.jsonObject(with:JSONEncoder().encode(document)) as? [String:Any])
        object["session"]="malformed session"
        let broken=try JSONSerialization.data(withJSONObject:object)
        try broken.write(to:dir.appendingPathComponent("save-v1.json"))
        let recovered=store.load()
        XCTAssertEqual(recovered.document.totalStars,3);XCTAssertEqual(recovered.document.settings.music,0.2)
        XCTAssertNotNil(recovered.document.session);XCTAssertTrue(recovered.document.session?.isPaused == true)
        XCTAssertTrue(recovered.notice?.contains("備份") == true)
        try broken.write(to:dir.appendingPathComponent("save-v1.backup.json"))
        let permanentOnly=store.load()
        XCTAssertEqual(permanentOnly.document.totalStars,3);XCTAssertNil(permanentOnly.document.session)
        XCTAssertTrue(permanentOnly.notice?.contains("永久進度已保留") == true)
        XCTAssertFalse(permanentOnly.preserveUnreadableFiles,"Readable permanent progress must still allow settings writes")
        try Data("unreadable".utf8).write(to:dir.appendingPathComponent("save-v1.json"))
        try Data("unreadable".utf8).write(to:dir.appendingPathComponent("save-v1.backup.json"))
        XCTAssertTrue(store.load().preserveUnreadableFiles,"Two unreadable files require an explicit fresh start before replacement")
    }
    func testOrderedWritesBackupAndSettlementTransaction() async throws {
        let c=try JSONDecoder().decode(GameContent.self,from:Data(contentsOf:URL(fileURLWithPath:"MonsterFoodTruck/Resources/Content.json")))
        let dir=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { do {try FileManager.default.removeItem(at:dir)}catch {XCTFail("Fixture cleanup failed: \(error)")} }
        let store=SaveStore(directory:dir,content:c)
        var doc=SaveDocument();doc.revision=1;doc.session=GameSession(level:c.levels[0],mode:.normal,content:c)
        let first=expectation(description:"first write")
        store.write(doc){result in if case let .failure(error)=result {XCTFail("\(error)")};first.fulfill()}
        await fulfillment(of:[first],timeout:5)
        doc.revision=2;doc.records[c.levels[0].id]=LevelRecord(normal:3,gentle:0);doc.session=nil
        let second=expectation(description:"settlement")
        store.write(doc){result in if case let .failure(error)=result {XCTFail("\(error)")};second.fulfill()}
        await fulfillment(of:[second],timeout:5)
        let saved=store.load().document
        XCTAssertEqual(saved.records[c.levels[0].id]?.best,3);XCTAssertNil(saved.session)
        var old=doc;old.revision=1
        let stale=expectation(description:"stale rejected")
        store.write(old){result in if case .success=result {XCTFail("Stale write accepted")};stale.fulfill()}
        await fulfillment(of:[stale],timeout:5)
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
        try doc.validate(content:JSONDecoder().decode(GameContent.self,from:Data(contentsOf:URL(fileURLWithPath:"MonsterFoodTruck/Resources/Content.json"))))
    }
}
