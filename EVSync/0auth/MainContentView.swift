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
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @State private var showWelcomeScreen = true
    @State private var showNoInternet = false
    @State private var isCheckingAuth = true
    @State private var contentReady = false
    @State private var initialConnectionCheck = false
    
    var body: some View {
        ZStack {
            if showWelcomeScreen {
                WelcomeScreen()
                    .transition(.opacity.animation(.easeInOut(duration: 0.6)))
            } else if showNoInternet {
                NoInternetView(onRefresh: handleRefresh)
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
        .environmentObject(networkMonitor)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .onAppear {
            startInitialization()
        }
        .onChange(of: networkMonitor.isConnected) { _, isConnected in
            if initialConnectionCheck && !isConnected && !showWelcomeScreen {
                handleNoInternetState()
            }
        }
    }
    
    private func startInitialization() {
        Task {
            // Minimum welcome screen duration
            let minimumDuration: TimeInterval = 2.0
            let startTime = Date()
            
            // Check initial connection status
            let hasConnection = await networkMonitor.checkConnection()
            
            // Ensure minimum welcome screen time
            let elapsed = Date().timeIntervalSince(startTime)
            let remainingTime = max(0, minimumDuration - elapsed)
            
            if remainingTime > 0 {
                try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
            }
            
            // Hide welcome screen
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showWelcomeScreen = false
                    initialConnectionCheck = true
                }
            }
            
            // Check if we should show no internet screen
            if !hasConnection {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showNoInternet = true
                    }
                }
                return
            }
            
            // If we have connection, proceed with auth check
            await proceedWithAuth()
        }
    }
    
    private func proceedWithAuth() async {
        // Start auth check
        await authManager.checkAuthStatusAsync()
        
        // Small delay before showing content to ensure smooth transition
        try? await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000))
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                contentReady = true
                isCheckingAuth = false
            }
        }
    }
    
    private func handleRefresh() {
        Task {
            let hasConnection = await networkMonitor.checkConnection()
            
            await MainActor.run {
                if hasConnection {
                    // Hide no internet screen and proceed with auth
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showNoInternet = false
                    }
                    
                    // Proceed with authentication
                    Task {
                        await proceedWithAuth()
                    }
                }
                // If still no connection, keep showing the no internet screen
            }
        }
    }
    
    private func handleNoInternetState() {
        withAnimation(.easeInOut(duration: 0.6)) {
            showNoInternet = true
            contentReady = false
        }
    }
}
