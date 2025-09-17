
import SwiftUI

@main
struct EVSyncApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var fontManager = FontManager.shared
    @StateObject private var stationsPreloader = StationsPreloader.shared

    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .environmentObject(languageManager)
                .environmentObject(fontManager)
                .environmentObject(stationsPreloader)
                .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
                .onAppear {
                    stationsPreloader.preloadStations()
                }
                .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
                    if isAuthenticated {
                        stationsPreloader.forceRefresh()
                    }
                }
        }
    }
}
