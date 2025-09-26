//
//  FavoriteStationCard.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

// MARK: - Station Card View
struct FavoriteStationCard: View {
    let station: ChargingStation
    let favorite: UserFavorite
    let onRemove: (UUID) async -> Void
    let onTap: (ChargingStation) -> Void
    
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    @State private var isRemoving = false
    
    var body: some View {
        Button(action: {
            onTap(station)
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(station.name)
                            .customFont(.headline, weight: .semibold)
                            .foregroundColor(textColor)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text(station.address)
                            .customFont(.subheadline)
                            .foregroundColor(secondaryTextColor)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            isRemoving = true
                            await onRemove(favorite.id)
                            isRemoving = false
                        }
                    }) {
                        Image(systemName: isRemoving ? "heart.slash" : "heart.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(isRemoving ? secondaryTextColor : .red)
                            .scaleEffect(isRemoving ? 0.8 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isRemoving)
                    }
                    .disabled(isRemoving)
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(station.availability.color)
                        .frame(width: 8, height: 8)
                    
                    Text(station.availability.rawValue)
                        .customFont(.caption, weight: .medium)
                        .foregroundColor(station.availability.color)
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    DetailChip(icon: "bolt.fill", text: station.power, color: .green)
                    PriceChip(text: station.price, languageManager: languageManager)
                    Spacer()
                }
                
                if !station.connectorTypes.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(station.connectorTypes, id: \.self) { connector in
                                HStack(spacing: 4) {
                                    Image(systemName: connector.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.primary)
                                    
                                    Text(connector.rawValue)
                                        .customFont(.caption2, weight: .medium)
                                        .foregroundColor(textColor)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(chipBackgroundColor)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                // Provider and navigation indicator
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.house")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(tertiaryTextColor)
                        
                        Text(station.provider)
                            .customFont(.caption)
                            .foregroundColor(secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(tertiaryTextColor)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(FavoriteCardButtonStyle())
    }
    
    // MARK: - Theme-based colors
    private var textColor: Color {
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
            return .gray
        case .dark:
            return .white.opacity(0.8)
        case .auto:
            return Color.secondary
        }
    }
    
    private var tertiaryTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .gray.opacity(0.7)
        case .dark:
            return .white.opacity(0.6)
        case .auto:
            return Color.secondary.opacity(0.8)
        }
    }
    
    private var chipBackgroundColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return Color.black.opacity(0.06)
        case .dark:
            return Color.white.opacity(0.15)
        case .auto:
            return Color.primary.opacity(0.08)
        }
    }
    
    private var shadowColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return Color.black.opacity(0.15)
        case .dark:
            return Color.white.opacity(0.1)
        case .auto:
            return Color.primary.opacity(0.15)
        }
    }
}

// MARK: - Custom Button Style
struct FavoriteCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
