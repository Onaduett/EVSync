//
//  SeeYouAgain.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 24.09.25.
//


import SwiftUI

struct SeeYouAgainView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    let onComplete: () -> Void
    
    @State private var animateElements = false
    @State private var showText = false
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.primary.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateElements ? 1.0 : 0.8)
                        .opacity(animateElements ? 1.0 : 0.0)
                    
                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.primary)
                        .scaleEffect(animateElements ? 1.0 : 0.8)
                        .opacity(animateElements ? 1.0 : 0.0)
                }
                
                // Text Content
                VStack(spacing: 16) {
                    Text(languageManager.localizedString("see_you_again", comment: "See You Again"))
                        .customFont(.largeTitle, weight: .bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .opacity(showText ? 1.0 : 0.0)
                        .offset(y: showText ? 0 : 20)
                    
                    Text(languageManager.localizedString("account_deleted_message", comment: "Your account has been successfully deleted. Thank you for using EVSync!"))
                        .customFont(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showText ? 1.0 : 0.0)
                        .offset(y: showText ? 0 : 20)
                }
                
                Spacer()
                
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.primary.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(animateElements ? 1.2 : 0.8)
                            .opacity(animateElements ? 0.8 : 0.3)
                            .animation(
                                .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: animateElements
                            )
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Initial icon animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
            animateElements = true
        }
        
        // Text animation after icon
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                showText = true
            }
        }
        
        // Complete after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.6)) {
                onComplete()
            }
        }
    }
}

#Preview {
    SeeYouAgainView {
        print("Animation completed")
    }
    .environmentObject(LanguageManager())
    .environmentObject(ThemeManager())
}
