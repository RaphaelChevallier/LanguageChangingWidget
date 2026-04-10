import SwiftUI

@main
struct LangToggleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if url.host == "toggle" {
                        PreferencesManager.shared.toggle()
                    }
                }
        }
    }
}
