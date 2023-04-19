import SwiftUI

@main
struct MyApp: App {
    
    init() {
        try! UIFont.registerFonts(withExtension: "ttf") // Para fontes com formato ttf
        try! UIFont.registerFonts(withExtension: "otf") // Para fontes com formato otf
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
