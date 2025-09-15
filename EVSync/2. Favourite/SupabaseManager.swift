//
//  SupabaseManager.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 15.09.25.
//


import Foundation
import Supabase

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
            return false
        }
    }
}
