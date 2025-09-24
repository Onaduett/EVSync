//
//  MapView.swift
//  EVSync
//
//  Updated for API integration
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var apiManager = APIManager.shared
    @Binding var selectedStationFromFavorites: ChargingStation?
    @State private var showingLocationAlert = false
    @State private var locationAlertType: LocationManager.LocationAlertType = .disabled
    @State private var isMapReady = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Map(position: $viewModel.cameraPosition) {
                    ForEach(viewModel.filteredStations) { station in
                        Annotation("", coordinate: station.coordinate) {
                            ChargingStationAnnotation(
                                station: station,
                                isSelected: viewModel.selectedStation?.id == station.id,
                                isFavorite: apiManager.favoriteIds.contains(station.id)
                            )
                            .onTapGesture {
                                viewModel.selectStation(station)
                            }
                        }
                    }
                    
                    if let userLocation = locationManager.userLocation, locationManager.isLocationEnabled {
                        Annotation("", coordinate: userLocation) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .shadow(radius: 4)
                        }
                    }
                }
                .mapStyle(mapStyleForType(viewModel.mapStyle))
                .ignoresSafeArea()
                .onMapCameraChange { _ in
                    if !isMapReady {
                        isMapReady = true
                    }
                }
                
                MapGradientOverlay()
                
                if viewModel.isLoading && isMapReady {
                    LoadingOverlay()
                        .transition(.opacity)
                        .zIndex(1)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    ErrorOverlay(message: errorMessage) {
                        viewModel.loadChargingStations(forceRefresh: true)
                    }
                }
                
                VStack {
                    MapHeader(
                        selectedConnectorTypes: viewModel.selectedConnectorTypes,
                        selectedOperators: viewModel.selectedOperators,
                        priceRange: viewModel.priceRange,
                        powerRange: viewModel.powerRange,
                        defaultPriceRange: viewModel.minPrice...viewModel.maxPrice,
                        defaultPowerRange: viewModel.minPower...viewModel.maxPower,
                        showingFilterOptions: $viewModel.showingFilterOptions,
                        mapStyle: $viewModel.mapStyle,
                        onLocationTap: handleLocationButtonTap,
                        locationManager: locationManager,
                        colorScheme: colorScheme
                    )
                    .opacity(isMapReady ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.3), value: isMapReady)
                    
                    Spacer()
                }
                
                // Filter overlay with manual opacity control
                FilterOptionsOverlay(
                    availableTypes: viewModel.availableConnectorTypes,
                    availableOperators: viewModel.availableOperators,
                    selectedTypes: $viewModel.selectedConnectorTypes,
                    selectedOperators: $viewModel.selectedOperators,
                    priceRange: $viewModel.priceRange,
                    powerRange: $viewModel.powerRange,
                    maxPrice: viewModel.maxPrice,
                    maxPower: viewModel.maxPower,
                    minPrice: viewModel.minPrice,
                    minPower: viewModel.minPower,
                    isShowing: $viewModel.showingFilterOptions
                )
                .opacity(viewModel.showingFilterOptions ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.25), value: viewModel.showingFilterOptions)
                
                // Station Detail Card with smooth animations
                if viewModel.selectedStation != nil {
                    VStack {
                        Spacer()
                        
                        StationDetailCard(
                            station: viewModel.selectedStation!,
                            showingDetail: $viewModel.showingStationDetail
                        )
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
                            removal: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95))
                        )
                    )
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.showingStationDetail)
                    .zIndex(2)
                }
            }
        }
        .onAppear {
            startMapInitialization()
            Task {
                await apiManager.syncFavorites()
            }
        }
        .onChange(of: viewModel.selectedConnectorTypes) {
            viewModel.applyFilters()
        }
        .onChange(of: viewModel.selectedOperators) { _, _ in
            viewModel.applyFilters()
        }
        .onChange(of: viewModel.priceRange) { _, _ in
            viewModel.applyFilters()
        }
        .onChange(of: viewModel.powerRange) { _, _ in
            viewModel.applyFilters()
        }
        .onChange(of: selectedStationFromFavorites) { _, station in
            if let station = station {
                handleFavoriteNavigation(station)
                selectedStationFromFavorites = nil
            }
        }
        .alert(locationAlertType.title, isPresented: $showingLocationAlert) {
            Button(locationAlertType.buttonTitle) {
                locationManager.handleLocationAlert(type: locationAlertType)
            }
            Button(LanguageManager().localizedString("cancel"), role: .cancel) { }
        } message: {
            Text(locationAlertType.message)
        }
    }
    
    // MARK: - Private Methods
    
    private func startMapInitialization() {
        Task {
            await MainActor.run {
                viewModel.preloadStations()
            }
        }
        
        if locationManager.isLocationEnabled && (locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways) {
            locationManager.startLocationUpdates()
        }
    }
    
    private func handleFavoriteNavigation(_ station: ChargingStation) {
        if viewModel.chargingStations.isEmpty {
            Task {
                let preloader = StationsPreloader.shared
                if preloader.isLoaded && !preloader.stations.isEmpty {
                    await MainActor.run {
                        viewModel.chargingStations = preloader.stations
                        viewModel.filteredStations = preloader.stations
                        viewModel.isLoading = false
                        viewModel.navigateToStationFromFavorites(station)
                    }
                } else {
                    viewModel.loadChargingStations()
                    
                    await MainActor.run {
                        viewModel.navigateToStationFromFavorites(station)
                    }
                }
            }
        } else {
            viewModel.navigateToStationFromFavorites(station)
        }
    }
    
    private func handleLocationButtonTap() {
        if let alertType = locationManager.getLocationAlertType() {
            locationAlertType = alertType
            showingLocationAlert = true
            return
        }
        
        if let userLocation = locationManager.userLocation {
            viewModel.centerOnUserLocation(userLocation)
        } else {
            locationManager.startLocationUpdates()
        }
    }
    
    private func mapStyleForType(_ mapType: MKMapType) -> MapStyle {
        switch mapType {
        case .satellite:
            return .imagery
        case .hybrid:
            return .hybrid
        default:
            return .standard
        }
    }
}
