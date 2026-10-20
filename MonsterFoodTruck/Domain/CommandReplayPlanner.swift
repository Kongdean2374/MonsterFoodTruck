#if DEBUG
import Foundation

/// Diagnostic player uses only currently visible orders and the public command validator.
enum CommandReplayPlanner {
    static func run(level:Level,mode:PlayMode,content:GameContent) throws -> GameSession {
        var s=GameSession(level:level,mode:mode,content:content);s.isPaused=false
        for _ in 0..<600 {
            let visible=s.activeOrders.sorted { a,b in
                func priority(_ o:OrderState)->Double {
                    if o.stage == .plated { return o.monster == .emberDragon ? -100 : -50 }
                    if o.stage == .ready { return -30 }
                    if o.stage == .prepared { return -10 }
                    return o.deadline
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
            if let command { if let error=s.send(command,content:content) {throw GameError.invalid(error)} }
            try s.validate(content:content)
            if s.finished(content:content) {return s}
            s.advance(to:s.time+0.6,content:content)
        }
        throw GameError.invalid("Reference replay did not finish: \(level.id)")
    }
}

#endif
