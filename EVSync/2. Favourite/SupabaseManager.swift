//
//  SupabaseManager.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 15.09.25.
//

import Foundation
import Supabase

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client = SupabaseClient(
        supabaseURL: SupabaseConfig.supabaseURL,
        supabaseKey: SupabaseConfig.supabaseKey
    )
    
    @Published private(set) var favoriteIds: Set<UUID> = []
    
    private init() {}
    
    @MainActor
    func syncFavorites() async {
        do {
            let user = try await client.auth.user()
            let response: [[String: AnyJSON]] = try await client
                .from("user_favorites")
                .select("station_id")
                .eq("user_id", value: user.id.uuidString)
                .execute()
                .value
            
            let ids = response.compactMap { row in
                if case .string(let stationIdString) = row["station_id"] {
                    return UUID(uuidString: stationIdString)
                }
                return nil
            }
            favoriteIds = Set(ids)
        } catch {
            print("Sync favorites error: \(error)")
        }
    }
    
    func getFavoriteStations() async throws -> [UserFavorite] {
        let user = try await client.auth.user()
        let response: [UserFavorite] = try await client
            .from("user_favorites")
            .select("*, charging_stations(*)")
            .eq("user_id", value: user.id.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }
    
    func addFavorite(stationId: UUID) async throws {
        let user = try await client.auth.user()
        
        _ = await MainActor.run { favoriteIds.insert(stationId) }
        
        do {
            try await client
                .from("user_favorites")
                .insert([
                    "user_id": user.id.uuidString,
                    "station_id": stationId.uuidString
                ])
                .execute()
        } catch {
            _ = await MainActor.run { favoriteIds.remove(stationId) }
            throw error
        }
    }
    
    func removeFavorite(stationId: UUID) async throws {
        let user = try await client.auth.user()
        
        _ = await MainActor.run { favoriteIds.remove(stationId) }
        
        do {
            try await client
                .from("user_favorites")
                .delete()
                .eq("user_id", value: user.id.uuidString)
                .eq("station_id", value: stationId.uuidString)
                .execute()
        } catch {
            _ = await MainActor.run { favoriteIds.insert(stationId) }
            throw error
        }
    }
    
    func addToFavorites(stationId: UUID) async throws {
        try await addFavorite(stationId: stationId)
    }
    
    func removeFromFavorites(favoriteId: UUID) async throws {
        try await client
            .from("user_favorites")
            .delete()
            .eq("id", value: favoriteId.uuidString)
            .execute()
        await syncFavorites()
    }
    
    func isStationFavorited(stationId: UUID) async throws -> Bool {
        if favoriteIds.contains(stationId) { return true }
        
        let user = try await client.auth.user()
        let response: [[String: AnyJSON]] = try await client
            .from("user_favorites")
            .select("station_id")
            .eq("user_id", value: user.id.uuidString)
            .eq("station_id", value: stationId.uuidString)
            .execute()
            .value
        
        let exists = !response.isEmpty
        if exists {
            _ = await MainActor.run { favoriteIds.insert(stationId) }
        }
        return exists
    }
}
