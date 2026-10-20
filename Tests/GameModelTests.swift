import XCTest
@testable import MonsterFoodTruck

final class GameModelTests: XCTestCase {
    func content() throws -> GameContent { try GameContent.load() }
    func fixture(_ monster: MonsterID = .mossDeer, recipe: RecipeID = .starSoup, withImp: Bool = false) throws -> (GameContent, GameSession) {
        var c = try content()
        var plans = [PlannedOrder(id: "test-1", scheduledAt: 0, monster: monster, recipe: recipe)]
        if withImp { plans.append(PlannedOrder(id: "test-2", scheduledAt: 4, monster: .nibbleImp, recipe: .moonCrisp)) }
        c.levels[0].orders = plans
        var s = GameSession(level: c.levels[0], mode: .normal, content: c); s.isPaused = false
        return (c,s)
    }
    func plate(_ session: inout GameSession, content: GameContent, id: String = "test-1") {
        XCTAssertNil(session.send(.prepare(id),content:content))
        let r=content.recipe(session.orders.first { $0.id == id }?.recipe ?? .starSoup)
        session.advance(to:session.time+r.prep,content:content)
        XCTAssertNil(session.send(.cook(id),content:content))
        session.advance(to:session.time+r.cook,content:content)
        XCTAssertNil(session.send(.plate(id),content:content))
    }
    func testAllRecipesAndToppings() throws {
        for recipe in RecipeID.allCases {
            var (c,s)=try fixture(recipe:recipe)
            plate(&s,content:c)
            XCTAssertNil(s.send(.garnish("test-1",.star),content:c))
            s.advance(to:s.time+2,content:c)
            XCTAssertNil(s.send(.garnish("test-1",.herb),content:c))
            s.advance(to:s.time+2,content:c)
            XCTAssertNil(s.send(.serve("test-1"),content:c))
            XCTAssertEqual(s.served,1); XCTAssertEqual(s.preferences,1)
            try s.validate(content:c)
        }
    }
    func testDuplicateInputAndResourceCapacity() throws {
        var c=try content()
        c.levels[0].orders=(0..<3).map { PlannedOrder(id:"o\($0)",scheduledAt:Double($0*4),monster:.mossDeer,recipe:.starSoup) }
        var s=GameSession(level:c.levels[0],mode:.normal,content:c);s.isPaused=false
        XCTAssertNil(s.send(.prepare("o0"),token:"same",content:c))
        XCTAssertNotNil(s.send(.prepare("o0"),token:"same",content:c))
        s.advance(to:4,content:c);XCTAssertNil(s.send(.prepare("o1"),content:c))
        s.advance(to:8,content:c);XCTAssertNotNil(s.send(.prepare("o2"),content:c))
        XCTAssertEqual(s.activeOrders.filter{$0.station == .prep}.count,2)
        try s.validate(content:c)
        s.advance(to:100,content:c)
        XCTAssertTrue(s.activeOrders.isEmpty);XCTAssertEqual(s.lost,3)
        XCTAssertTrue(s.orders.allSatisfy{$0.station == nil && !$0.isCovered})
    }
    func testPausedClockAndSnapshotRoundTrip() throws {
        var (c,s)=try fixture(withImp:true);plate(&s,content:c)
        s.advance(to:20,content:c);XCTAssertEqual(s.nibbleTarget,"test-1")
        s.isPaused=true;let before=s.time;s.advance(to:10000,content:c);XCTAssertEqual(s.time,before)
        let data=try JSONEncoder().encode(s)
        let restored=try JSONDecoder().decode(GameSession.self,from:data)
        try restored.validate(content:c)
        XCTAssertEqual(restored.time,s.time);XCTAssertEqual(restored.nibbleTarget,s.nibbleTarget)
        XCTAssertEqual(restored.orders[0].warningRemaining,s.orders[0].warningRemaining)
    }
    func testCoverPausesWarningWithoutResetAndTidyNeverRestoresPreference() throws {
        var (c,s)=try fixture(withImp:true);plate(&s,content:c)
        s.advance(to:21,content:c)
        let remaining=s.orders[0].warningRemaining
        XCTAssertNil(s.send(.cover("test-1"),content:c))
        s.advance(to:26,content:c)
        XCTAssertEqual(s.orders[0].warningRemaining,remaining)
        XCTAssertNotNil(s.send(.garnish("test-1",.herb),content:c))
        XCTAssertNil(s.send(.uncover("test-1"),content:c))
        s.advance(to:29,content:c);XCTAssertEqual(s.nibbleCount,1)
        XCTAssertNotNil(s.send(.serve("test-1"),content:c))
        XCTAssertNil(s.send(.tidy("test-1"),content:c))
        s.advance(to:32,content:c)
        XCTAssertNil(s.send(.garnish("test-1",.herb),content:c));s.advance(to:34,content:c)
        XCTAssertNil(s.send(.serve("test-1"),content:c))
        XCTAssertEqual(s.served,1);XCTAssertEqual(s.preferences,0)
    }
    func testDeadlineEqualityHeatAndScorch() throws {
        var (c,s)=try fixture(.emberDragon)
        plate(&s,content:c);let cooked=s.orders[0].cookedAt ?? -100
        s.advance(to:cooked+9,content:c);XCTAssertNil(s.send(.serve("test-1"),content:c));XCTAssertEqual(s.preferences,1)
        var (_,late)=try fixture(.emberDragon);plate(&late,content:c)
        late.advance(to:cooked+9.1,content:c);XCTAssertNil(late.send(.serve("test-1"),content:c));XCTAssertEqual(late.preferences,0)
        var (d,deadline)=try fixture();plate(&deadline,content:d)
        deadline.advance(to:65,content:d);XCTAssertNil(deadline.send(.serve("test-1"),content:d));XCTAssertEqual(deadline.served,1)
        var (_,scorch)=try fixture();XCTAssertNil(scorch.send(.prepare("test-1"),content:d))
        scorch.advance(to:3,content:d);XCTAssertNil(scorch.send(.cook("test-1"),content:d))
        scorch.advance(to:20,content:d);XCTAssertEqual(scorch.scorchCount,1)
        let notice=try XCTUnwrap(scorch.events.first{$0.kind=="scorchWarning"})
        let burned=try XCTUnwrap(scorch.events.first{$0.kind=="scorched"})
        XCTAssertEqual(notice.time,17,accuracy:0.0001);XCTAssertGreaterThanOrEqual(burned.time-notice.time,GameRules.scorchNotice)
        XCTAssertNil(scorch.send(.plate("test-1"),content:d));XCTAssertNil(scorch.send(.tidy("test-1"),content:d))
        scorch.advance(to:23,content:d);XCTAssertFalse(scorch.orders[0].needsTidy);XCTAssertTrue(scorch.orders[0].everScorched)
    }
    func testLongFramesMatchSmallSteps() throws {
        var (c,a)=try fixture(withImp:true);plate(&a,content:c)
        var b=a
        a.advance(to:60,content:c)
        for step in 1...470 { b.advance(to:13+Double(step)/10,content:c) }
        XCTAssertEqual(a.served,b.served);XCTAssertEqual(a.lost,b.lost);XCTAssertEqual(a.nibbleCount,b.nibbleCount)
        XCTAssertEqual(a.events.map(\.kind),b.events.map(\.kind))
    }
    func testNoImpNoTheftAndCancelledToppingHasNoCredit() throws {
        var (c,s)=try fixture();plate(&s,content:c)
        XCTAssertNil(s.send(.garnish("test-1",.herb),content:c))
        s.advance(to:14,content:c)
        XCTAssertNil(s.send(.cancelGarnish("test-1"),content:c))
        s.advance(to:30,content:c)
        XCTAssertNil(s.nibbleTarget);XCTAssertEqual(s.nibbleCount,0);XCTAssertNil(s.orders[0].topping)
        XCTAssertNil(s.send(.serve("test-1"),content:c));XCTAssertEqual(s.preferences,0)
        XCTAssertNotNil(s.send(.serve("test-1"),content:c));XCTAssertEqual(s.served,1)
    }
    func testQueuePatienceStartsAtActualAdmissionWithFreshNoticeAfterFull() throws {
        var c=try content()
        c.levels[0].orders=(0..<5).map{PlannedOrder(id:"q\($0)",scheduledAt:Double($0*4),monster:.mossDeer,recipe:.starSoup)}
        var s=GameSession(level:c.levels[0],mode:.normal,content:c);s.isPaused=false
        s.advance(to:12,content:c);XCTAssertEqual(s.activeOrders.count,3);XCTAssertTrue(s.waitingForSlot)
        s.advance(to:65.1,content:c);XCTAssertEqual(s.orders.count,3)
        let admission=s.nextAdmissionAt ?? 0
        XCTAssertGreaterThanOrEqual(admission,69)
        s.advance(to:admission,content:c)
        let fourth=try XCTUnwrap(s.orders.first{$0.id=="q3"})
        XCTAssertEqual(fourth.deadline-fourth.admittedAt,65,accuracy:0.0001)
        XCTAssertLessThanOrEqual(s.activeOrders.count,3)
        try s.validate(content:c)
    }
    func testImpNeverTargetsItsOwnPlate() throws {
        var (c,s)=try fixture(.nibbleImp);plate(&s,content:c)
        s.advance(to:35,content:c);XCTAssertNil(s.nibbleTarget);XCTAssertEqual(s.nibbleCount,0)
    }
    func testCoveredServiceReturnsClocheAndServingActorCancelsWarning() throws{
        var (c,s)=try fixture(withImp:true);plate(&s,content:c)
        XCTAssertNil(s.send(.cover("test-1"),content:c));XCTAssertNil(s.send(.serve("test-1"),content:c))
        XCTAssertFalse(s.orders[0].isCovered)
        plate(&s,content:c,id:"test-2");XCTAssertNil(s.send(.cover("test-2"),content:c))
        XCTAssertNil(s.send(.serve("test-2"),content:c));XCTAssertFalse(s.activeOrders.contains(where:\.isCovered));try s.validate(content:c)

        var (_,a)=try fixture(withImp:true)
        XCTAssertNil(a.send(.prepare("test-1"),content:c));a.advance(to:3,content:c);XCTAssertNil(a.send(.cook("test-1"),content:c))
        a.advance(to:4,content:c);XCTAssertNil(a.send(.prepare("test-2"),content:c))
        a.advance(to:8,content:c);XCTAssertNil(a.send(.cook("test-2"),content:c))
        a.advance(to:13,content:c);XCTAssertNil(a.send(.plate("test-1"),content:c))
        a.advance(to:16,content:c);XCTAssertNil(a.send(.plate("test-2"),content:c))
        a.advance(to:20,content:c);XCTAssertEqual(a.nibbleTarget,"test-1")
        XCTAssertNil(a.send(.serve("test-2"),content:c));XCTAssertNil(a.nibbleActor);XCTAssertNil(a.nibbleTarget)
        a.advance(to:25,content:c);XCTAssertEqual(a.nibbleCount,0);try a.validate(content:c)
    }
    func testCorruptSnapshotRejectsInvalidStationAndVersion() throws {
        let (c,s)=try fixture()
        let encoded=try JSONEncoder().encode(s)
        var object=try XCTUnwrap(JSONSerialization.jsonObject(with:encoded) as? [String:Any])
        object["schemaVersion"]=999
        let bad=try JSONDecoder().decode(GameSession.self,from:JSONSerialization.data(withJSONObject:object))
        XCTAssertThrowsError(try bad.validate(content:c))
        object["schemaVersion"]=1
        var orders=try XCTUnwrap(object["orders"] as? [[String:Any]])
        orders[0]["station"]="stove";orders[0]["slot"]=0;object["orders"]=orders
        let impossibleStation=try JSONDecoder().decode(GameSession.self,from:JSONSerialization.data(withJSONObject:object))
        XCTAssertThrowsError(try impossibleStation.validate(content:c))
    }
    func testAllSixScoringBoundariesThroughLegalCommands() throws{
        let c=try content()
        let thresholds=[(3,3),(3,3),(4,4),(5,5),(6,5),(7,7)]
        for mode in PlayMode.allCases{for (index,level) in c.levels.enumerated(){
            let (pass,preference)=thresholds[index]
            XCTAssertEqual(level.passCount,pass);XCTAssertEqual(level.preferenceCount,preference)
            let reference=try CommandReplayPlanner.run(level:level,mode:mode,content:c)
            for count in [pass-1,pass] where count<level.orders.count{
                let accepted=Set(level.orders.prefix(count).map(\.id))
                var s=GameSession(level:level,mode:mode,content:c);s.isPaused=false
                for input in reference.inputs where accepted.contains(input.command.orderID){
                    s.advance(to:input.time,content:c);XCTAssertNil(s.send(input.command,content:c))
                }
                s.advance(to:300,content:c);try s.validate(content:c)
                XCTAssertTrue(s.finished(content:c));XCTAssertEqual(s.served,count)
                XCTAssertEqual(s.stars(content:c),count<pass ? 0:1,"\(level.id), served \(count)")
            }
            let automatic=level.orders.filter{$0.monster == .emberDragon}.count
            for target in [preference-1,preference]{
                let topped=Set(level.orders.filter{$0.monster != .emberDragon}.prefix(target-automatic).map(\.id))
                var s=GameSession(level:level,mode:mode,content:c);s.isPaused=false
                for input in reference.inputs{
                    if case let .garnish(id,_)=input.command,!topped.contains(id){continue}
                    s.advance(to:input.time,content:c);XCTAssertNil(s.send(input.command,content:c))
                }
                s.advance(to:reference.time,content:c);try s.validate(content:c)
                XCTAssertEqual(s.served,level.orders.count);XCTAssertEqual(s.preferences,target)
                XCTAssertEqual(s.stars(content:c),target==preference ? 3:2,"\(level.id), preferences \(target)")
            }
        }}
    }
    func testSixLevelsNormalAndGentleReferenceReplay() throws {
        let c=try content()
        for mode in PlayMode.allCases { for level in c.levels {
            let result=try CommandReplayPlanner.run(level:level,mode:mode,content:c)
            XCTAssertEqual(result.stars(content:c),3,"\(level.id) \(mode.rawValue)")
            XCTAssertEqual(result.served,level.orders.count)
            for pair in zip(result.inputs,result.inputs.dropFirst()) { XCTAssertGreaterThanOrEqual(pair.1.time-pair.0.time,0.5999) }
            var replay=GameSession(level:level,mode:mode,content:c);replay.isPaused=false
            for input in result.inputs {
                replay.advance(to:input.time,content:c);XCTAssertNil(replay.send(input.command,content:c))
                let snapshot=try JSONDecoder().decode(GameSession.self,from:JSONEncoder().encode(replay))
                try snapshot.validate(content:c)
                XCTAssertEqual(snapshot.time,replay.time);XCTAssertEqual(snapshot.orders.map(\.stage),replay.orders.map(\.stage))
            }
            replay.advance(to:result.time,content:c)
            XCTAssertEqual(replay.stars(content:c),3);try replay.validate(content:c)
            let attachment=XCTAttachment(data:try JSONEncoder().encode(result),uniformTypeIdentifier:"public.json")
            attachment.name="reference-\(level.id)-\(mode == .normal ? "normal":"gentle")"
            attachment.lifetime = .keepAlways
            add(attachment)
        }}
    }
}
