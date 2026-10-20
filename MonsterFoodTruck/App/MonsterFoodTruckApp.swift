import SwiftUI

@main
struct MonsterFoodTruckApp: App {
    @StateObject private var model=AppModel()
    var body:some Scene {WindowGroup {GameRoot().environmentObject(model)}}
}
