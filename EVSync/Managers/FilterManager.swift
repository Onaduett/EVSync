//
//  FilterManager.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 06.10.25.
//

import SwiftUI
import MapKit
import CoreLocation

@MainActor
class FilterManager: ObservableObject {
    @Published var showingFilterOptions = false
    @Published var selectedConnectorTypes: Set<ConnectorType> = []
    @Published var selectedOperators: Set<String> = []
    @Published var priceRange: ClosedRange<Double> = 0...100
    @Published var powerRange: ClosedRange<Double> = 0...350
    
    private var allStations: [ChargingStation] = []
    
    
    var availableConnectorTypes: [ConnectorType] {
        let allTypes = allStations.flatMap { $0.connectorTypes }
        return Array(Set(allTypes)).sorted { $0.rawValue < $1.rawValue }
    }
    
    var availableOperators: [String] {
        let allOperators = allStations.map { $0.provider }
        return Array(Set(allOperators)).sorted()
    }
    
    var minPrice: Double {
        let prices = allStations.compactMap { $0.pricePerKWh }
        return prices.isEmpty ? 0 : prices.min() ?? 0
    }
    
    var maxPrice: Double {
        let prices = allStations.compactMap { $0.pricePerKWh }
        return prices.isEmpty ? 100 : prices.max() ?? 100
    }
    
    var minPower: Double {
        let powers = allStations.compactMap { $0.maxPower }
        return powers.isEmpty ? 0 : powers.min() ?? 0
    }
    
    var maxPower: Double {
        let powers = allStations.compactMap { $0.maxPower }
        return powers.isEmpty ? 350 : powers.max() ?? 350
    }
    
    var hasActiveFilters: Bool {
        let defaultPriceRange = minPrice...maxPrice
        let defaultPowerRange = minPower...maxPower
        
        return !selectedConnectorTypes.isEmpty ||
               !selectedOperators.isEmpty ||
               priceRange != defaultPriceRange ||
               powerRange != defaultPowerRange
    }
    
    // MARK: - Public Methods
    
    func updateStations(_ stations: [ChargingStation]) {
        allStations = stations
    }
    
    func initializeFilterRanges() {
        guard !allStations.isEmpty else { return }
        
        let defaultPriceRange = minPrice...maxPrice
        let defaultPowerRange = minPower...maxPower
        
        if priceRange == 0...100 {
            priceRange = defaultPriceRange
        }
        if powerRange == 0...350 {
            powerRange = defaultPowerRange
        }
    }
    
    func clearAllFilters() {
        selectedConnectorTypes.removeAll()
        selectedOperators.removeAll()
        priceRange = minPrice...maxPrice
        powerRange = minPower...maxPower
    }
    
    func applyFilters(to stations: [ChargingStation]) -> [ChargingStation] {
        return stations.filter { station in
            var matchesConnectorFilter = true
            var matchesOperatorFilter = true
            var matchesPriceFilter = true
            var matchesPowerFilter = true
            
            if !selectedConnectorTypes.isEmpty {
                matchesConnectorFilter = !Set(station.connectorTypes).isDisjoint(with: selectedConnectorTypes)
            }
            
            if !selectedOperators.isEmpty {
                matchesOperatorFilter = selectedOperators.contains(station.provider)
            }
            
            if let stationPrice = station.pricePerKWh {
                matchesPriceFilter = priceRange.contains(stationPrice)
            }
            
            if let stationPower = station.maxPower {
                matchesPowerFilter = powerRange.contains(stationPower)
            }
            
            return matchesConnectorFilter && matchesOperatorFilter && matchesPriceFilter && matchesPowerFilter
        }
    }
    
    func shouldAdjustMapForFilteredStations(_ filteredStations: [ChargingStation]) -> Bool {
        guard filteredStations.count <= 5 else { return false }
        
        let coordinates = filteredStations.map { $0.coordinate }
        let minLat = coordinates.map { $0.latitude }.min() ?? 43.25552
        let maxLat = coordinates.map { $0.latitude }.max() ?? 43.25552
        let minLon = coordinates.map { $0.longitude }.min() ?? 76.930076
        let maxLon = coordinates.map { $0.longitude }.max() ?? 76.930076
        
        let latRange = maxLat - minLat
        let lonRange = maxLon - minLon
        
        return latRange < 0.05 && lonRange < 0.05
    }
    
    func calculateRegionForFilteredStations(_ filteredStations: [ChargingStation]) -> MKCoordinateRegion? {
        guard !filteredStations.isEmpty else { return nil }
        
        let coordinates = filteredStations.map { $0.coordinate }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? 43.25552
        let maxLat = coordinates.map { $0.latitude }.max() ?? 43.25552
        let minLon = coordinates.map { $0.longitude }.min() ?? 76.930076
        let maxLon = coordinates.map { $0.longitude }.max() ?? 76.930076
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(min(maxLat - minLat + 0.02, 0.15), 0.05),
            longitudeDelta: max(min(maxLon - minLon + 0.02, 0.15), 0.05)
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}
