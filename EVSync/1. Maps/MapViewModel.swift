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
    @Published var isAnimatingToStation = false
    
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
    
    // MARK: - Position & Filter Persistence
    
    private let positionKey = "savedMapPosition"
    private let filtersKey = "savedMapFilters"
    private var shouldRestorePosition = true
    
    init() {
        restoreMapPosition()
        restoreFilters()
    }
    
    private func saveMapPosition() {
        let position = SavedMapPosition(
            latitude: currentRegion.center.latitude,
            longitude: currentRegion.center.longitude,
            latitudeDelta: currentRegion.span.latitudeDelta,
            longitudeDelta: currentRegion.span.longitudeDelta
        )
        
        if let encoded = try? JSONEncoder().encode(position) {
            UserDefaults.standard.set(encoded, forKey: positionKey)
        }
    }
    
    private func restoreMapPosition() {
        guard let data = UserDefaults.standard.data(forKey: positionKey),
              let position = try? JSONDecoder().decode(SavedMapPosition.self, from: data) else {
            return
        }
        
        let center = CLLocationCoordinate2D(
            latitude: position.latitude,
            longitude: position.longitude
        )
        let span = MKCoordinateSpan(
            latitudeDelta: position.latitudeDelta,
            longitudeDelta: position.longitudeDelta
        )
        
        let region = MKCoordinateRegion(center: center, span: span)
        currentRegion = region
        cameraPosition = .region(region)
    }
    
    private func saveFilters() {
        let filters = SavedMapFilters(
            connectorTypes: Array(selectedConnectorTypes.map { $0.rawValue }),
            operators: Array(selectedOperators),
            priceRangeLower: priceRange.lowerBound,
            priceRangeUpper: priceRange.upperBound,
            powerRangeLower: powerRange.lowerBound,
            powerRangeUpper: powerRange.upperBound
        )
        
        if let encoded = try? JSONEncoder().encode(filters) {
            UserDefaults.standard.set(encoded, forKey: filtersKey)
        }
    }
    
    private func restoreFilters() {
        guard let data = UserDefaults.standard.data(forKey: filtersKey),
              let filters = try? JSONDecoder().decode(SavedMapFilters.self, from: data) else {
            return
        }
        
        selectedConnectorTypes = Set(filters.connectorTypes.compactMap { ConnectorType(rawValue: $0) })
        selectedOperators = Set(filters.operators)
        priceRange = filters.priceRangeLower...filters.priceRangeUpper
        powerRange = filters.powerRangeLower...filters.powerRangeUpper
    }
    
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
    
    // MARK: - Виртуализация станций (оптимизация рендеринга)
    
    var visibleStations: [ChargingStation] {
        // Если анимируемся к станции, показываем все отфильтрованные станции
        if isAnimatingToStation {
            return filteredStations
        }
        
        let region = currentRegion
        let buffer = 0.15 // 15% буфер для плавной подгрузки
        
        return filteredStations.filter { station in
            let latDiff = abs(station.coordinate.latitude - region.center.latitude)
            let lonDiff = abs(station.coordinate.longitude - region.center.longitude)
            
            return latDiff <= region.span.latitudeDelta * (0.5 + buffer) &&
                   lonDiff <= region.span.longitudeDelta * (0.5 + buffer)
        }
    }
    
    // MARK: - Cinematic Map Methods with Smooth Animations
    
    func updateCurrentRegion(_ region: MKCoordinateRegion) {
        let threshold = 0.0001
        guard abs(currentRegion.center.latitude - region.center.latitude) > threshold ||
              abs(currentRegion.center.longitude - region.center.longitude) > threshold ||
              abs(currentRegion.span.latitudeDelta - region.span.latitudeDelta) > threshold else {
            return
        }
        currentRegion = region
        saveMapPosition()
    }
    
    private func setCamera(_ position: MapCameraPosition, animated: Bool, duration: Double = 0.6) {
        if animated && !isLoading {
            withAnimation(.easeInOut(duration: duration)) {
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
        isAnimatingToStation = true
        
        let region = MKCoordinateRegion(center: station.coordinate, span: focusSpan)
        updateCurrentRegion(region)
        setCamera(.region(region), animated: animated, duration: 0.8)
        
        // Отключаем флаг после завершения анимации
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 секунды
            isAnimatingToStation = false
        }
    }
    
    func subtleZoomOut(animated: Bool = true) {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: clamp(currentRegion.span.latitudeDelta * zoomOutFactor, minDelta, maxDelta),
            longitudeDelta: clamp(currentRegion.span.longitudeDelta * zoomOutFactor, minDelta, maxDelta)
        )
        
        let newRegion = MKCoordinateRegion(center: currentRegion.center, span: newSpan)
        updateCurrentRegion(newRegion)
        setCamera(.region(newRegion), animated: animated, duration: 0.7)
        
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
        subtleZoomOut(animated: true)
    }
    
    func centerOnUserLocation(_ userLocation: CLLocationCoordinate2D) {
        let newRegion = MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        updateCurrentRegion(newRegion)
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
            cameraPosition = .region(newRegion)
        }
    }
    
    func resetToDefaultPosition() {
        selectedStation = nil
        showingStationDetail = false
        
        let region = MKCoordinateRegion(center: almatyCenter, span: almatySpan)
        updateCurrentRegion(region)
        
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
            cameraPosition = .region(region)
        }
    }
    
    // MARK: - Data Loading
    
    func loadChargingStations(forceRefresh: Bool = false) {
        if !forceRefresh && isCacheValid() {
            chargingStations = cachedStations
            applyFilters()
            isLoading = false
            
            initializeFilterRanges()
            
            if !hasInitialLoad && shouldRestorePosition {
                shouldRestorePosition = false
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
                self.applyFilters()
                self.isLoading = false
                
                self.initializeFilterRanges()

                if !hasInitialLoad && shouldRestorePosition {
                    shouldRestorePosition = false
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
        focusOnStation(stationToShow, animated: true)
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
        
        // Проверяем локальный кэш первым делом
        if isCacheValid() {
            print("📦 Using local cache (\(cachedStations.count) stations)")
            chargingStations = cachedStations
            applyFilters()
            isLoading = false
            hasInitialLoad = true
            initializeFilterRanges()
            return
        }
        
        // Проверяем preloader кэш
        if preloader.isLoaded && !preloader.stations.isEmpty {
            print("📦 Using preloader cache (\(preloader.stations.count) stations)")
            chargingStations = preloader.stations
            cachedStations = preloader.stations
            cacheTimestamp = Date()
            applyFilters()
            isLoading = false
            hasInitialLoad = true
            initializeFilterRanges()
            return
        }
        
        // Загружаем через preloader
        isLoading = true
        
        Task {
            await preloader.preloadStations()
            
            if !preloader.stations.isEmpty {
                print("✅ Loaded from preloader (\(preloader.stations.count) stations)")
                self.chargingStations = preloader.stations
                self.cachedStations = preloader.stations
                self.cacheTimestamp = Date()
                self.applyFilters()
                self.isLoading = false
                self.hasInitialLoad = true
                self.initializeFilterRanges()
            } else if let error = preloader.error {
                print("❌ Preloader failed, falling back to direct load: \(error)")
                self.loadChargingStations()
            } else {
                print("⚠️ Preloader returned empty, trying direct load")
                self.loadChargingStations()
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
        saveFilters()
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
        
        saveFilters()
        
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
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
            cameraPosition = .region(region)
        }
    }
    
    private func updateMapRegionForFiltered() {
        guard let region = calculateRegionForFilteredStations() else { return }
        
        updateCurrentRegion(region)
        
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
            cameraPosition = .region(region)
        }
    }
}

// MARK: - SavedMapPosition Model

struct SavedMapPosition: Codable {
    let latitude: Double
    let longitude: Double
    let latitudeDelta: Double
    let longitudeDelta: Double
}

// MARK: - SavedMapFilters Model

struct SavedMapFilters: Codable {
    let connectorTypes: [String]
    let operators: [String]
    let priceRangeLower: Double
    let priceRangeUpper: Double
    let powerRangeLower: Double
    let powerRangeUpper: Double
}
