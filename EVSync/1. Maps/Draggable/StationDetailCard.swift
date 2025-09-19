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
    @State private var dragOffset: CGFloat = 0
    @StateObject private var supabaseManager = SupabaseManager.shared
    @Namespace private var hero // Added namespace for matched geometry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showingFullDetail {
                StationFullDetailView(
                    station: station,
                    showingDetail: $showingDetail,
                    showingFullDetail: $showingFullDetail,
                    isFavorited: $isFavorited,
                    isLoadingFavorite: $isLoadingFavorite,
                    dragOffset: $dragOffset,
                    supabaseManager: supabaseManager,
                    ns: hero // Pass namespace to full view
                )
                .zIndex(1)
            } else {
                StationPreviewView(
                    station: station,
                    showingDetail: $showingDetail,
                    showingFullDetail: $showingFullDetail,
                    dragOffset: $dragOffset,
                    ns: hero // Pass namespace to preview view
                )
                .zIndex(1)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(radius: 20, x: 0, y: 10)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .padding(.bottom, -10)
        .offset(y: 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.88), value: showingFullDetail)
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
