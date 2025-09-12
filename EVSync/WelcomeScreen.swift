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
    @State private var backgroundOpacity: Double = 1.0
    
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
            .opacity(backgroundOpacity)
            
            VStack {
                Spacer()
                
                // Logo Section - по центру экрана
                Image("LOGOFRONT")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .shadow(color: .primary.opacity(0.2), radius: 10, x: 0, y: 5)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                Spacer()
                
                // Loading Indicator - внизу экрана
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .scaleEffect(1.2)
                    
                    Text(languageManager.localizedString("loading"))
                        .font(.custom("Nunito Sans", size: 16))
                        .foregroundColor(.secondary)
                    
                    Text(languageManager.localizedString("welcome_tagline"))
                        .font(.custom("Nunito Sans", size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)
                        .padding(.horizontal, 40)
                }
                .opacity(progressOpacity)
                .padding(.bottom, 60)
            }
        }
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo animation - более быстрая и плавная
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Text animation - раньше появляется
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            textOpacity = 1.0
        }
        
        // Progress indicator animation - раньше появляется
        withAnimation(.easeIn(duration: 0.4).delay(0.5)) {
            progressOpacity = 1.0
        }
    }
    
    // Функция для плавного исчезновения
    func fadeOut() {
        withAnimation(.easeOut(duration: 0.4)) {
            logoOpacity = 0.0
            textOpacity = 0.0
            progressOpacity = 0.0
        }
        
        withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
            backgroundOpacity = 0.0
        }
    }
}

#Preview {
    WelcomeScreen()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
}
