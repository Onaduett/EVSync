//
//  NoInternetView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 12.09.25.
//

import SwiftUI

struct NoInternetView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var fontManager: FontManager
    @State private var isRefreshing = false
    
    let onRefresh: () -> Void
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.red)
                    }
                    
                    VStack(spacing: 12) {
                        // Title
                        Text(languageManager.localizedString("no_internet_title"))
                            .font(fontManager.font(.title3, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        // Description
                        Text(languageManager.localizedString("no_internet_description"))
                            .font(fontManager.font(.callout))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 40)
                    }
                }
                
                Button(action: {
                    handleRefresh()
                }) {
                    HStack(spacing: 12) {
                        if isRefreshing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: continueButtonTextColor))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(continueButtonTextColor)
                        }
                        
                        Text(isRefreshing ?
                             languageManager.localizedString("checking_connection") :
                             languageManager.localizedString("try_again_button"))
                            .font(fontManager.font(.callout, weight: .medium))
                            .foregroundColor(continueButtonTextColor)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(continueButtonBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isRefreshing)
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Tips Section
                VStack(spacing: 16) {
                    Text(languageManager.localizedString("connection_tips_title"))
                        .font(fontManager.font(.footnote, weight: .medium))
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 8) {
                        ConnectionTipRow(
                            icon: "wifi",
                            text: languageManager.localizedString("check_wifi_tip")
                        )
                        
                        ConnectionTipRow(
                            icon: "antenna.radiowaves.left.and.right",
                            text: languageManager.localizedString("check_cellular_tip")
                        )
                        
                        ConnectionTipRow(
                            icon: "arrow.clockwise",
                            text: languageManager.localizedString("restart_device_tip")
                        )
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
    

    private var continueButtonBackgroundColor: Color {
        if !isRefreshing {
            return .primary
        } else {
            return Color.secondary.opacity(0.3)
        }
    }
    
    private var continueButtonTextColor: Color {
        if !isRefreshing {
            return Color(UIColor.systemBackground)
        } else {
            return .secondary
        }
    }
    
    private func handleRefresh() {
        isRefreshing = true
        
        // Add a small delay to show the loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isRefreshing = false
            onRefresh()
        }
    }
}

struct ConnectionTipRow: View {
    @EnvironmentObject var fontManager: FontManager
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 16)
            
            Text(text)
                .font(fontManager.font(.caption))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

#Preview {
    NoInternetView(onRefresh: {})
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
        .environmentObject(FontManager.shared)
}
