import Foundation

/// Development-only executable compiled with the exact App Domain sources.
/// iOS UI/build validation remains separate; no alternative game simulation.
@main enum BalanceDiagnostics {
    static func main() throws {
        guard CommandLine.arguments.count==3 else{throw GameError.invalid("Usage: BalanceDiagnostics Content.json output.json")}
        let source=URL(fileURLWithPath:CommandLine.arguments[1])
        let content=try JSONDecoder().decode(GameContent.self,from:Data(contentsOf:source))
        try content.validate()
        var rows:[[String:Any]]=[]
        let selectionDelay=Double(ProcessInfo.processInfo.environment["MFT_DIAGNOSTIC_SELECTION_DELAY"] ?? "0.4") ?? 0.4
        let protect=ProcessInfo.processInfo.environment["MFT_DIAGNOSTIC_PROTECT"] != "0"
        for mode in PlayMode.allCases{for level in content.levels.dropFirst(2){for policy in CommandReplayPlanner.Policy.allCases{for interval in [0.6,1.2,1.8]{
            let observed=try CommandReplayPlanner.observe(level:level,mode:mode,content:content,policy:policy,interval:interval,selectionDelay:selectionDelay,protectPlates:protect)
            let session=observed.session;try session.validate(content:content)
            rows.append(["level":level.id,"mode":mode.rawValue,"policy":policy.rawValue,"command_interval":interval,"selection_delay":selectionDelay,"protect_plates":protect,"duration":session.time,"served":session.served,"preferences":session.preferences,"stars":session.stars(content:content),"lost":session.lost,"scorched":session.scorchCount,"nibbled":session.nibbleCount,"warnings":session.events.filter{$0.kind=="nibbleWarning"}.count,"covers":session.events.filter{$0.kind=="covered"}.count,"idle_seconds_no_legal_work":observed.idleSeconds,"longest_idle_span":observed.longestIdleSpan,"selections":observed.selectionCount])
        }}}}
        let report:[String:Any]=["method":"Exact App GameContent, GameSession and CommandReplayPlanner sources compiled as a DEBUG development executable. Pure Domain diagnosis, not iOS UI, human playtest or Dot verdict.","content_file":source.lastPathComponent,"content_version":content.version,"exposure_before_warning":GameRules.exposureBeforeWarning,"observations":rows]
        try JSONSerialization.data(withJSONObject:report,options:[.prettyPrinted,.sortedKeys]).write(to:URL(fileURLWithPath:CommandLine.arguments[2]),options:.atomic)
    }
}
