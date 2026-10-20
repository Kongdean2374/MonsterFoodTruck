import Foundation

let manager = FileManager.default
let root = manager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
try manager.createDirectory(at: root, withIntermediateDirectories: true)
defer { do { try manager.removeItem(at: root) } catch { fputs("Temporary fixture cleanup failed: \(error)\n", stderr) } }
let expected = "cc.chaihome.monsterfoodtruck"
let dictionary: [String: Any] = ["CFBundleIdentifier": expected, "CFBundleExecutable": "MonsterFoodTruck", "CFBundleName": "MonsterFoodTruck", "CFBundlePackageType": "APPL", "CFBundleInfoDictionaryVersion": "6.0", "CFBundleVersion": "1", "CFBundleShortVersionString": "1.0.0"]
let data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .binary, options: 0)
for legacy in [false, true] {
    let app = root.appendingPathComponent(legacy ? "Legacy.app" : "Standard.app")
    try manager.createDirectory(at: app, withIntermediateDirectories: true)
    try data.write(to: app.appendingPathComponent("Info.plist"))
    if legacy { try manager.createDirectory(at: app.appendingPathComponent("Resources"), withIntermediateDirectories: true) }
    let identifier = Bundle(url: app)?.bundleIdentifier
    print("Layout regression \(legacy ? "root Resources folder" : "standard flat iOS bundle"): \(identifier ?? "<nil>")")
    if !legacy && identifier != expected { throw NSError(domain: "MFTBundleLayout", code: 1, userInfo: [NSLocalizedDescriptionKey: "Flat bundle fixture must be readable."]) }
    if legacy && identifier == expected { throw NSError(domain: "MFTBundleLayout", code: 2, userInfo: [NSLocalizedDescriptionKey: "Legacy-layout hypothesis did not reproduce on this runner; investigate instead of claiming a fix."]) }
}
