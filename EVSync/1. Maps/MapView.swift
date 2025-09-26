//
//  MapView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI
import MapKit
import Supabase

struct MapView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var supabaseManager = SupabaseManager.shared
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
                                isFavorite: supabaseManager.favoriteIds.contains(station.id)
                            )
                            .onTapGesture {
                                handleStationTap(station)
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
                
                // Карточка станции - упрощенная логика отображения
                if let selectedStation = viewModel.selectedStation {
                    VStack {
                        Spacer()
                        
                        StationDetailCard(
                            station: selectedStation,
                            showingDetail: .constant(true),
                            onClose: {
                                viewModel.clearSelectedStation()
                            }
                        )
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.selectedStation?.id)
                    .zIndex(2)
                }
                
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
                .zIndex(3)
            }
        }
        .onAppear {
            startMapInitialization()
            
            Task { @MainActor in
                while !isMapReady {
                    try? await Task.sleep(nanoseconds: 50_000_000)
                }
                try? await Task.sleep(nanoseconds: 200_000_000)
                await supabaseManager.syncFavorites()
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
        // Отладочные onChange для диагностики
        .onChange(of: viewModel.selectedStation) { oldValue, newValue in
            print("🚉 selectedStation changed from \(oldValue?.name ?? "nil") to \(newValue?.name ?? "nil")")
        }
        .onChange(of: viewModel.showingStationDetail) { oldValue, newValue in
            print("📱 showingStationDetail changed from \(oldValue) to \(newValue)")
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
    
    private func handleStationTap(_ station: ChargingStation) {
        print("🎯 Tapped on station: \(station.name)")
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Простой вызов без сложной логики
        viewModel.selectStation(station)
    }
    
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
