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
    @State private var isLoadingFavorite = false
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
        .task {
            isFavorited = supabaseManager.favoriteIds.contains(station.id)
            if supabaseManager.favoriteIds.isEmpty {
                await supabaseManager.syncFavorites()
                isFavorited = supabaseManager.favoriteIds.contains(station.id)
            }
        }
        .onChange(of: station.id) { _, _ in
            isFavorited = supabaseManager.favoriteIds.contains(station.id)
            isLoadingFavorite = false
            showingFullDetail = false
        }
        .onChange(of: showingDetail) { _, isShowing in
            if !isShowing {
                showingFullDetail = false
            }
        }
        .onReceive(supabaseManager.$favoriteIds) { ids in
            isFavorited = ids.contains(station.id)
        }
    }
}
