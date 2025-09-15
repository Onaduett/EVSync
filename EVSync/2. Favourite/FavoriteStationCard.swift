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
    @State private var isRemoving = false
    
    var body: some View {
        Button(action: {
            onTap(station)
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(station.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text(station.address)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
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
                
                // Station status
                HStack {
                    Circle()
                        .fill(station.availability.color)
                        .frame(width: 8, height: 8)
                    
                    Text(station.availability.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(station.availability.color)
                    
                    Spacer()
                }
                
                // Station details
                HStack(spacing: 15) {
                    DetailChip(icon: "bolt.fill", text: station.power, color: .green)
                    PriceChip(text: station.price, languageManager: languageManager)
                }
                
                // Connector types
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
                                        .font(.caption2)
                                }
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                HStack {
                    Image(systemName: "building.2")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(station.provider)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .glassEffect()
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}