//
//  WelcomeScreen.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 11.09.25.
//


import SwiftUI

struct WelcomeScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var progressOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Dynamic background with gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.primary.opacity(0.05),
                    Color.primary.opacity(0.02),
                    Color.primary.opacity(0.08)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo Section
                VStack(spacing: 20) {
                    // App Logo/Icon
                    ZStack {
                        // Background circle with gradient
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.8),
                                        Color.green.opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: .primary.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        // Charging icon
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    // App Name
                    Text("Charge&Go")
                        .font(.custom("Lexend-SemiBold", size: 42))
                        .foregroundColor(.primary)
                        .opacity(textOpacity)
                    
                    // Tagline
                    Text(languageManager.localizedString("welcome_tagline"))
                        .font(.custom("Nunito Sans", size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Loading Indicator
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .scaleEffect(1.2)
                    
                    Text(languageManager.localizedString("loading"))
                        .font(.custom("Nunito Sans", size: 16))
                        .foregroundColor(.secondary)
                }
                .opacity(progressOpacity)
                
                Spacer()
            }
        }
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Text animation
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            textOpacity = 1.0
        }
        
        // Progress indicator animation
        withAnimation(.easeIn(duration: 0.5).delay(0.8)) {
            progressOpacity = 1.0
        }
    }
}

#Preview {
    WelcomeScreen()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
}
