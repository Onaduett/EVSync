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
    @State private var showWelcomeScreen = true
    @State private var isCheckingAuth = true
    @State private var contentReady = false
    
    var body: some View {
        ZStack {
            if showWelcomeScreen {
                WelcomeScreen()
                    .transition(.opacity.animation(.easeInOut(duration: 0.6)))
            } else {
                Group {
                    if authManager.isAuthenticated {
                        NavigationBar()
                            .opacity(contentReady ? 1.0 : 0.0)
                    } else {
                        WelcomeView()
                            .opacity(contentReady ? 1.0 : 0.0)
                    }
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.8)))
            }
        }
        .environmentObject(authManager)
        .environmentObject(themeManager)
        .environmentObject(languageManager)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .onAppear {
            startInitialization()
        }
    }
    
    private func startInitialization() {
        Task {
            // Minimum welcome screen duration
            let minimumDuration: TimeInterval = 2.0
            let startTime = Date()
            
            // Start auth check immediately
            await authManager.checkAuthStatusAsync()
            
            // Ensure minimum welcome screen time
            let elapsed = Date().timeIntervalSince(startTime)
            let remainingTime = max(0, minimumDuration - elapsed)
            
            if remainingTime > 0 {
                try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
            }
            
            // Hide welcome screen with smooth animation
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showWelcomeScreen = false
                }
            }
            
            // Small delay before showing content to ensure smooth transition
            try? await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000))
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    contentReady = true
                    isCheckingAuth = false
                }
            }
        }
    }
}
