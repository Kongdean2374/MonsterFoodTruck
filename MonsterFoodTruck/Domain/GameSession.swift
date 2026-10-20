import Foundation

enum OrderStatus: String, Codable { case waiting, served, left }
enum FoodStage: String, Codable { case none, prepping, prepared, cooking, ready, plated, topping, tidying }
enum Station: String, Codable, Hashable { case prep, stove, plate }
enum GameCommand: Equatable, Codable {
    case prepare(String), cook(String), plate(String), garnish(String, Topping), cancelGarnish(String), tidy(String), cover(String), uncover(String), serve(String)
    var orderID: String {
        switch self {
        case let .prepare(id), let .cook(id), let .plate(id), let .garnish(id, _), let .cancelGarnish(id), let .tidy(id), let .cover(id), let .uncover(id), let .serve(id): return id
        }
    }
}
struct OrderState: Codable, Identifiable {
    var id: String; var monster: MonsterID; var recipe: RecipeID; var admittedAt: Double; var deadline: Double
    var status: OrderStatus = .waiting
    var stage: FoodStage = .none
    var station: Station?; var slot: Int?; var workEnds: Double?
    var cookedAt: Double?; var platedAt: Double?
    var topping: Topping?; var pendingTopping: Topping?
    var isCovered = false; var everScorched = false; var everNibbled = false
    var needsTidy = false; var preferred = false; var heatExpiredRecorded = false
    var exposure: Double = 0; var warningRemaining: Double?
    var isActive: Bool { status == .waiting }
}
struct GameEvent: Codable, Identifiable {
    var id: Int; var time: Double; var kind: String; var orderID: String?; var detail: String
}
struct ReplayInput: Codable { var time: Double; var command: GameCommand }

