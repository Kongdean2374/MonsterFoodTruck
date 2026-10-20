#if DEBUG
import Foundation

/// Screenshot fixtures are built through the real model commands. Never shipped
/// in Release, never used as proof of a normal playthrough or written to saves.
enum DebugScenarios {
    static func make(_ name:String,content:GameContent) throws -> GameSession {
        var s=GameSession(level:content.levels[5],mode:.normal,content:content)
        s.isPaused=false;s.isPractice=true
        func send(_ command:GameCommand) throws {if let error=s.send(command,content:content){throw GameError.invalid(error)}}
        try send(.prepare("L6-1"));s.advance(to:5,content:content);try send(.cook("L6-1"))
        s.advance(to:6,content:content);try send(.prepare("L6-2"))
        s.advance(to:10,content:content);try send(.cook("L6-2"))
        s.advance(to:12,content:content);try send(.prepare("L6-3"))
        if name=="scorched" {
            s.advance(to:25,content:content);try send(.plate("L6-2"));try send(.tidy("L6-2"))
            s.advance(to:26,content:content)
        }else{
            s.advance(to:18,content:content);try send(.plate("L6-2"));try send(.cook("L6-3"))
            s.advance(to:21,content:content);try send(.plate("L6-1"));try send(.garnish("L6-1",.herb))
            s.advance(to:name=="busy" ? 22:25,content:content)
            if name=="covered" {try send(.cover("L6-2"))}
            if name=="tidy" {s.advance(to:28,content:content);try send(.tidy("L6-2"));s.advance(to:29,content:content)}
        }
        try s.validate(content:content)
        return s
    }
}
#endif
