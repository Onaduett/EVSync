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
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                NavigationBar()
                    // Убираем .id(themeManager.currentTheme) - это вызывает полную перерисовку
            } else {
                WelcomeView()
            }
        }
        .environmentObject(authManager)
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        // Анимация применится автоматически благодаря @Published в ThemeManager
    }
}

#Preview {
    MainContentView()
}
