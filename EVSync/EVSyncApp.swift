
import SwiftUI

@main
struct EVSyncApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var languageManager = LanguageManager()

    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .environmentObject(languageManager)
                .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
        }
    }
}
