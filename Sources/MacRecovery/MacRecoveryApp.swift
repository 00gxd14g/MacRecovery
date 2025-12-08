import SwiftUI

@main
struct MacRecoveryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle()) // Optional: for a cleaner look
    }
}
