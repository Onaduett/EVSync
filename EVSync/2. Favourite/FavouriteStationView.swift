//
//  FavouriteStationView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI
import Supabase
import CoreLocation

// MARK: - User Favorite Model (for database interaction)
struct UserFavorite: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let stationId: UUID
    let createdAt: String
    let station: DatabaseChargingStation?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case stationId = "station_id"
        case createdAt = "created_at"
        case station = "charging_stations"
    }
}

// MARK: - Supabase Manager
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://ncuoknogwyjvdikoysfa.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jdW9rbm9nd3lqdmRpa295c2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDU2ODAsImV4cCI6MjA3MTg4MTY4MH0.FwzpAeHXVQWsWuD2jjDZAdMw_anIT0_uFf9P-aAe0zA"
    )
    
    private init() {}
    
    // Get user's favorite stations
    func getFavoriteStations() async throws -> [UserFavorite] {
        let response: [UserFavorite] = try await client
            .from("user_favorites")
            .select("*, charging_stations(*)")
            .execute()
            .value
        
        return response
    }
    
    // Add station to favorites
    func addToFavorites(stationId: UUID) async throws {
        let user = try await client.auth.user()
        let userId = user.id
        
        let favorite = [
            "user_id": userId.uuidString,
            "station_id": stationId.uuidString
        ]
        
        try await client
            .from("user_favorites")
            .insert(favorite)
            .execute()
    }
    
    // Remove station from favorites
    func removeFromFavorites(favoriteId: UUID) async throws {
        try await client
            .from("user_favorites")
            .delete()
            .eq("id", value: favoriteId.uuidString)
            .execute()
    }
    
    // Check if station is favorited
    func isStationFavorited(stationId: UUID) async throws -> Bool {
        do {
            let user = try await client.auth.user()
            let userId = user.id
            
            let response: [UserFavorite] = try await client
                .from("user_favorites")
                .select("id")
                .eq("user_id", value: userId.uuidString)
                .eq("station_id", value: stationId.uuidString)
                .execute()
                .value
            
            return !response.isEmpty
        } catch {
            // If user is not authenticated, return false
            return false
        }
    }
}

// MARK: - Custom Header
struct FavoriteHeader: View {
    var body: some View {
        HStack {
            Text("Charge&Go")
                .font(.custom("Lexend-SemiBold", size: 20))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text("Favourite")
                .font(.custom("Nunito Sans", size: 20).weight(.bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

struct FavoriteStationsView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var favoriteStations: [UserFavorite] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingError = false
    
    // Navigation bindings
    @Binding var selectedTab: Int
    @Binding var selectedStationFromFavorites: ChargingStation?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Custom Header
                FavoriteHeader()
                
                if isLoading {
                    Spacer()
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                        
                        Text("Loading favorites...")
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 8)
                    }
                    Spacer()
                } else if favoriteStations.isEmpty {
                    Spacer()
                    EmptyFavoritesView(selectedTab: $selectedTab)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(favoriteStations) { favorite in
                                if let dbStation = favorite.station {
                                    FavoriteStationCard(
                                        station: dbStation.toChargingStation(),
                                        favorite: favorite,
                                        onRemove: { favoriteId in
                                            await removeFavorite(favoriteId)
                                        },
                                        onTap: { station in
                                            // Navigate to map and show station detail
                                            selectedStationFromFavorites = station
                                            selectedTab = 0 // Switch to map tab
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100) // Account for custom tab bar
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await loadFavoriteStations()
        }
        .refreshable {
            await loadFavoriteStations()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func loadFavoriteStations() async {
        isLoading = true
        do {
            favoriteStations = try await supabaseManager.getFavoriteStations()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }
    
    private func removeFavorite(_ favoriteId: UUID) async {
        do {
            try await supabaseManager.removeFromFavorites(favoriteId: favoriteId)
            await loadFavoriteStations() // Refresh the list
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

// MARK: - Empty State View
struct EmptyFavoritesView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Favorite Stations")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Add stations to your favorites from the map view to see them here")
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
                    Text("Explore Map")
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

// MARK: - Station Card View
struct FavoriteStationCard: View {
    let station: ChargingStation
    let favorite: UserFavorite
    let onRemove: (UUID) async -> Void
    let onTap: (ChargingStation) -> Void
    
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
                    DetailChip(icon: "tenge", text: station.price, color: .blue)
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

// MARK: - Preview
struct FavoriteStationsView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteStationsView(
            selectedTab: .constant(1),
            selectedStationFromFavorites: .constant(nil)
        )
    }
}
