//
//  MapViewModel.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI
import MapKit
import Supabase
import CoreLocation

@MainActor
class MapViewModel: ObservableObject {
    @Published var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.25552, longitude: 76.930076),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )
    
    @Published var selectedStation: ChargingStation?
    @Published var showingStationDetail = false
    @Published var chargingStations: [ChargingStation] = []
    @Published var filteredStations: [ChargingStation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var mapStyle: MKMapType = .standard
    
    // Filter properties
    @Published var showingFilterOptions = false
    @Published var selectedConnectorTypes: Set<ConnectorType> = []
    @Published var selectedOperators: Set<String> = []
    @Published var priceRange: ClosedRange<Double> = 0...100
    @Published var powerRange: ClosedRange<Double> = 0...350
    
    @Published private var currentRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.25552, longitude: 76.930076),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )
    
    private let focusSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    private let zoomOutFactor: Double = 1.4
    private let minDelta: Double = 0.002
    private let maxDelta: Double = 1.5
    
    private let almatyCenter = CLLocationCoordinate2D(latitude: 43.25552, longitude: 76.930076)
    private let almatySpan = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    private var hasInitialLoad = false
    
    private var cachedStations: [ChargingStation] = []
    private var cacheTimestamp: Date?
    private let cacheExpirationTime: TimeInterval = 300 // 5 minutes
    
    private let supabase = SupabaseClient(
        supabaseURL: SupabaseConfig.supabaseURL,
        supabaseKey: SupabaseConfig.supabaseKey
    )
    
    // MARK: - Computed Filter Properties
    
    var availableConnectorTypes: [ConnectorType] {
        let allTypes = chargingStations.flatMap { $0.connectorTypes }
        return Array(Set(allTypes)).sorted { $0.rawValue < $1.rawValue }
    }
    
    var availableOperators: [String] {
        let allOperators = chargingStations.map { $0.provider }
        return Array(Set(allOperators)).sorted()
    }
    
    var minPrice: Double {
        let prices = chargingStations.compactMap { $0.pricePerKWh }
        return prices.isEmpty ? 0 : prices.min() ?? 0
    }
    
    var maxPrice: Double {
        let prices = chargingStations.compactMap { $0.pricePerKWh }
        return prices.isEmpty ? 100 : prices.max() ?? 100
    }
    
    var minPower: Double {
        let powers = chargingStations.compactMap { $0.maxPower }
        return powers.isEmpty ? 0 : powers.min() ?? 0
    }
    
    var maxPower: Double {
        let powers = chargingStations.compactMap { $0.maxPower }
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
    
    // MARK: - Cinematic Map Methods
    
    private func updateCurrentRegion(_ region: MKCoordinateRegion) {
        currentRegion = region
    }
    
    private func setCamera(_ position: MapCameraPosition, animated: Bool) {
        if animated {
            withAnimation(.easeInOut(duration: 0.6)) {
                cameraPosition = position
            }
        } else {
            cameraPosition = position
        }
    }
    
    private func clamp(_ value: Double, _ minValue: Double, _ maxValue: Double) -> Double {
        return Swift.max(minValue, Swift.min(value, maxValue))
    }
    
    func focusOnStation(_ station: ChargingStation, animated: Bool = true) {
        selectedStation = station
        let region = MKCoordinateRegion(center: station.coordinate, span: focusSpan)
        updateCurrentRegion(region)
        setCamera(.region(region), animated: animated)
    }
    
    func subtleZoomOut(animated: Bool = true) {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: clamp(currentRegion.span.latitudeDelta * zoomOutFactor, minDelta, maxDelta),
            longitudeDelta: clamp(currentRegion.span.longitudeDelta * zoomOutFactor, minDelta, maxDelta)
        )
        
        let newRegion = MKCoordinateRegion(center: currentRegion.center, span: newSpan)
        updateCurrentRegion(newRegion)
        setCamera(.region(newRegion), animated: animated)
        
        selectedStation = nil
    }
    
    func selectStation(_ station: ChargingStation) {
        selectedStation = station
        showingStationDetail = true
        focusOnStation(station, animated: true)
    }

    func clearSelectedStation() {
        selectedStation = nil
        showingStationDetail = false
        subtleZoomOut()
    }
    
    func centerOnUserLocation(_ userLocation: CLLocationCoordinate2D) {
        let newRegion = MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        updateCurrentRegion(newRegion)
        
        withAnimation(.easeInOut(duration: 1.0)) {
            cameraPosition = .region(newRegion)
        }
    }
    
    func resetToDefaultPosition() {
        selectedStation = nil
        showingStationDetail = false
        
        let currentSpan = currentRegion.span
        let targetSpan = almatySpan
        
        let needsZoomOut = currentSpan.latitudeDelta < targetSpan.latitudeDelta
        
        if needsZoomOut {
            let intermediateSpan = MKCoordinateSpan(
                latitudeDelta: currentSpan.latitudeDelta * 1.5,
                longitudeDelta: currentSpan.longitudeDelta * 1.5
            )
            let intermediateRegion = MKCoordinateRegion(center: currentRegion.center, span: intermediateSpan)
            
            withAnimation(.easeOut(duration: 0.4)) {
                cameraPosition = .region(intermediateRegion)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                let region = MKCoordinateRegion(center: self.almatyCenter, span: self.almatySpan)
                self.updateCurrentRegion(region)
                
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.cameraPosition = .region(region)
                }
            }
        } else {
            let region = MKCoordinateRegion(center: almatyCenter, span: almatySpan)
            updateCurrentRegion(region)
            
            withAnimation(.easeInOut(duration: 0.8)) {
                cameraPosition = .region(region)
            }
        }
    }
    
    // MARK: - Data Loading
    
    func loadChargingStations(forceRefresh: Bool = false) {
        if !forceRefresh && isCacheValid() {
            chargingStations = cachedStations
            filteredStations = chargingStations
            isLoading = false
            
            initializeFilterRanges()
            
            if !hasInitialLoad {
                setAlmatyRegion()
            }
            hasInitialLoad = true
            return
        }
        
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response: [DatabaseChargingStation] = try await supabase
                    .from("charging_stations")
                    .select()
                    .execute()
                    .value

                let loadedStations = response.map { $0.toChargingStation() }
                
                self.cachedStations = loadedStations
                self.cacheTimestamp = Date()
                
                self.chargingStations = loadedStations
                self.filteredStations = loadedStations
                self.isLoading = false
                
                self.initializeFilterRanges()

                if !hasInitialLoad {
                    setAlmatyRegion()
                }
                hasInitialLoad = true

            } catch {
                self.errorMessage = "Failed to load charging stations: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func navigateToStationFromFavorites(_ station: ChargingStation) {
        let stationToShow = chargingStations.first(where: { $0.id == station.id }) ?? station
        focusOnStation(stationToShow)
        showingStationDetail = true
    }
    
    // MARK: - Cache Management
    
    private func isCacheValid() -> Bool {
        guard let timestamp = cacheTimestamp else { return false }
        return !cachedStations.isEmpty && Date().timeIntervalSince(timestamp) < cacheExpirationTime
    }
    
    func refreshData() {
        loadChargingStations(forceRefresh: true)
    }
    
    func preloadStations() {
        let preloader = StationsPreloader.shared
        
        if preloader.isLoaded && !preloader.stations.isEmpty {
            chargingStations = preloader.stations
            filteredStations = chargingStations
            isLoading = false
            hasInitialLoad = true
            initializeFilterRanges()
            return
        }
        
        if isCacheValid() {
            chargingStations = cachedStations
            filteredStations = chargingStations
            isLoading = false
            hasInitialLoad = true
            initializeFilterRanges()
            return
        }
        
        Task {
            preloader.preloadStations()
            
            if preloader.stations.isEmpty {
                await MainActor.run {
                    self.loadChargingStations()
                }
            } else {
                await MainActor.run {
                    self.chargingStations = preloader.stations
                    self.filteredStations = preloader.stations
                    self.isLoading = false
                    self.hasInitialLoad = true
                    self.initializeFilterRanges()
                }
            }
        }
    }
    
    // MARK: - Filter Management
    
    func initializeFilterRanges() {
        guard !chargingStations.isEmpty else { return }
        
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
    
    func applyFilters() {
        filteredStations = chargingStations.filter { station in
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
        
        if !filteredStations.isEmpty && shouldAdjustMapForFilteredStations() {
            updateMapRegionForFiltered()
        }
    }
    
    private func shouldAdjustMapForFilteredStations() -> Bool {
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
    
    private func calculateRegionForFilteredStations() -> MKCoordinateRegion? {
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
    
    // MARK: - Private Methods
    
    private func setAlmatyRegion() {
        let region = MKCoordinateRegion(center: almatyCenter, span: almatySpan)
        updateCurrentRegion(region)
        
        withAnimation(.easeInOut(duration: 1.0)) {
            cameraPosition = .region(region)
        }
    }
    
    private func updateMapRegionForFiltered() {
        guard let region = calculateRegionForFilteredStations() else { return }
        
        updateCurrentRegion(region)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(region)
        }
    }
}
