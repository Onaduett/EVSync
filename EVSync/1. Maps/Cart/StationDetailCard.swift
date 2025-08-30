//
//  StationDetailCard.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

struct StationDetailCard: View {
    let station: ChargingStation
    @Binding var showingDetail: Bool
    @State private var showingFullDetail = false
    @State private var isFavorited = false
    @State private var isLoadingFavorite = true // Start with loading true
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showingFullDetail {
                StationFullDetailView(
                    station: station,
                    showingDetail: $showingDetail,
                    showingFullDetail: $showingFullDetail,
                    isFavorited: $isFavorited,
                    isLoadingFavorite: $isLoadingFavorite,
                    supabaseManager: supabaseManager
                )
            } else {
                StationPreviewView(
                    station: station,
                    showingDetail: $showingDetail,
                    showingFullDetail: $showingFullDetail
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 16)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingFullDetail)
        .onAppear {
            // Check favorite status when view appears
            Task {
                await checkFavoriteStatus()
            }
        }
        .onChange(of: station.id) { newStationId in
            // When station changes, check status but DON'T reset isFavorited to false
            // Keep the loading state but don't assume the station is not favorited
            isLoadingFavorite = true
            Task {
                await checkFavoriteStatus()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .favoritesChanged)) { _ in
            // Refresh favorite status when favorites change from other screens
            Task {
                await checkFavoriteStatus()
            }
        }
    }
    
    // MARK: - Favorite Methods
    @MainActor
    private func checkFavoriteStatus() async {
        isLoadingFavorite = true
        let stationId = station.id
        
        do {
            let favoriteStatus = try await supabaseManager.isStationFavorited(stationId: stationId)
            isFavorited = favoriteStatus
            isLoadingFavorite = false
            print("✅ Station \(station.name) favorite status: \(favoriteStatus)")
        } catch {
            print("❌ Error checking favorite status: \(error)")
            isLoadingFavorite = false
            // Don't change isFavorited on error, keep current state
        }
    }
}
