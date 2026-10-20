import SwiftUI
import Combine
import UIKit

enum Screen: Equatable { case home, levels, introduction(String), game, result, complete, help, about, ended }

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var content: GameContent?
    @Published private(set) var document = SaveDocument()
    @Published var screen: Screen = .home
    @Published var selectedOrder: String?
    @Published var message: String?
    @Published var lesson: String?
    @Published var settingsPresented = false
    @Published var startupError: String?
    @Published var confirmation: Confirmation?
    @Published var isSaving = false
    @Published private(set) var resultSession: GameSession?
    let kitchen = KitchenScene()
    let audio = GameAudio()
    private var store: SaveStore?
    private var lastUptime: Double?
    private var lastSnapshotTime: Double = 0
    private var lastEvent = -1
    private var tutorialPhase: Int {
        get {document.session?.tutorialStep ?? 0}
        set {document.session?.tutorialStep=newValue}
    }
    @Published private(set) var isSettling=false
    private var recoveryBlocked = false
    private var nextIsPractice = false
    enum Confirmation: Identifiable {
        case replace(String), restart, abandon, resetSettings, resetProgress
        var id: String { String(describing:self) }
    }
    init() { load() }
    func load() {
        do {
            let content = try GameContent.load()
            let store = SaveStore(directory:try SaveStore.applicationDirectory(),content:content)
            let loaded = store.load()
            self.content = content; self.store = store; document = loaded.document
            message = loaded.notice
            recoveryBlocked = loaded.notice?.contains("無法恢復") == true
            startupError = nil
            audio.configure(document.settings)
        } catch { startupError = error.localizedDescription }
    }
    var session: GameSession? { document.session }
    var selected: OrderState? { session?.activeOrders.first { $0.id == selectedOrder } }
    var allComplete: Bool { guard let content else { return false }; return content.levels.allSatisfy { (document.records[$0.id]?.best ?? 0) > 0 } }
    func startButton() {
        guard let content else { return }
        if document.session != nil { confirmation = .replace(nextLevelID()); return }
        if allComplete { screen = .levels }
        else { screen = .introduction(nextLevelID()) }
    }
    private func nextLevelID() -> String {
        guard let content else { return "level_01" }
        return content.levels.first { (document.records[$0.id]?.best ?? 0) == 0 }?.id ?? content.levels[0].id
    }
    func requestBegin(_ levelID: String) {
        if document.session != nil { confirmation = .replace(levelID) }
        else { begin(levelID) }
    }
    func begin(_ levelID: String) {
        guard let content, let index = content.levels.firstIndex(where: { $0.id == levelID }), document.unlocked(index,content:content) else { message = "請先通過前一關。"; return }
        recoveryBlocked = false
        lesson=nil
        document.session = GameSession(level:content.levels[index],mode:document.settings.nextMode,content:content)
        document.session?.isPractice = nextIsPractice
        nextIsPractice = false
        selectedOrder = document.session?.activeOrders.first?.id
        resultSession = nil; lastEvent = -1; lastSnapshotTime = 0; lastUptime = nil; tutorialPhase = 0
        screen = .game; persist()
        if levelID == "level_01" && (!document.tutorialDone || document.session?.isPractice == true) { tutorialPhase = 1; showLesson("歡迎開張！先點選苔角鹿的訂單，料理會一直綁定這位客人。") }
    }
    func continueSession() {
        guard document.session != nil else { return }
        document.session?.isPaused = true; lastUptime = nil
        lesson=document.session?.pendingLesson
        lastEvent=document.session?.events.last?.id ?? -1
        selectedOrder = document.session?.activeOrders.first?.id
        screen = .game
        syncKitchen()
    }
    func pause() {
        document.session?.isPaused = true; lastUptime = nil
        kitchen.isPaused = true; audio.pause(); persist()
    }
    func resume() {
        guard screen == .game, lesson == nil else { return }
        document.session?.isPaused = false
        lastUptime = ProcessInfo.processInfo.systemUptime
        kitchen.isPaused = document.settings.reduceMotion
        audio.startMusic(); syncKitchen()
    }
    func dismissLesson(skip: Bool = false) {
        if skip { if document.session?.isPractice != true {document.tutorialDone = true}; tutorialPhase = 0 }
        lesson = nil; document.session?.pendingLesson=nil; resume(); persist()
    }
    func select(_ id: String) {
        selectedOrder = id; audio.play("select")
        if tutorialPhase == 1 {
            tutorialPhase = 2
            showLesson("點「備料」就會自動準備，不需要連點。兩個備料槽都能使用。")
        }
        syncKitchen()
    }
    func tick() {
        guard screen == .game, var session = document.session, !session.isPaused, lesson == nil, let content else { return }
        let uptime = ProcessInfo.processInfo.systemUptime
        let delta = lastUptime.map { max(0,uptime-$0) } ?? 0
        lastUptime = uptime
        session.advance(to:session.time+delta,content:content)
        document.session = session
        consumeEvents()
        syncKitchen()
        if session.finished(content:content) { settleResult(session); return }
        if session.time-lastSnapshotTime >= 2 { lastSnapshotTime=session.time;persist() }
    }
    func command(_ command: GameCommand) {
        tick()
        guard var session=document.session, let content else { return }
        if let error=session.send(command,content:content) { message=error;return }
        document.session=session;consumeEvents();syncKitchen();persist()
        if session.finished(content:content) { settleResult(session) }
    }
    private func consumeEvents() {
        guard let session=document.session, let content else { return }
        for event in session.events where event.id > lastEvent {
            lastEvent=event.id;audio.play(event.kind)
            if (event.kind=="preferred" || event.kind=="served"),let order=session.orders.first(where:{$0.id==event.orderID}) {
                audio.play(order.monster == .emberDragon ? "dragonReaction":order.monster == .nibbleImp ? "impReaction":"deerReaction")
            }
            if event.kind == "preferred" && document.settings.haptics { UIImpactFeedbackGenerator(style:.light).impactOccurred() }
            if tutorialPhase == 2 && event.kind == "prepDone" {tutorialPhase=3;showLesson("食材備妥了。點備料槽或下方「下鍋」，會送往第一個空爐。")}
            else if tutorialPhase == 3 && event.kind == "cookDone" {tutorialPhase=4;showLesson("料理完成！點爐位或「裝盤」，移到空成品位置。留在爐上超過寬限會出現焦邊。")}
            else if tutorialPhase == 4 && event.kind == "plated" {tutorialPhase=5;showLesson("點「出餐」就會送到原來的客人。這次先完成流程，下一筆再試香草。")}
            else if tutorialPhase == 5 && (event.kind == "served" || event.kind == "preferred") {tutorialPhase=6}
            else if tutorialPhase == 6 && event.kind == "plated" {tutorialPhase=7;showLesson("苔角鹿喜歡香草芽。點香草芽，等兩秒配料完成，再出餐；也能取消配料先騰出位置。")}
            else if tutorialPhase == 7 && event.kind == "toppingDone" {tutorialPhase=0;if !session.isPractice{document.tutorialDone=true}}
            if event.kind == "arrival", let id=event.orderID, let order=session.orders.first(where:{$0.id==id}) {
                let key=order.monster == .emberDragon ? "hot" : order.monster == .nibbleImp ? "imp" : order.recipe == .cloudStew ? "stew" : order.recipe == .moonCrisp ? "crisp" : "basic"
                if key != "basic", !document.seenLessons.contains(key), lesson == nil {
                    document.seenLessons.append(key)
                    let text: String
                    switch key {
                    case "hot":text="焰尾龍喜歡熱食。熱度從烹調完成起算九秒，裝盤或蓋餐蓋都不會重置。舒緩模式會延長期限。"
                    case "imp":text="小鬼喜歡星脆片，也會偷嚐別人的未蓋成品。爪子預告會指向目標；可蓋住那盤、送餐，或先服務伸手的小鬼。餐蓋只有一個，取下後預告接續。"
                    case "stew":text="雲菇燉菜需要煮十六秒。可以先安排長菜，再用另一爐處理短菜。"
                    default:text="月角脆餅煮八秒，起鍋安全寬限五秒；先留意成品位置，再安排裝盤。"
                    }
                    showLesson(text)
                }
            }
        }
        if !session.activeOrders.contains(where:{$0.id==selectedOrder}) {selectedOrder=session.activeOrders.first?.id}
        audio.configure(document.settings)
        _ = content
    }
    private func showLesson(_ text: String) {lesson=text;document.session?.pendingLesson=text;document.session?.isPaused=true;lastUptime=nil;kitchen.isPaused=true;persist()}
    private func syncKitchen() {guard let session=document.session,let content else{return};kitchen.display(session:session,content:content,selected:selectedOrder,reduceMotion:document.settings.reduceMotion)}
    private func settleResult(_ session: GameSession) {
        guard screen == .game,!isSettling,let content,let store else{return}
        isSettling=true
        pause();resultSession=session
        document.revision += 1
        var settled=document
        if !session.isPractice {
            var record=settled.records[session.levelID] ?? LevelRecord()
            record.record(session.stars(content:content),mode:session.mode)
            settled.records[session.levelID]=record
        }
        settled.session=nil
        isSaving=true
        store.write(settled) { [weak self] result in
            guard let self else{return}
            self.isSettling=false;self.isSaving=false
            switch result {
            case .success:self.document=settled;self.screen = .result;self.audio.play(session.stars(content:content)>0 ? "win":"lose")
            case let .failure(error):self.message="結算尚未儲存：\(error.localizedDescription)。請在暫停畫面重試。"
            }
        }
    }
    func retrySettlement(){if let resultSession{settleResult(resultSession)}}
    func homeSaving() {pause();persist{[weak self] success in if success{self?.screen = .home}}}
    func endPlay() {pause();persist{[weak self] success in if success{self?.audio.pause();self?.screen = .ended}}}
    func openSettings() {if screen == .game{pause()};settingsPresented=true}
    func updateTutorialForReplay() {nextIsPractice=true}
    func updateSettings(_ edit: (inout GameSettings)->Void) {edit(&document.settings);audio.configure(document.settings);syncKitchen();persist()}
    func confirmed(_ confirmation: Confirmation) {
        switch confirmation {
        case let .replace(id):begin(id)
        case .restart:if let id=document.session?.levelID{begin(id)}
        case .abandon:document.session=nil;screen = .home;persist()
        case .resetSettings:document.settings=GameSettings();audio.configure(document.settings);persist()
        case .resetProgress:document.records=[:];document.session=nil;document.tutorialDone=false;document.seenLessons=[];screen = .home;settingsPresented=false;recoveryBlocked=false;persist()
        }
        self.confirmation=nil
    }
    func persist(completion: ((Bool)->Void)? = nil) {
        guard !isSettling else{completion?(false);return}
        guard let store else{message="存檔服務尚未可用。";completion?(false);return}
        guard !recoveryBlocked else{message="存檔無法恢復，尚未儲存新的進度。可重新開始，或保留原檔離開。";completion?(false);return}
        document.revision += 1;isSaving=true
        store.write(document){[weak self] result in
            guard let self else{return};self.isSaving=false
            switch result {case .success:completion?(true);case let .failure(error):self.message="儲存失敗：\(error.localizedDescription)";completion?(false)}
        }
    }
}
