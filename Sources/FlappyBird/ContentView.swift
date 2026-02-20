import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: getScene(size: geometry.size))
                .ignoresSafeArea()
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    func getScene(size: CGSize) -> SKScene {
        let scene = GameScene(size: size)
        scene.scaleMode = .fill
        return scene
    }
}
