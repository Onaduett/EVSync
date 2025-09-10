//
//  MapViewModel.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI
import MapKit
import Supabase

@MainActor
class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.25552, longitude: 76.930076),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @Published var selectedStation: ChargingStation?
    @Published var showingStationDetail = false
    @Published var chargingStations: [ChargingStation] = []
    @Published var filteredStations: [ChargingStation] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var showingFilterOptions = false
    @Published var selectedConnectorTypes: Set<ConnectorType> = []
    @Published var mapStyle: MKMapType = .standard
    
    private let almatyCenter = CLLocationCoordinate2D(latitude: 43.25552, longitude: 76.930076)
    private let almatySpan = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://ncuoknogwyjvdikoysfa.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jdW9rbm9nd3lqdmRpa295c2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDU2ODAsImV4cCI6MjA3MTg4MTY4MH0.FwzpAeHXVQWsWuD2jjDZAdMw_anIT0_uFf9P-aAe0zA"
    )
    
    var availableConnectorTypes: [ConnectorType] {
        let allTypes = chargingStations.flatMap { $0.connectorTypes }
        return Array(Set(allTypes)).sorted { $0.rawValue < $1.rawValue }
    }
    
    func selectStation(_ station: ChargingStation) {
        selectedStation = station
        showingStationDetail = true
        
        withAnimation(.easeInOut(duration: 0.5)) {
            region.center = station.coordinate
        }
    }
    
    func centerMapOnStation(_ station: ChargingStation) {
        withAnimation(.easeInOut(duration: 0.5)) {
            region.center = station.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        }
    }
    
    func loadChargingStations() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response: [DatabaseChargingStation] = try await supabase.database
                    .from("charging_stations")
                    .select()
                    .execute()
                    .value
                
                self.chargingStations = response.map { $0.toChargingStation() }
                self.filteredStations = self.chargingStations
                self.isLoading = false
                
                setAlmatyRegion()
                
            } catch {
                self.errorMessage = "Failed to load charging stations: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func applyFilters() {
        if selectedConnectorTypes.isEmpty {
            filteredStations = chargingStations
        } else {
            filteredStations = chargingStations.filter { station in
                return !Set(station.connectorTypes).isDisjoint(with: selectedConnectorTypes)
            }
        }
        

        if !filteredStations.isEmpty && shouldAdjustForFilteredStations() {
            updateMapRegionForFiltered()
        }
    }
    
    // MARK: - Private Methods
    private func shouldAdjustForFilteredStations() -> Bool {
        guard filteredStations.count <= 5 else { return false }
        
        let coordinates = filteredStations.map { $0.coordinate }
        let minLat = coordinates.map { $0.latitude }.min() ?? almatyCenter.latitude
        let maxLat = coordinates.map { $0.latitude }.max() ?? almatyCenter.latitude
        let minLon = coordinates.map { $0.longitude }.min() ?? almatyCenter.longitude
        let maxLon = coordinates.map { $0.longitude }.max() ?? almatyCenter.longitude
        
        let latRange = maxLat - minLat
        let lonRange = maxLon - minLon
        
        return latRange < 0.05 && lonRange < 0.05
    }
    
    private func setAlmatyRegion() {
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(center: almatyCenter, span: almatySpan)
        }
    }
    
    private func updateMapRegionForFiltered() {
        let coordinates = filteredStations.map { $0.coordinate }
        guard !coordinates.isEmpty else { return }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? almatyCenter.latitude
        let maxLat = coordinates.map { $0.latitude }.max() ?? almatyCenter.latitude
        let minLon = coordinates.map { $0.longitude }.min() ?? almatyCenter.longitude
        let maxLon = coordinates.map { $0.longitude }.max() ?? almatyCenter.longitude
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(min(maxLat - minLat + 0.02, 0.15), 0.05),
            longitudeDelta: max(min(maxLon - minLon + 0.02, 0.15), 0.05)
        )
        
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(center: center, span: span)
        }
    }
}
