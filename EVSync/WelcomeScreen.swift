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
    @EnvironmentObject var fontManager: FontManager
    @Binding var shouldFadeOut: Bool
    
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var progressOpacity: Double = 0.0
    @State private var backgroundOpacity: Double = 1.0
    @State private var opacity: Double = 1.0  // управляемый fade-out
    
    var body: some View {
        ZStack {
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
                
                Image("LOGOFRONT")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .shadow(color: .primary.opacity(0.2), radius: 10, x: 0, y: 5)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                Spacer()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .scaleEffect(1.2)
                    
                    Text(languageManager.localizedString("loading"))
                        .font(fontManager.font(.callout))
                        .foregroundColor(.secondary)
                    
                    Text(languageManager.localizedString("welcome_tagline"))
                        .font(fontManager.font(.body, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)
                        .padding(.horizontal, 40)
                }
                .opacity(progressOpacity)
                .padding(.bottom, 60)
            }
        }
        .opacity(opacity)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .onAppear {
            startAnimations()
        }
        .onChange(of: shouldFadeOut) { _, new in
            if new { fadeOut() }
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            textOpacity = 1.0
        }
        
        withAnimation(.easeIn(duration: 0.4).delay(0.5)) {
            progressOpacity = 1.0
        }
    }
    
    private func fadeOut() {
        withAnimation(.easeInOut(duration: 0.45)) {
            opacity = 0
        }
    }
}

#Preview {
    WelcomeScreen(shouldFadeOut: .constant(false))
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
        .environmentObject(FontManager.shared)
}
