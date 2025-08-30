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

// MARK: - Enhanced Supabase Manager
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://ncuoknogwyjvdikoysfa.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jdW9rbm9nd3lqdmRpa295c2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDU2ODAsImV4cCI6MjA3MTg4MTY4MH0.FwzpAeHXVQWsWuD2jjDZAdMw_anIT0_uFf9P-aAe0zA"
    )
    
    private init() {}
    
    // Get user's favorite stations
    func getFavoriteStations() async throws -> [UserFavorite] {
        let user = try await client.auth.user()
        let userId = user.id
        
        print("📋 Loading favorites for user: \(userId)")
        
        let response: [UserFavorite] = try await client
            .from("user_favorites")
            .select("*, charging_stations(*)")
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        print("📋 Found \(response.count) favorite stations")
        return response
    }
    
    // Remove station from favorites
    func removeFromFavorites(favoriteId: UUID) async throws {
        print("➖ Removing favorite with ID: \(favoriteId)")
        
        try await client
            .from("user_favorites")
            .delete()
            .eq("id", value: favoriteId.uuidString)
            .execute()
        
        print("✅ Successfully removed from favorites")
    }
    
    // Remove station from favorites by station ID
    func removeFromFavoritesByStationId(stationId: UUID) async throws {
        let user = try await client.auth.user()
        let userId = user.id
        
        print("➖ Removing from favorites: user \(userId), station \(stationId)")
        
        try await client
            .from("user_favorites")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("station_id", value: stationId.uuidString)
            .execute()
        
        print("✅ Successfully removed from favorites by station ID")
    }
    
    // Check if station is favorited - FIXED VERSION
    func isStationFavorited(stationId: UUID) async throws -> Bool {
        do {
            let user = try await client.auth.user()
            let userId = user.id
            
            print("🔍 Checking favorite status for user: \(userId), station: \(stationId)")
            
            let response: [UserFavorite] = try await client
                .from("user_favorites")
                .select("id, user_id, station_id")
                .eq("user_id", value: userId.uuidString)
                .eq("station_id", value: stationId.uuidString)
                .execute()
                .value
            
            let isFavorited = !response.isEmpty
            print("🔍 Query result: found \(response.count) records, isFavorited: \(isFavorited)")
            
            if !response.isEmpty {
                let record = response[0]
                print("🔍 First record - ID: \(record.id), UserID: \(record.userId), StationID: \(record.stationId)")
            }
            
            return isFavorited
        } catch {
            print("❌ Error in isStationFavorited: \(error)")
            return false
        }
    }
    

    func toggleStationFavorite(stationId: UUID) async throws -> Bool {
        print("🔄 Toggling favorite for station: \(stationId)")
        
        let currentStatus = try await isStationFavorited(stationId: stationId)
        print("🔄 Current status: \(currentStatus)")
        
        if currentStatus {
            // Remove from favorites
            try await removeFromFavoritesByStationId(stationId: stationId)
            print("🔄 Removed from favorites, new status: false")
            return false
        } else {
            // Add to favorites with duplicate handling
            do {
                try await addToFavorites(stationId: stationId)
                print("🔄 Added to favorites, new status: true")
                return true
            } catch let error as PostgrestError {
                // Handle duplicate key constraint violation
                if error.code == "23505" {
                    print("⚠️ Duplicate constraint error - station already favorited")
                    // Station is already favorited, return true
                    return true
                } else {
                    throw error
                }
            }
        }
    }

    // Also improve the addToFavorites method
    func addToFavorites(stationId: UUID) async throws {
        let user = try await client.auth.user()
        let userId = user.id
        
        print("➕ Adding to favorites: user \(userId), station \(stationId)")
        
        // Double-check if already exists to prevent duplicate error
        let exists = try await isStationFavorited(stationId: stationId)
        if exists {
            print("⚠️ Station already in favorites, skipping add")
            return
        }
        
        let favorite = [
            "user_id": userId.uuidString,
            "station_id": stationId.uuidString
        ]
        
        do {
            try await client
                .from("user_favorites")
                .insert(favorite)
                .execute()
            
            print("✅ Successfully added to favorites")
        } catch let error as PostgrestError {
            // Handle duplicate key constraint violation gracefully
            if error.code == "23505" {
                print("⚠️ Duplicate constraint error - station was already favorited by another process")
                // This is not really an error, just means station is already favorited
                return
            } else {
                throw error
            }
        }
    }
}

// MARK: - Custom Header
struct FavoriteHeader: View {
    var body: some View {
        HStack {
            Text("Charge&Go")
                .font(.custom("Nunito Sans", size: 20).weight(.bold))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text("Favourite")
                .font(.custom("Nunito Sans", size: 20).weight(.bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

// MARK: - Main Favorite Stations View
struct FavoriteStationsView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var favoriteStations: [UserFavorite] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var selectedStation: ChargingStation?
    @State private var showingStationDetail = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
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
                    EmptyFavoritesView()
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
                                            selectedStation = station
                                            showingStationDetail = true
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
        .onReceive(NotificationCenter.default.publisher(for: .favoritesChanged)) { _ in
            // Refresh when favorites change from other screens
            Task {
                await loadFavoriteStations()
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .sheet(isPresented: $showingStationDetail) {
            if let station = selectedStation {
                StationDetailCard(station: station, showingDetail: $showingStationDetail)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onChange(of: showingStationDetail) { isShowing in
            // Refresh favorites when detail sheet is dismissed
            if !isShowing {
                Task {
                    await loadFavoriteStations()
                }
            }
        }
    }
    
    @MainActor
    private func loadFavoriteStations() async {
        isLoading = true
        print("🔄 Loading favorite stations...")
        
        do {
            favoriteStations = try await supabaseManager.getFavoriteStations()
            print("✅ Loaded \(favoriteStations.count) favorite stations")
        } catch {
            print("❌ Error loading favorites: \(error)")
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isLoading = false
    }
    
    @MainActor
    private func removeFavorite(_ favoriteId: UUID) async {
        print("🗑️ Removing favorite: \(favoriteId)")
        
        do {
            try await supabaseManager.removeFromFavorites(favoriteId: favoriteId)
            await loadFavoriteStations() // Refresh the list
            
            // Post notification that favorites changed
            NotificationCenter.default.post(name: .favoritesChanged, object: nil)
            
            print("✅ Successfully removed favorite and refreshed list")
        } catch {
            print("❌ Error removing favorite: \(error)")
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

// MARK: - Empty State View
struct EmptyFavoritesView: View {
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
            
            // Suggestion to go to map
            Button(action: {
                // This would need to be handled by parent view to switch tabs
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
                            // Post notification that favorites changed
                            NotificationCenter.default.post(name: .favoritesChanged, object: nil)
                            isRemoving = false
                        }
                    }) {
                        if isRemoving {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        } else {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                        }
                    }
                    .disabled(isRemoving)
                    .frame(width: 30, height: 30)
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
                                    Image(systemName: connector.icon)
                                        .font(.caption2)
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

// MARK: - Detail Chip
struct DetailChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .clipShape(Capsule())
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let favoritesChanged = Notification.Name("favoritesChanged")
}

// MARK: - Preview
struct FavoriteStationsView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteStationsView()
    }
}
