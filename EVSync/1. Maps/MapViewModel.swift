//
//  MapViewModel.swift
//  EVSync
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
    @Published var isLoading = false // Изменено на false по умолчанию
    @Published var errorMessage: String?
    @Published var showingFilterOptions = false
    @Published var selectedConnectorTypes: Set<ConnectorType> = []
    @Published var mapStyle: MKMapType = .standard
    
    private let almatyCenter = CLLocationCoordinate2D(latitude: 43.25552, longitude: 76.930076)
    private let almatySpan = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    private var hasInitialLoad = false
    
    private var cachedStations: [ChargingStation] = []
    private var cacheTimestamp: Date?
    private let cacheExpirationTime: TimeInterval = 300 // 5 минут
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://ncuoknogwyjvdikoysfa.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jdW9rbm9nd3lqdmRpa295c2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDU2ODAsImV4cCI6MjA3MTg4MTY4MH0.FwzpAeHXVQWsWuD2jjDZAdMw_anIT0_uFf9P-aAe0zA"
    )
    
    var availableConnectorTypes: [ConnectorType] {
        let allTypes = chargingStations.flatMap { $0.connectorTypes }
        return Array(Set(allTypes)).sorted { $0.rawValue < $1.rawValue }
    }
    
    // MARK: - Public Methods
    
    func selectStation(_ station: ChargingStation) {
        selectedStation = station
        showingStationDetail = true
        centerMapOnStation(station)
    }
    
    func centerMapOnStation(_ station: ChargingStation) {
        let newRegion = MKCoordinateRegion(
            center: station.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        
        withAnimation(.easeInOut(duration: 1.0)) {
            cameraPosition = .region(newRegion)
        }
    }
    
    func centerOnUserLocation(_ userLocation: CLLocationCoordinate2D) {
        let newRegion = MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        withAnimation(.easeInOut(duration: 1.0)) {
            cameraPosition = .region(newRegion)
        }
    }
    
    // MARK: - Data Loading
    
    func loadChargingStations(forceRefresh: Bool = false) {
        if !forceRefresh && isCacheValid() {
            chargingStations = cachedStations
            filteredStations = chargingStations
            isLoading = false
            
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
                
                // Обновляем кеш
                self.cachedStations = loadedStations
                self.cacheTimestamp = Date()
                
                self.chargingStations = loadedStations
                self.filteredStations = loadedStations
                self.isLoading = false

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
        let newRegion = MKCoordinateRegion(
            center: station.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        cameraPosition = .region(newRegion)
        
        let stationToShow = chargingStations.first(where: { $0.id == station.id }) ?? station
        
        selectedStation = stationToShow
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
        // Сначала проверяем preloader
        let preloader = StationsPreloader.shared
        
        if preloader.isLoaded && !preloader.stations.isEmpty {
            // Если данные уже загружены в preloader - используем их
            chargingStations = preloader.stations
            filteredStations = chargingStations
            isLoading = false
            hasInitialLoad = true
            return
        }
        
        // Если есть кеш - используем его
        if isCacheValid() {
            chargingStations = cachedStations
            filteredStations = chargingStations
            isLoading = false
            hasInitialLoad = true
            return
        }
        
        // Запускаем preloader асинхронно
        Task {
            preloader.preloadStations()
            
            // Ждем загрузки или используем обычный способ
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
                }
            }
        }
    }
    
    // MARK: - Filtering
    
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
            cameraPosition = .region(
                MKCoordinateRegion(center: almatyCenter, span: almatySpan)
            )
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
            cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
}