/// Pure game-time model. Rendering and wall clock are deliberately absent.
struct GameSession: Codable {
    var schemaVersion = 1
    var id = UUID().uuidString
    var contentVersion: Int; var levelID: String; var mode: PlayMode
    private(set) var time: Double = 0
    var isPaused = true
    var isPractice = false
    var tutorialStep = 0
    var pendingLesson: String?
    private(set) var cursor = 0
    private(set) var orders: [OrderState] = []
    private(set) var nextAdmissionAt: Double?
    private(set) var waitingForSlot = false
    private(set) var lastAdmissionAt: Double = -GameRules.arrivalNotice
    private(set) var nibbleActor: String?; private(set) var nibbleTarget: String?
    private(set) var cooldownUntil: Double = 0
    private(set) var events: [GameEvent] = []
    private(set) var inputs: [ReplayInput] = []
    private(set) var processedCommands: [String] = []
    var activeOrders: [OrderState] { orders.filter(\.isActive) }
    var served: Int { orders.filter { $0.status == .served }.count }
    var preferences: Int { orders.filter(\.preferred).count }
    var lost: Int { orders.filter { $0.status == .left }.count }
    var scorchCount: Int { orders.filter(\.everScorched).count }
    var nibbleCount: Int { orders.filter(\.everNibbled).count }
    func finished(content: GameContent) -> Bool { cursor == level(content).orders.count && activeOrders.isEmpty }
    func level(_ content: GameContent) -> Level { content.levels.first { $0.id == levelID } ?? content.levels[0] }
    func stars(content: GameContent) -> Int {
        let n = level(content).orders.count
        if served < Int(ceil(Double(n) * 0.75)) { return 0 }
        if served < n { return 1 }
        return preferences >= Int(ceil(Double(n) * 0.70)) ? 3 : 2
    }
    init(level: Level, mode: PlayMode, content: GameContent) {
        self.levelID = level.id; self.mode = mode; self.contentVersion = content.version
        admit(content)
    }
    private mutating func emit(_ kind: String, _ orderID: String? = nil, _ detail: String = "") {
        events.append(GameEvent(id: (events.last?.id ?? -1) + 1, time: time, kind: kind, orderID: orderID, detail: detail))
    }
    private mutating func admit(_ content: GameContent) {
        let plans = level(content).orders
        guard cursor < plans.count, activeOrders.count < 3 else { return }
        let plan = plans[cursor]
        orders.append(OrderState(id: plan.id, monster: plan.monster, recipe: plan.recipe, admittedAt: time, deadline: time + content.monster(plan.monster).patience * mode.multiplier))
        emit("arrival", plan.id); cursor += 1; lastAdmissionAt = time
        nextAdmissionAt = cursor < plans.count ? max(plans[cursor].scheduledAt, time + GameRules.arrivalNotice) : nil
    }
    private func freeSlot(_ station: Station) -> Int? {
        (0..<2).first { slot in !activeOrders.contains { $0.station == station && $0.slot == slot } }
    }
    private func eligibleActor(for order: OrderState) -> String? {
        activeOrders.first { $0.monster == .nibbleImp && $0.id != order.id }?.id
    }
    private func exposed(_ order: OrderState) -> Bool {
        order.isActive && order.station == .plate && !order.isCovered && order.stage != .tidying && !order.everNibbled && eligibleActor(for: order) != nil
    }
    private mutating func refreshNibble() {
        if let target = nibbleTarget, let oi = orders.firstIndex(where: { $0.id == target }),
           exposed(orders[oi]), let actor = nibbleActor, activeOrders.contains(where: { $0.id == actor && actor != target }) { return }
        nibbleActor = nil; nibbleTarget = nil
        guard time >= cooldownUntil else { return }
        let candidates = orders.filter { exposed($0) && $0.exposure >= GameRules.exposureBeforeWarning - 0.000001 }.sorted {
            if $0.platedAt == $1.platedAt { return $0.id < $1.id }
            return ($0.platedAt ?? 0) < ($1.platedAt ?? 0)
        }
        if let target = candidates.first, let i = orders.firstIndex(where: { $0.id == target.id }) {
            nibbleTarget = target.id; nibbleActor = eligibleActor(for: target)
            if orders[i].warningRemaining == nil { orders[i].warningRemaining = mode.nibbleWarning; emit("nibbleWarning", target.id) }
        }
    }
    /// Advance chronologically without shortening long frames. Deadline equality remains serviceable.
    mutating func advance(to target: Double, content: GameContent) {
        guard !isPaused, target.isFinite, target >= time else { return }
        var iterations = 0
        while time < target - 0.0000001 && iterations < 10000 {
            iterations += 1
            refreshNibble()
            var next = target
            if let t = nextAdmissionAt { next = min(next, max(time, t)) }
            for o in activeOrders {
                if let t = o.workEnds { next = min(next, max(time, t)) }
                // Strict expiry gives an input received exactly at deadline priority.
                next = min(next, max(time, o.deadline + 0.00001))
                if o.station == .stove, let cooked = o.cookedAt, !o.everScorched { next = min(next, max(time, cooked + content.recipe(o.recipe).grace * mode.multiplier + 0.00001)) }
                if o.monster == .emberDragon, let cooked = o.cookedAt, !o.heatExpiredRecorded { next = min(next, max(time, cooked + GameRules.heatWindow * mode.multiplier + 0.00001)) }
                if exposed(o), o.exposure < GameRules.exposureBeforeWarning, time >= cooldownUntil { next = min(next, time + GameRules.exposureBeforeWarning - o.exposure) }
            }
            if time < cooldownUntil { next = min(next, cooldownUntil) }
            if let id = nibbleTarget, let o = orders.first(where: { $0.id == id }), let remaining = o.warningRemaining { next = min(next, time + max(0, remaining)) }
            let delta = max(0, next - time)
            for i in orders.indices where exposed(orders[i]) && time >= cooldownUntil {
                orders[i].exposure = min(GameRules.exposureBeforeWarning, orders[i].exposure + delta)
                if orders[i].id == nibbleTarget, let remaining = orders[i].warningRemaining { orders[i].warningRemaining = max(0, remaining - delta) }
            }
            time = next
            let before = events.count
            settle(content)
            if delta == 0 && events.count == before {
                // Only floating-point equality can reach here; preserve elapsed game time.
                let bump = min(target, time + 0.00001)
                if bump <= time { break }; time = bump
            }
        }
    }
    private mutating func settle(_ content: GameContent) {
        for i in orders.indices where orders[i].isActive {
            if let end = orders[i].workEnds, end <= time + 0.000001 {
                orders[i].workEnds = nil
                switch orders[i].stage {
                case .prepping: orders[i].stage = .prepared; emit("prepDone", orders[i].id)
                case .cooking: orders[i].stage = .ready; orders[i].cookedAt = end; emit("cookDone", orders[i].id)
                case .topping: orders[i].stage = .plated; orders[i].topping = orders[i].pendingTopping; orders[i].pendingTopping = nil; emit("toppingDone", orders[i].id)
                case .tidying: orders[i].stage = .plated; orders[i].needsTidy = false; emit("tidyDone", orders[i].id)
                default: break
                }
            }
            if orders[i].station == .stove, let cooked = orders[i].cookedAt, !orders[i].everScorched,
               time > cooked + content.recipe(orders[i].recipe).grace * mode.multiplier {
                orders[i].everScorched = true; orders[i].needsTidy = true; emit("scorched", orders[i].id)
            }
            if orders[i].monster == .emberDragon, let cooked = orders[i].cookedAt, !orders[i].heatExpiredRecorded, time > cooked + GameRules.heatWindow * mode.multiplier {
                orders[i].heatExpiredRecorded = true; emit("heatExpired", orders[i].id)
            }
        }
        refreshNibble()
        if let target = nibbleTarget, let i = orders.firstIndex(where: { $0.id == target }), (orders[i].warningRemaining ?? 1) <= 0.000001 {
            orders[i].everNibbled = true; orders[i].needsTidy = true
            if orders[i].stage == .topping { orders[i].stage = .plated; orders[i].workEnds = nil; orders[i].pendingTopping = nil }
            emit("nibbled", target); nibbleTarget = nil; nibbleActor = nil; cooldownUntil = time + GameRules.theftCooldown
        }
        for i in orders.indices where orders[i].isActive && time > orders[i].deadline {
            orders[i].status = .left; clearFood(i); emit("left", orders[i].id)
        }
        refreshNibble()
        if waitingForSlot && activeOrders.count < 3 {
            waitingForSlot = false; nextAdmissionAt = max(time + GameRules.arrivalNotice, lastAdmissionAt + GameRules.arrivalNotice)
            emit("arrivalNotice", nil)
        }
        if let admission = nextAdmissionAt, time >= admission - 0.000001 {
            if activeOrders.count < 3 { admit(content) }
            else { nextAdmissionAt = nil; waitingForSlot = true; emit("queueFull") }
        }
    }
    private mutating func clearFood(_ i: Int) {
        orders[i].station = nil; orders[i].slot = nil; orders[i].workEnds = nil
        orders[i].pendingTopping = nil; orders[i].isCovered = false
        if nibbleTarget == orders[i].id || nibbleActor == orders[i].id { nibbleTarget = nil; nibbleActor = nil }
    }
    @discardableResult mutating func send(_ command: GameCommand, token: String = UUID().uuidString, content: GameContent) -> String? {
        guard !isPaused else { return "請先繼續營業。" }
        guard !processedCommands.contains(token) else { return "這個操作已處理。" }
        processedCommands.append(token)
        guard let i = orders.firstIndex(where: { $0.id == command.orderID && $0.isActive }) else { return "這筆訂單已不在場。" }
        let o = orders[i]; let recipe = content.recipe(o.recipe)
        var failure: String?
        switch command {
        case .prepare:
            if o.stage != .none { failure = "這份料理已開始製作。" }
            else if let slot = freeSlot(.prep) { orders[i].station = .prep; orders[i].slot = slot; orders[i].stage = .prepping; orders[i].workEnds = time + recipe.prep; emit("prepStart",o.id) }
            else { failure = "兩個備料槽都滿了。" }
        case .cook:
            if o.stage != .prepared { failure = "食材還沒備妥。" }
            else if let slot = freeSlot(.stove) { orders[i].station = .stove; orders[i].slot = slot; orders[i].stage = .cooking; orders[i].workEnds = time + recipe.cook; emit("cookStart",o.id) }
            else { failure = "兩個爐位都滿了，食材會留在原槽。" }
        case .plate:
            if o.stage != .ready { failure = "料理還不能起鍋。" }
            else if let slot = freeSlot(.plate) { orders[i].station = .plate; orders[i].slot = slot; orders[i].stage = .plated; orders[i].platedAt = time; emit("plated",o.id) }
            else { failure = "兩個成品位置都滿了，請先出餐。" }
        case let .garnish(_, topping):
            if o.stage != .plated || o.isCovered || o.needsTidy { failure = "請先取下餐蓋並整理料理。" }
            else { orders[i].stage = .topping; orders[i].topping = nil; orders[i].pendingTopping = topping; orders[i].workEnds = time + GameRules.toppingTime; emit("toppingStart",o.id,topping.rawValue) }
        case .cancelGarnish:
            if o.stage != .topping { failure = "目前沒有配料工序。" }
            else { orders[i].stage = .plated; orders[i].workEnds = nil; orders[i].pendingTopping = nil; orders[i].topping = nil; emit("toppingCancel",o.id) }
        case .tidy:
            if o.stage != .plated || !o.needsTidy || o.isCovered { failure = "請選擇未蓋住且需要整理的成品。" }
            else { orders[i].stage = .tidying; orders[i].workEnds = time + GameRules.tidyTime; emit("tidyStart",o.id) }
        case .cover:
            if o.stage != .plated || o.isCovered { failure = "配料或整理時不能蓋上。" }
            else if activeOrders.contains(where: \.isCovered) { failure = "唯一的餐蓋正在另一盤上。" }
            else { orders[i].isCovered = true; emit("covered",o.id) }
        case .uncover:
            if !o.isCovered { failure = "這盤沒有餐蓋。" }
            else { orders[i].isCovered = false; emit("uncovered",o.id) }
        case .serve:
            if o.stage != .plated || o.needsTidy { failure = o.needsTidy ? "這份料理需要先整理三秒。" : "請先完成工序再出餐。" }
            else {
                orders[i].status = .served
                let clean = !o.everScorched && !o.everNibbled
                switch o.monster {
                case .emberDragon: orders[i].preferred = clean && time <= (o.cookedAt ?? -100) + GameRules.heatWindow * mode.multiplier
                case .mossDeer: orders[i].preferred = clean && o.topping == .herb
                case .nibbleImp: orders[i].preferred = clean && o.topping == .star
                }
                clearFood(i); emit(orders[i].preferred ? "preferred" : "served",o.id)
            }
        }
        if let failure { emit("rejected",o.id,failure); return failure }
        inputs.append(ReplayInput(time: time, command: command))
        settle(content)
        return nil
    }
    func validate(content: GameContent) throws {
        guard schemaVersion == 1, contentVersion == content.version, content.levels.contains(where: { $0.id == levelID }),
              time.isFinite, time >= 0, cursor >= 1, cursor <= level(content).orders.count,
              orders.count == cursor, (0...7).contains(tutorialStep),
              activeOrders.count <= 3, Set(orders.map(\.id)).count == orders.count,
              activeOrders.filter(\.isCovered).count <= 1 else { throw GameError.invalid("進行中的存檔版本或資源不正確。") }
        let plans = level(content).orders
        guard orders.map(\.id) == Array(plans.prefix(cursor)).map(\.id),
              nextAdmissionAt.map({$0.isFinite && $0 >= time-0.0001}) ?? true,
              cooldownUntil.isFinite, cooldownUntil >= 0 else {throw GameError.invalid("入場佇列或時鐘快照不正確。")}
        for o in orders {
            guard plans.contains(where: { $0.id == o.id && $0.recipe == o.recipe && $0.monster == o.monster }),
                  o.deadline.isFinite, o.deadline >= o.admittedAt, o.admittedAt >= 0, o.admittedAt <= time,
                  abs((o.deadline-o.admittedAt)-content.monster(o.monster).patience*mode.multiplier)<0.001,
                  o.exposure.isFinite, (0...(GameRules.exposureBeforeWarning+0.000001)).contains(o.exposure),
                  o.workEnds.map({ $0.isFinite && $0 >= time - 0.0001 }) ?? true,
                  o.warningRemaining.map({ $0.isFinite && $0 >= 0 && $0 <= mode.nibbleWarning }) ?? true else { throw GameError.invalid("訂單快照不正確。") }
            if let station = o.station {
                guard o.isActive, let slot = o.slot, (0..<2).contains(slot), activeOrders.filter({ $0.station == station && $0.slot == slot }).count == 1 else { throw GameError.invalid("工作站占用衝突。") }
            }
            if o.station == nil && o.slot != nil {throw GameError.invalid("工作站索引沒有對應位置。")}
            if o.isActive {
                let expected:Station?
                switch o.stage {case .none:expected=nil;case .prepping,.prepared:expected = .prep;case .cooking,.ready:expected = .stove;case .plated,.topping,.tidying:expected = .plate}
                guard o.station == expected else {throw GameError.invalid("料理工序與工作站不一致。")}
                let timed=[FoodStage.prepping,.cooking,.topping,.tidying].contains(o.stage)
                guard timed == (o.workEnds != nil) else {throw GameError.invalid("工序計時器不一致。")}
            }
            if o.isCovered && o.station != .plate { throw GameError.invalid("餐蓋歸屬錯誤。") }
        }
        if let actor=nibbleActor,let target=nibbleTarget {
            guard let meal=activeOrders.first(where:{$0.id==target}),exposed(meal),activeOrders.contains(where:{$0.id==actor && $0.monster == .nibbleImp && $0.id != target}) else{throw GameError.invalid("偷嚐的執行者或目標已失效。")}
        }else if nibbleActor != nil || nibbleTarget != nil{throw GameError.invalid("偷嚐預告快照不完整。")}
    }
    var hints: [String] {
        var result: [String] = []
        if events.contains(where: { $0.kind == "rejected" && $0.detail.contains("成品位置") }) { result.append("成品位置曾經滿了；先送出一盤，就能騰出裝盤空間。") }
        if events.contains(where: { $0.kind == "heatExpired" }) { result.append("有焰尾龍餐點失去熱度；熱度從烹調完成開始，可優先出餐。") }
        if result.count < 2 && nibbleCount > 0 { result.append("成品曾被偷嚐；可蓋住目標餐點，或先服務伸手的小鬼。") }
        if result.count < 2 && scorchCount > 0 { result.append("料理曾出現焦邊；留意爐上的完成提示與安全寬限。") }
        return Array(result.prefix(2))
    }
}
