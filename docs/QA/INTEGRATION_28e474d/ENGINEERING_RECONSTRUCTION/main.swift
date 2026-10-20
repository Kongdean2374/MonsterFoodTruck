import Foundation
let content=try JSONDecoder().decode(GameContent.self,from:Data(contentsOf:URL(fileURLWithPath:"MonsterFoodTruck/Resources/Content.json")))
try content.validate()
var session=GameSession(level:content.levels[4],mode:.normal,content:content);session.isPaused=false
// Engineering reconstruction from native synthesized-event timestamps, relative
// to beginLevel. This advances a model; it is NOT actual UI execution evidence.
let inputs:[(Double,GameCommand)]=[(2.894,.prepare("L5-1")),(9.094,.cook("L5-1")),(12.605,.prepare("L5-2")),(17.378,.cook("L5-2")),(29.048,.plate("L5-2")),(30.391,.cover("L5-2")),(32.916,.uncover("L5-2")),(35.086,.cover("L5-2")),(37.098,.serve("L5-2")),(38.989,.plate("L5-1")),(39.842,.cover("L5-1")),(41.772,.uncover("L5-1")),(44.102,.tidy("L5-1")),(49.572,.garnish("L5-1",.herb))]
for (time,command) in inputs{session.advance(to:time,content:content);if let error=session.send(command,content:content){throw GameError.invalid("Reconstruction command rejected at \(time): \(error)")}}
session.advance(to:52,content:content)
let before=session.orders[0]
let relevant=session.events.filter{["scorched","nibbleWarning","nibbled","tidyStart","tidyDone","toppingStart","toppingDone"].contains($0.kind)}
// Proposed bounded real-UI response: tidy the second, now nibbled damage, then
// reapply the required herb and serve; no clock or scoring rule is changed.
for (time,command) in [(52.1,GameCommand.tidy("L5-1")),(55.2,GameCommand.garnish("L5-1",.herb)),(57.3,GameCommand.serve("L5-1"))]{session.advance(to:time,content:content);if let error=session.send(command,content:content){throw GameError.invalid(error)}}
try session.validate(content:content)
let encoder=JSONEncoder();encoder.outputFormatting=[.prettyPrinted,.sortedKeys]
struct Report:Encodable{var method:String;var nativeSourceSHA:String;var beforeRecovery:OrderState;var relevantEvents:[GameEvent];var afterRecovery:OrderState;var served:Int}
let report=Report(method:"Engineering model reconstruction from approximate native event timestamps; not real UI success or source-SHA native retest.",nativeSourceSHA:"28e474db37fdc8c9be40a490cd9c51a1070bd888",beforeRecovery:before,relevantEvents:relevant,afterRecovery:session.orders[0],served:session.served)
print(String(decoding:try encoder.encode(report),as:UTF8.self))
