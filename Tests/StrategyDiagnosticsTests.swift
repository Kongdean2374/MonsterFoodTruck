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
        let summary=XCTAttachment(data:try JSONSerialization.data(withJSONObject:["scope":"Engineering diagnosis using the actual Domain and public validators. Results do not assert fun, human playtesting or Dot acceptance. No future orders used by prioritization; both stoves interchangeable; no injected scores or food states.","observations":rows],options:[.prettyPrinted,.sortedKeys]),uniformTypeIdentifier:"public.json")
        summary.name="STRATEGY_DIAGNOSTICS";summary.lifetime = .keepAlways;add(summary)
    }
}
