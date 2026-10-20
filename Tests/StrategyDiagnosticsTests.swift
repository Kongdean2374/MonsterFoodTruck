import XCTest
@testable import MonsterFoodTruck

final class StrategyDiagnosticsTests:XCTestCase{
    private struct Evidence:Encodable{
        var policy:String;var commandInterval:Double;var selectionDelay:Double
        var idleSeconds:Double;var longestIdleSpan:Double;var selectionCount:Int
        var session:GameSession
    }
    func testThreeStrategiesAtConservativeInputSpeedsExportActualModelEvidence() throws{
        let content=try GameContent.load()
        var rows:[[String:Any]]=[]
        for mode in PlayMode.allCases{for level in content.levels.dropFirst(2){for policy in CommandReplayPlanner.Policy.allCases{for interval in [0.6,1.2,1.8]{
            let observed=try CommandReplayPlanner.observe(level:level,mode:mode,content:content,policy:policy,interval:interval,selectionDelay:0.4)
            let session=observed.session
            XCTAssertTrue(session.finished(content:content));try session.validate(content:content)
            for pair in zip(session.inputs,session.inputs.dropFirst()){XCTAssertGreaterThanOrEqual(pair.1.time-pair.0.time,interval-0.0001)}
            let row:[String:Any]=["level":level.id,"mode":mode.rawValue,"policy":policy.rawValue,"command_interval":interval,"selection_delay":0.4,"duration":session.time,"served":session.served,"preferences":session.preferences,"stars":session.stars(content:content),"lost":session.lost,"scorched":session.scorchCount,"nibbled":session.nibbleCount,"warnings":session.events.filter{$0.kind=="nibbleWarning"}.count,"covers":session.events.filter{$0.kind=="covered"}.count,"idle_seconds_no_legal_work":observed.idleSeconds,"longest_idle_span":observed.longestIdleSpan,"selections":observed.selectionCount]
            rows.append(row)
            let evidence=Evidence(policy:policy.rawValue,commandInterval:interval,selectionDelay:0.4,idleSeconds:observed.idleSeconds,longestIdleSpan:observed.longestIdleSpan,selectionCount:observed.selectionCount,session:session)
            let attachment=XCTAttachment(data:try JSONEncoder().encode(evidence),uniformTypeIdentifier:"public.json")
            attachment.name="strategy-\(level.id)-\(mode == .normal ? "normal":"gentle")-\(policy.rawValue)-\(interval)";attachment.lifetime = .keepAlways;add(attachment)
        }}}}
        var controls:[[String:Any]]=[];var protectionHelped=false
        for mode in PlayMode.allCases{for level in content.levels.dropFirst(2){for interval in [0.6,1.2,1.8]{
            let protected=try CommandReplayPlanner.observe(level:level,mode:mode,content:content,interval:interval,selectionDelay:0.4)
            let unprotected=try CommandReplayPlanner.observe(level:level,mode:mode,content:content,interval:interval,selectionDelay:0.4,protectPlates:false)
            try unprotected.session.validate(content:content);XCTAssertTrue(unprotected.session.finished(content:content))
            if protected.session.served>unprotected.session.served || protected.session.preferences>unprotected.session.preferences{protectionHelped=true}
            controls.append(["level":level.id,"mode":mode.rawValue,"interval":interval,"covered_count":protected.session.events.filter{$0.kind=="covered"}.count,"with_protection_served":protected.session.served,"with_protection_preferences":protected.session.preferences,"without_protection_served":unprotected.session.served,"without_protection_preferences":unprotected.session.preferences])
            let attachment=XCTAttachment(data:try JSONEncoder().encode(unprotected.session),uniformTypeIdentifier:"public.json");attachment.name="unprotected-control-\(level.id)-\(mode == .normal ? "normal":"gentle")-\(interval)";attachment.lifetime = .keepAlways;add(attachment)
        }}}
        XCTAssertTrue(controls.contains{($0["covered_count"] as? Int ?? 0)>0},"Late-level normal validated strategies must actually use the cloche")
        XCTAssertTrue(protectionHelped,"A paired normal-input control must show a concrete protection benefit; no idle-only fixture")
        let summary=XCTAttachment(data:try JSONSerialization.data(withJSONObject:["scope":"Engineering diagnosis using the actual Domain and public validators. Results do not assert fun, human playtesting or Dot acceptance. No future orders used by prioritization; both stoves interchangeable; no injected scores or food states. Three strategies plus paired dynamic runs with plate protection disabled.","observations":rows,"unprotected_controls":controls],options:[.prettyPrinted,.sortedKeys]),uniformTypeIdentifier:"public.json")
        summary.name="STRATEGY_DIAGNOSTICS";summary.lifetime = .keepAlways;add(summary)
    }
}
