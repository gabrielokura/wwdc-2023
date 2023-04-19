import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject var gameManager = GameManager()
    
    var body: some View {
        ZStack {
            switch gameManager.selectedScene {
            case .ARGame:
                MyARView()
            case .menu:
                MenuView(gameManager: gameManager)
            case .spaceInvaders:
                SpaceInvadersView(gameManager: gameManager)
            case .menuAR:
                ARMenuView(gameManager: gameManager)
            case .end:
                EndScreenView()
            }
        }
    }
}
