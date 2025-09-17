//
//  EmptyFavoritesView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

// MARK: - Empty State View
struct EmptyFavoritesView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(iconColor)
            
            VStack(spacing: 8) {
                Text(languageManager.localizedString("no_favorite_stations"))
                    .customFont(.title2, weight: .semibold)
                    .foregroundColor(primaryTextColor)
                
                Text(languageManager.localizedString("no_favorite_stations_description"))
                    .customFont(.body)
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Button to navigate to map
            Button(action: {
                selectedTab = 0 // Assuming map view is at index 0
            }) {
                HStack {
                    Image(systemName: "map")
                    Text(languageManager.localizedString("explore_map"))
                        .customFont(.subheadline, weight: .semibold)
                }
                .foregroundColor(buttonTextColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(buttonBackgroundColor)
                        .glassEffect()
                )
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - Theme-based colors
    private var iconColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .black.opacity(0.6)
        case .dark:
            return .white.opacity(0.6)
        case .auto:
            return Color.primary.opacity(0.6)
        }
    }
    
    private var primaryTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .black
        case .dark:
            return .white
        case .auto:
            return Color.primary
        }
    }
    
    private var secondaryTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .black.opacity(0.7)
        case .dark:
            return .white.opacity(0.7)
        case .auto:
            return Color.secondary
        }
    }
    
    private var buttonTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .black
        case .dark:
            return .white
        case .auto:
            return Color.primary
        }
    }
    
    private var buttonBackgroundColor: Material {
        switch themeManager.currentTheme {
        case .light:
            return .regularMaterial
        case .dark:
            return .regularMaterial
        case .auto:
            return .regularMaterial
        }
    }
}
