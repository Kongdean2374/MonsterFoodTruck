import AVFoundation
import UIKit

@MainActor
final class GameAudio {
    private var music: AVAudioPlayer?
    private var sounds: [String: [AVAudioPlayer]] = [:]
    private var settings = GameSettings()
    private var lastPlayed: [String: Double] = [:]
    private(set) var loadWarnings: [String] = []
    #if DEBUG
    var diagnosticPlayerCount:Int{sounds.values.reduce(0){$0+$1.count}+(music == nil ? 0:1)}
    #endif
    init() {
        do { try AVAudioSession.sharedInstance().setCategory(.ambient,mode:.default,options:[.mixWithOthers]) }
        catch { loadWarnings.append("系統音訊初始化失敗：\(error.localizedDescription)") }
        if let url=Bundle.main.url(forResource:"forest_evening",withExtension:"wav") {
            do { music=try AVAudioPlayer(contentsOf:url);music?.numberOfLoops = -1;music?.prepareToPlay() }
            catch {loadWarnings.append("配樂無法載入：\(error.localizedDescription)")}
        } else {loadWarnings.append("缺少離線配樂。")}
        for name in ["select","prepStart","prepDone","cookStart","cookDone","scorched","plated","toppingStart","toppingDone","covered","uncovered","nibbleWarning","nibbled","tidyStart","tidyDone","served","preferred","left","arrival","win","lose","dragonReaction","impReaction","deerReaction"] {
            guard let url=Bundle.main.url(forResource:name,withExtension:"wav") else{loadWarnings.append("缺少音效：\(name)");continue}
            do {let players=try (0..<2).map{_ in try AVAudioPlayer(contentsOf:url)};players.forEach{$0.prepareToPlay()};sounds[name]=players}
            catch{loadWarnings.append("音效無法載入：\(name)：\(error.localizedDescription)")}
        }
    }
    func configure(_ settings: GameSettings) {self.settings=settings;music?.volume=Float(settings.music);for voices in sounds.values{for voice in voices{voice.volume=Float(settings.effects)}}}
    func startMusic() {if settings.music>0{music?.play()}}
    func preview() {startMusic();play("cookDone")}
    func pause() {music?.pause();for voices in sounds.values{for voice in voices{voice.stop()}}}
    func play(_ name: String) {
        guard settings.effects>0,let voices=sounds[name] else{return}
        let now=ProcessInfo.processInfo.systemUptime
        guard now-(lastPlayed[name] ?? -100)>0.08 else{return}
        lastPlayed[name]=now
        let playing=sounds.values.flatMap({$0}).filter(\.isPlaying)
        if playing.count>=6 {
            guard name=="nibbleWarning" || name=="cookDone" || name=="scorched" else{return}
            playing.first?.stop()
        }
        let voice=voices.first{!$0.isPlaying} ?? voices[0]
        voice.currentTime=0;voice.volume=Float(settings.effects);voice.play()
    }
}
