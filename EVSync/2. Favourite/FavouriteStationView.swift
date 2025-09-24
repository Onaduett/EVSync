//
//  FavoriteStationsView.swift
//  EVSync
//
//  Updated for API integration - Fixed version
//

import SwiftUI
import CoreLocation

struct FavoriteStationsView: View {
    @ObservedObject private var apiManager = APIManager.shared
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    @State private var favoriteStations: [UserFavorite] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var hasAppeared = false
    @State private var contentOpacity: Double = 0.0
    
    // Mock user ID - in real app, get from auth manager
    private let currentUserId = UUID()

    @Binding var selectedTab: Int
    @Binding var selectedStationFromFavorites: ChargingStation?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    if isLoading {
                        Spacer()
                        LoadingView()
                            .opacity(contentOpacity)
                        Spacer()
                    } else if favoriteStations.isEmpty {
                        Spacer()
                        EmptyFavoritesView(selectedTab: $selectedTab)
                            .opacity(contentOpacity)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(favoriteStations.indices, id: \.self) { index in
                                    let favorite = favoriteStations[index]
                                    if let station = favorite.station {
                                        FavoriteStationCard(
                                            station: station,
                                            favorite: favorite,
                                            onRemove: { favoriteId in
                                                await removeFavorite(favoriteId)
                                            },
                                            onTap: { station in
                                                selectedTab = 0
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    selectedStationFromFavorites = station
                                                }
                                            }
                                        )
                                        .opacity(contentOpacity)
                                        .animation(
                                            .easeOut(duration: 0.4)
                                            .delay(Double(index) * 0.05),
                                            value: contentOpacity
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 100) // Space for header
                            .padding(.bottom, 100) // Space for tab bar
                        }
                    }
                }
                
                // Header
                FavoriteHeader()
                    .opacity(contentOpacity)
            }
        }
        .background(backgroundColor.ignoresSafeArea())
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .onAppear {
            startFavoriteViewAnimation()
        }
        .onDisappear {
            hasAppeared = false
            contentOpacity = 0.0
        }
        .refreshable {
            await loadFavoriteStations()
        }
        .alert(languageManager.localizedString("error_title"), isPresented: $showingError) {
            Button(languageManager.localizedString("ok_button")) { }
        } message: {
            Text(errorMessage ?? languageManager.localizedString("unknown_error"))
                .customFont(.body)
        }
    }
    
    // MARK: - Private Views
    private var backgroundColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return Color(.systemGroupedBackground)
        case .dark:
            return Color(.systemBackground)
        case .auto:
            return Color(.systemGroupedBackground)
        }
    }
    
    // MARK: - Private Methods
    private func startFavoriteViewAnimation() {
        guard !hasAppeared else { return }
        hasAppeared = true
        
        withAnimation(.easeIn(duration: 0.3)) {
            contentOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            Task {
                await loadFavoriteStations()
            }
        }
    }
    
    private func loadFavoriteStations() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let stations = try await apiManager.getFavoriteStations(for: currentUserId)
            await MainActor.run {
                favoriteStations = stations
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showingError = true
                isLoading = false
            }
        }
    }
    
    private func removeFavorite(_ favoriteId: UUID) async {
        do {
            try await apiManager.removeFromFavorites(favoriteId: favoriteId)
            await loadFavoriteStations()
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)
            
            Text(languageManager.localizedString("loading_favorites"))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct FavoriteStationsView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteStationsView(
            selectedTab: .constant(1),
            selectedStationFromFavorites: .constant(nil)
        )
        .environmentObject(LanguageManager())
        .environmentObject(ThemeManager())
        .environmentObject(FontManager.shared)
    }
}
