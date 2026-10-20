#if DEBUG
import Foundation

/// Diagnostic player uses only currently visible orders and the public command validator.
enum CommandReplayPlanner {
    enum Policy:String,CaseIterable {case dynamic,shortFirst,longFirst}
    struct Observation {
        var session:GameSession
        var idleSeconds:Double
        var longestIdleSpan:Double
        var selectionCount:Int
    }
    static func run(level:Level,mode:PlayMode,content:GameContent) throws -> GameSession {
        try observe(level:level,mode:mode,content:content).session
    }
    static func observe(level:Level,mode:PlayMode,content:GameContent,policy:Policy = .dynamic,interval:Double = 0.6,selectionDelay:Double = 0) throws -> Observation {
        guard interval>=0.6,selectionDelay>=0 else{throw GameError.invalid("Diagnostic input speed is invalid")}
        var s=GameSession(level:level,mode:mode,content:content);s.isPaused=false
        var selected:String?,selections=0,idle:Double=0,currentIdle:Double=0,longestIdle:Double=0
        for _ in 0..<600 {
            if s.finished(content:content){return Observation(session:s,idleSeconds:idle,longestIdleSpan:longestIdle,selectionCount:selections)}
            let visible=s.activeOrders.sorted { a,b in
                func priority(_ o:OrderState)->Double {
                    if o.stage == .plated { return o.monster == .emberDragon ? -100 : -50 }
                    if o.stage == .ready { return -30 }
                    let work=content.recipe(o.recipe).cook
                    let tie=policy == .shortFirst ? work:policy == .longFirst ? -work:o.deadline
                    if o.stage == .prepared { return -10 + (policy == .dynamic ? 0:tie/100) }
                    return policy == .dynamic ? o.deadline:100+tie
                }
                return priority(a)<priority(b)
            }
            var command:GameCommand?
            for o in visible {
                switch o.stage {
                case .none: if s.activeOrders.filter({$0.station == .prep}).count<2 {command = .prepare(o.id)}
                case .prepared: if s.activeOrders.filter({$0.station == .stove}).count<2 {command = .cook(o.id)}
                case .ready: if s.activeOrders.filter({$0.station == .plate}).count<2 {command = .plate(o.id)}
                case .plated:
                    if o.needsTidy {command = .tidy(o.id)}
                    else if o.monster == .mossDeer && o.topping != .herb {command = .garnish(o.id,.herb)}
                    else if o.monster == .nibbleImp && o.topping != .star {command = .garnish(o.id,.star)}
                    else {command = .serve(o.id)}
                default:break
                }
                if command != nil {break}
            }
            if let command {
                currentIdle=0
                if selected != command.orderID{
                    selected=command.orderID;selections+=1
                    if selectionDelay>0{
                        s.advance(to:s.time+selectionDelay,content:content)
                        try s.validate(content:content)
                        continue // Re-evaluate legal work after selection time, including arrivals or expiry.
                    }
                }
                if let error=s.send(command,content:content) {throw GameError.invalid(error)}
            }else{idle+=interval;currentIdle+=interval;longestIdle=max(longestIdle,currentIdle)}
            try s.validate(content:content)
            if s.finished(content:content) {return Observation(session:s,idleSeconds:idle,longestIdleSpan:longestIdle,selectionCount:selections)}
            s.advance(to:s.time+interval,content:content)
        }
        throw GameError.invalid("Reference replay did not finish: \(level.id)")
    }
}

#endif
