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
                            .font(.system(size: 20))
                            .foregroundColor(isRemoving ? .gray : .red)
                            .scaleEffect(isRemoving ? 0.8 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isRemoving)
                    }
                    .disabled(isRemoving)
                }
                
                HStack {
                    Circle()
                        .fill(station.availability.color)
                        .frame(width: 8, height: 8)
                    
                    Text(station.availability.rawValue)
                        .customFont(.caption, weight: .medium)
                        .foregroundColor(station.availability.color)
                    
                    Spacer()
                }
                
                HStack(spacing: 15) {
                    DetailChip(icon: "bolt.fill", text: station.power, color: .green)
                    PriceChip(text: station.price, languageManager: languageManager)
                }
                
                if !station.connectorTypes.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(station.connectorTypes, id: \.self) { connector in
                                HStack(spacing: 4) {
                                    Image(connector.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(.blue)
                                    Text(connector.rawValue)
                                        .customFont(.caption2, weight: .medium)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(chipBackgroundColor)
                                .foregroundColor(textColor)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                HStack {
                    Image(systemName: "building.2")
                        .font(.caption)
                        .foregroundColor(tertiaryTextColor)
                    
                    Text(station.provider)
                        .customFont(.caption)
                        .foregroundColor(secondaryTextColor)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(tertiaryTextColor)
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBackgroundColor)
                    .glassEffect()
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
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
            return .black.opacity(0.7)
        case .dark:
            return .white.opacity(0.8)
        case .auto:
            return Color.secondary
        }
    }
    
    private var tertiaryTextColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .black.opacity(0.5)
        case .dark:
            return .white.opacity(0.6)
        case .auto:
            return Color.secondary.opacity(0.8)
        }
    }
    
    private var cardBackgroundColor: Material {
        switch themeManager.currentTheme {
        case .light:
            return .regularMaterial
        case .dark:
            return .regularMaterial
        case .auto:
            return .regularMaterial
        }
    }
    
    private var chipBackgroundColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return Color.black.opacity(0.1)
        case .dark:
            return Color.white.opacity(0.2)
        case .auto:
            return Color.primary.opacity(0.1)
        }
    }
}
