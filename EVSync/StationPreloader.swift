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
    
    private var cacheTimestamp: Date?
    private let cacheExpirationTime: TimeInterval = 300 // 5 минут
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://ncuoknogwyjvdikoysfa.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jdW9rbm9nd3lqdmRpa295c2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDU2ODAsImV4cCI6MjA3MTg4MTY4MH0.FwzpAeHXVQWsWuD2jjDZAdMw_anIT0_uFf9P-aAe0zA"
    )
    
    private init() {}
    
    func preloadStations() {
        guard !isLoading else { return }
        
        // Если данные свежие, не перезагружаем
        if isCacheValid() {
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let response: [DatabaseChargingStation] = try await supabase
                    .from("charging_stations")
                    .select()
                    .execute()
                    .value
                
                let loadedStations = response.map { $0.toChargingStation() }
                
                await MainActor.run {
                    self.stations = loadedStations
                    self.isLoaded = true
                    self.isLoading = false
                    self.cacheTimestamp = Date()
                }
                
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func forceRefresh() {
        cacheTimestamp = nil
        preloadStations()
    }
    
    private func isCacheValid() -> Bool {
        guard let timestamp = cacheTimestamp else { return false }
        return isLoaded && !stations.isEmpty && Date().timeIntervalSince(timestamp) < cacheExpirationTime
    }
}
