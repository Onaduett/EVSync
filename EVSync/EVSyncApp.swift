
import SwiftUI

@main
struct EVSyncApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
    }
}
