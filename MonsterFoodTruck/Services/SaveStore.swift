import Foundation

struct GameSettings: Codable, Equatable {
    var music: Double = 0.55
    var effects: Double = 0.75
    var haptics = true
    var nextMode: PlayMode = .normal
    var highContrast = false
    var largeText = false
    var reduceMotion = false
    var leftHanded = false
}
struct LevelRecord: Codable {
    var normal = 0; var gentle = 0
    var best: Int { max(normal, gentle) }
    mutating func record(_ stars: Int, mode: PlayMode) {
        if mode == .normal { normal = max(normal, stars) }
        else { gentle = max(gentle, stars) }
    }
}
struct SaveDocument: Codable {
    var version = 1
    var revision: UInt64 = 0
    var settings = GameSettings()
    var records: [String: LevelRecord] = [:]
    var tutorialDone = false
    var seenLessons: [String] = []
    var session: GameSession?
    var sessionReadIssue: String?
    enum CodingKeys:String,CodingKey {case version,revision,settings,records,tutorialDone,seenLessons,session}
    init(){}
    init(from decoder:Decoder) throws{
        let c=try decoder.container(keyedBy:CodingKeys.self)
        version=try c.decode(Int.self,forKey:.version);revision=try c.decode(UInt64.self,forKey:.revision)
        settings=try c.decode(GameSettings.self,forKey:.settings);records=try c.decode([String:LevelRecord].self,forKey:.records)
        tutorialDone=try c.decode(Bool.self,forKey:.tutorialDone);seenLessons=try c.decode([String].self,forKey:.seenLessons)
        do{session=try c.decodeIfPresent(GameSession.self,forKey:.session)}
        catch{session=nil;sessionReadIssue=error.localizedDescription}
    }
    var totalStars: Int { records.values.reduce(0) { $0 + $1.best } }
    func unlocked(_ index: Int, content: GameContent) -> Bool {
        index == 0 || (index > 0 && index < content.levels.count && (records[content.levels[index-1].id]?.best ?? 0) > 0)
    }
    func validate(content: GameContent, includeSession: Bool = true) throws {
        guard version == 1, settings.music.isFinite, settings.effects.isFinite,
              (0...1).contains(settings.music), (0...1).contains(settings.effects),
              records.allSatisfy({ key, record in content.levels.contains { $0.id == key } && (0...3).contains(record.normal) && (0...3).contains(record.gentle) }) else { throw GameError.invalid("永久進度或設定格式不正確。") }
        if includeSession {
            if sessionReadIssue != nil{throw GameError.invalid("進行中快照無法解碼。")}
            try session?.validate(content: content)
        }
    }
}
struct SaveLoadResult {
    var document: SaveDocument
    var notice: String?
}

/// One ordered writer; whole-document atomic replacement keeps settlement and
/// session clearing in the same transaction. No scene nodes are serialized.
final class SaveStore {
    private let queue = DispatchQueue(label: "cc.chaihome.monsterfoodtruck.save", qos: .utility)
    private let directory: URL
    private var newestRevision: UInt64 = 0
    private let content: GameContent
    init(directory: URL, content: GameContent) {
        self.directory = directory; self.content = content
    }
    static func applicationDirectory() throws -> URL {
        let base = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return base.appendingPathComponent("MonsterFoodTruck", isDirectory: true)
    }
    private var primary: URL { directory.appendingPathComponent("save-v1.json") }
    private var backup: URL { directory.appendingPathComponent("save-v1.backup.json") }
    func load() -> SaveLoadResult {
        queue.sync {
            var failures: [String] = []
            for (index,url) in [primary,backup].enumerated() where FileManager.default.fileExists(atPath:url.path) {
                do {
                    var document = try JSONDecoder().decode(SaveDocument.self, from:Data(contentsOf:url))
                    try document.validate(content:content,includeSession:false)
                    var sessionNotice: String?
                    do {
                        if document.sessionReadIssue != nil{throw GameError.invalid("進行中快照無法解碼。")}
                        try document.session?.validate(content:content)
                    }catch{
                        document.session=nil
                        sessionNotice="永久進度已保留，但進行中的局無法恢復或與資料不相容，需重新開局。"
                        if index==0 && FileManager.default.fileExists(atPath:backup.path){
                            do{
                                let previous=try JSONDecoder().decode(SaveDocument.self,from:Data(contentsOf:backup))
                                try previous.validate(content:content)
                                if let snapshot=previous.session{
                                    document.session=snapshot
                                    sessionNotice="永久進度與設定已保留，進行中的局已從最後有效備份恢復。"
                                }
                            }catch{ /* Keep readable permanent progress when no valid session backup exists. */ }
                        }
                        document.sessionReadIssue=nil
                    }
                    document.session?.isPaused = true
                    newestRevision = document.revision
                    return SaveLoadResult(document:document,notice:sessionNotice ?? (index == 1 ? "主要存檔無法讀取，已從最後有效備份恢復。" : nil))
                } catch { failures.append(error.localizedDescription) }
            }
            return SaveLoadResult(document:SaveDocument(),notice:failures.isEmpty ? nil : "存檔與備份無法恢復。原檔已保留；可重新開始，或先離開以保留資料。")
        }
    }
    func write(_ document: SaveDocument, completion: @escaping (Result<Void,Error>) -> Void) {
        queue.async { [self] in
            let result: Result<Void,Error>
            do {
                if document.revision < newestRevision { throw GameError.invalid("已拒絕舊版存檔覆蓋較新進度。") }
                try document.validate(content:content)
                let manager = FileManager.default
                try manager.createDirectory(at:directory,withIntermediateDirectories:true)
                if manager.fileExists(atPath:primary.path) {
                    var validPreviousData: Data?
                    do {
                        let oldData = try Data(contentsOf:primary)
                        let oldDocument = try JSONDecoder().decode(SaveDocument.self,from:oldData)
                        try oldDocument.validate(content:content)
                        validPreviousData = oldData
                    } catch {
                        // Preserve a healthy existing backup when primary is corrupt.
                        // Backup and primary I/O failures below still propagate.
                    }
                    if let validPreviousData { try validPreviousData.write(to:backup,options:.atomic) }
                }
                let data = try JSONEncoder().encode(document)
                try data.write(to:primary,options:.atomic)
                newestRevision = document.revision
                result = .success(())
            } catch { result = .failure(error) }
            DispatchQueue.main.async { completion(result) }
        }
    }
    func flushForTesting() { queue.sync {} }
}
