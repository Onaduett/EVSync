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
    @StateObject private var fontManager = FontManager.shared
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @State private var showNoInternet = false
    @State private var isCheckingAuth = true
    @State private var initialConnectionCheck = false
    @State private var contentMounted = false
    @State private var showWelcomeOverlay = true
    @State private var contentReady = false
    @State private var shouldFadeOutWelcome = false
    @State private var authChecked = false
    @State private var minTimePassed = false
    
    var body: some View {
        ZStack {
            if contentMounted {
                Group {
                    if authManager.isAuthenticated {
                        NavigationBar()
                            .opacity(contentReady ? 1 : 0)
                    } else {
                        WelcomeView()
                            .opacity(contentReady ? 1 : 0)
                    }
                }
                .transition(.opacity)
            }
            
            if showNoInternet {
                NoInternetView(onRefresh: handleRefresh)
                    .transition(.opacity.animation(.easeInOut(duration: 0.6)))
                    .zIndex(5)
            } else if authManager.showSeeYouAgain {
                SeeYouAgainView {
                    authManager.completeSeeYouAgain()
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.6)))
                .zIndex(5)
            }

            if showWelcomeOverlay {
                WelcomeScreen(shouldFadeOut: $shouldFadeOutWelcome)
                    .zIndex(10)
                    .transition(.opacity)
                    .allowsHitTesting(true)
            }
        }
        .background(Color.black.opacity(0.001))
        .environmentObject(authManager)
        .environmentObject(themeManager)
        .environmentObject(languageManager)
        .environmentObject(fontManager)
        .environmentObject(networkMonitor)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .onAppear { startInitialization() }
        .onChange(of: networkMonitor.isConnected) { _, isConnected in
            if initialConnectionCheck && !isConnected && !showWelcomeOverlay {
                handleNoInternetState()
            }
        }
    }
    
    private func startInitialization() {
        Task {
            async let connOk = networkMonitor.checkConnection()
            async let authTask: Void = authManager.checkAuthStatusAsync()

            async let minSplash: Void = { try? await Task.sleep(nanoseconds: 2_000_000_000) }()

            let hasConnection = await connOk
            _ = await authTask
            await MainActor.run { authChecked = true }
            _ = await minSplash
            await MainActor.run { minTimePassed = true }

            await MainActor.run {
                withAnimation(.none) {
                    contentMounted = true
                }
            }

            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s - let map start rendering
            await MainActor.run {
                shouldFadeOutWelcome = true
                initialConnectionCheck = true
            }

            try? await Task.sleep(nanoseconds: 180_000_000) // 0.18s
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.35)) {
                    contentReady = true
                }
            }

            try? await Task.sleep(nanoseconds: 320_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showWelcomeOverlay = false
                    isCheckingAuth = false
                }
            }

            if !hasConnection {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showNoInternet = true
                    }
                }
            }
        }
    }
    
    private func handleRefresh() {
        Task {
            let hasConnection = await networkMonitor.checkConnection()
            
            await MainActor.run {
                if hasConnection {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showNoInternet = false
                    }
                    
                    Task {
                        await proceedWithAuth()
                    }
                }
            }
        }
    }
    
    private func proceedWithAuth() async {
        await authManager.checkAuthStatusAsync()
        
        try? await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000))
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                contentReady = true
                isCheckingAuth = false
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
