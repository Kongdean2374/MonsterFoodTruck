import Foundation

enum GameRules {
    static let toppingTime: Double = 2
    static let tidyTime: Double = 3
    static let heatWindow: Double = 9
    static let exposureBeforeWarning: Double = 3
    static let theftCooldown: Double = 8
    static let arrivalNotice: Double = 4
    static let scorchNotice: Double = 2
}

enum RecipeID: String, Codable, CaseIterable, Hashable { case starSoup = "star_soup", moonCrisp = "moon_crisp", cloudStew = "cloud_stew" }
enum MonsterID: String, Codable, CaseIterable, Hashable { case emberDragon = "ember_dragon", nibbleImp = "nibble_imp", mossDeer = "moss_deer" }
enum Topping: String, Codable, CaseIterable, Hashable { case herb = "香草芽", star = "星脆片" }
enum PlayMode: String, Codable, CaseIterable, Hashable { case normal = "一般", gentle = "舒緩"
    var multiplier: Double { self == .gentle ? 1.5 : 1 }
    var nibbleWarning: Double { self == .gentle ? 5 : 3 }
}
struct Recipe: Codable, Identifiable {
    var id: RecipeID; var name: String; var prep: Double; var cook: Double; var grace: Double; var atlasColumn: Int
}
struct Monster: Codable, Identifiable {
    var id: MonsterID; var name: String; var patience: Double; var preference: String; var atlasColumn: Int
}
struct PlannedOrder: Codable, Identifiable {
    var id: String; var scheduledAt: Double; var monster: MonsterID; var recipe: RecipeID
}
struct Level: Codable, Identifiable {
    var id: String; var name: String; var focus: String; var orders: [PlannedOrder]
    var passCount: Int { Int(ceil(Double(orders.count) * 0.75)) }
    var preferenceCount: Int { Int(ceil(Double(orders.count) * 0.70)) }
}
enum GameError: LocalizedError {
    case invalid(String)
    var errorDescription: String? { if case let .invalid(message) = self { return message }; return nil }
}
struct GameContent: Codable {
    var version: Int; var recipes: [Recipe]; var monsters: [Monster]; var levels: [Level]
    static func load(bundle: Bundle = .main) throws -> GameContent {
        guard let url = bundle.url(forResource: "Content", withExtension: "json") else { throw GameError.invalid("找不到離線關卡資料。") }
        let content = try JSONDecoder().decode(GameContent.self, from: Data(contentsOf: url))
        try content.validate()
        return content
    }
    func recipe(_ id: RecipeID) -> Recipe { recipes.first { $0.id == id } ?? Recipe(id: id, name: "資料錯誤", prep: 3, cook: 10, grace: 6, atlasColumn: 0) }
    func monster(_ id: MonsterID) -> Monster { monsters.first { $0.id == id } ?? Monster(id: id, name: "資料錯誤", patience: 44, preference: "", atlasColumn: 0) }
    func validate() throws {
        guard version == 2, recipes.count == 3, monsters.count == 3, levels.count == 6,
              Set(recipes.map(\.id)).count == 3, Set(monsters.map(\.id)).count == 3,
              Set(levels.map(\.id)).count == 6 else { throw GameError.invalid("遊戲資料版本或數量不正確。") }
        for r in recipes where !r.prep.isFinite || !r.cook.isFinite || !r.grace.isFinite || r.prep <= 0 || r.cook <= 0 || r.grace <= 0 { throw GameError.invalid("食譜時間不正確：\(r.id.rawValue)") }
        for m in monsters where !m.patience.isFinite || m.patience <= 0 { throw GameError.invalid("魔物耐心資料不正確。") }
        guard Set(recipes.map(\.atlasColumn))==Set(0..<3),Set(monsters.map(\.atlasColumn))==Set(0..<3) else{throw GameError.invalid("料理或魔物素材映射不正確。")}
        for l in levels {
            guard !l.orders.isEmpty, Set(l.orders.map(\.id)).count == l.orders.count,
                  l.orders.allSatisfy({ $0.scheduledAt.isFinite && $0.scheduledAt >= 0 }),
                  l.orders.map(\.scheduledAt) == l.orders.map(\.scheduledAt).sorted(), l.orders[0].scheduledAt == 0 else { throw GameError.invalid("關卡訂單資料不正確：\(l.id)") }
        }
    }
}
