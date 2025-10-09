//
//  StationPreloader.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 15.09.25.
//

import Foundation
import Supabase
import CoreLocation

@MainActor
class StationsPreloader: ObservableObject {
    static let shared = StationsPreloader()
    
    @Published var stations: [ChargingStation] = []
    @Published var isLoaded = false
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cacheTimestamp: Date?
    private let cacheExpirationTime: TimeInterval = 300 // 5 минут
    
    private let supabase = SupabaseClient(
        supabaseURL: SupabaseConfig.supabaseURL,
        supabaseKey: SupabaseConfig.supabaseKey
    )
    
    private init() {
        print("🔄 StationsPreloader initialized")
    }
    
    func preloadStations() async {
        guard !isLoading else {
            print("⚠️ Already loading, skipping...")
            return
        }
        
        // Если данные свежие, не перезагружаем
        if isCacheValid() {
            print("✅ Cache is valid, using cached data (\(stations.count) stations)")
            return
        }
        
        print("🔄 Starting to preload stations...")
        isLoading = true
        error = nil
        
        do {
            let response: [DatabaseChargingStation] = try await supabase
                .from("charging_stations")
                .select()
                .execute()
                .value
            
            let loadedStations = response.map { $0.toChargingStation() }
            
            self.stations = loadedStations
            self.isLoaded = true
            self.isLoading = false
            self.cacheTimestamp = Date()
            
            print("✅ Successfully loaded \(loadedStations.count) stations")
            
        } catch {
            print("❌ Failed to preload stations: \(error.localizedDescription)")
            self.error = error
            self.isLoading = false
        }
    }
    
    func forceRefresh() async {
        print("🔄 Force refreshing stations...")
        cacheTimestamp = nil
        isLoaded = false
        await preloadStations()
    }
    
    private func isCacheValid() -> Bool {
        guard let timestamp = cacheTimestamp else { return false }
        let isValid = isLoaded && !stations.isEmpty && Date().timeIntervalSince(timestamp) < cacheExpirationTime
        
        if !isValid {
            if !isLoaded {
                print("❌ Cache invalid: not loaded")
            } else if stations.isEmpty {
                print("❌ Cache invalid: stations empty")
            } else {
                print("❌ Cache invalid: expired (\(Date().timeIntervalSince(timestamp))s old)")
            }
        }
        
        return isValid
    }
    
    func clearCache() {
        print("🗑️ Clearing preloader cache")
        stations.removeAll()
        isLoaded = false
        cacheTimestamp = nil
        error = nil
    }
}
