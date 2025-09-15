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
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(languageManager.localizedString("no_favorite_stations"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(languageManager.localizedString("no_favorite_stations_description"))
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
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
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.regularMaterial)
                        .glassEffect()
                )
            }
            .padding(.top, 10)
        }
    }
}