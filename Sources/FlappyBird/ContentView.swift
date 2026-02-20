import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 0 && geometry.size.height > 0 {
                SpriteView(scene: getScene(size: geometry.size))
                    .ignoresSafeArea()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .ignoresSafeArea()
    }
    
    func getScene(size: CGSize) -> SKScene {
        let scene = GameScene(size: size)
        scene.scaleMode = .fill
        return scene
    }
}
