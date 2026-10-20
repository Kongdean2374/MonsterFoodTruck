import SwiftUI
import SpriteKit

@main
struct MonsterFoodTruckApp: App {
    var body: some Scene {
        WindowGroup { LaunchView() }
    }
}

private struct LaunchView: View {
    @State private var scene: SKScene = {
        let scene = SKScene(size: CGSize(width: 390, height: 400))
        scene.backgroundColor = UIColor(red: 0.40, green: 0.48, blue: 0.32, alpha: 1)
        scene.scaleMode = .resizeFill
        return scene
    }()
    var body: some View {
        VStack(spacing: 24) {
            Text("魔物餐車").font(.largeTitle.bold())
            SpriteView(scene: scene).frame(height: 240).accessibilityHidden(true)
            Text("黃昏森林的廚房").font(.title2)
        }
        .padding()
        .background(Color(red: 1, green: 0.95, blue: 0.84))
    }
}
