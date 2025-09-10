//
//  MainContentView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct MainContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var languageManager = LanguageManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                NavigationBar()
            } else {
                WelcomeView()
            }
        }
        .environmentObject(authManager)
        .environmentObject(themeManager)
        .environmentObject(languageManager)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
}

#Preview {
    MainContentView()
}
