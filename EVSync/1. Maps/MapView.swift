//
//  MapView.swift
//  Charge&Go
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
    
    @Binding var presentedStation: ChargingStation?
    @Binding var isStationCardShown: Bool
    
    @Binding var shouldResetMap: Bool
    
    @State private var showingLocationAlert = false
    @State private var locationAlertType: LocationManager.LocationAlertType = .disabled
    @State private var isMapReady = false
    
    init(
        selectedStationFromFavorites: Binding<ChargingStation?>,
        presentedStation: Binding<ChargingStation?> = .constant(nil),
        isStationCardShown: Binding<Bool> = .constant(false),
        shouldResetMap: Binding<Bool> = .constant(false)
    ) {
        _selectedStationFromFavorites = selectedStationFromFavorites
        _presentedStation = presentedStation
        _isStationCardShown = isStationCardShown
        _shouldResetMap = shouldResetMap
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack(alignment: .top) {
                    mapContent
                    MapGradientOverlay()
                    overlaysContent
                    headerContent
                    filterOverlay
                }
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ZoomOutFromStation"))) { _ in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                viewModel.clearSelectedStation()
            }
        }
        .onChange(of: viewModel.selectedConnectorTypes) {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.applyFilters()
            }
        }
        .onChange(of: viewModel.selectedOperators) { _, _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.applyFilters()
            }
        }
        .onChange(of: viewModel.priceRange) { _, _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.applyFilters()
            }
        }
        .onChange(of: viewModel.powerRange) { _, _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.applyFilters()
            }
        }
        .onChange(of: selectedStationFromFavorites) { _, station in
            if let station = station {
                handleFavoriteNavigation(station)
                selectedStationFromFavorites = nil
            }
        }
        .onChange(of: viewModel.chargingStations.count) { oldValue, newValue in
            if oldValue == 0 && newValue > 0 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.applyFilters()
                }
            }
        }
        .onChange(of: shouldResetMap) { _, shouldReset in
            if shouldReset {
                handleMapReset()
                shouldResetMap = false
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
    
    private var mapContent: some View {
        Map(position: $viewModel.cameraPosition) {
            stationAnnotations
            userLocationAnnotation
        }
        .mapStyle(mapStyleForType(viewModel.mapStyle))
        .ignoresSafeArea()
        .onMapCameraChange { context in
            handleMapCameraChange(context)
        }
    }
    
    private var stationAnnotations: some MapContent {
        ForEach(viewModel.visibleStations, id: \.id) { station in
            Annotation("", coordinate: station.coordinate) {
                ChargingStationAnnotation(
                    station: station,
                    isSelected: viewModel.selectedStation?.id == station.id,
                    isFavorite: supabaseManager.favoriteIds.contains(station.id)
                )
                .drawingGroup()
                .scaleEffect(viewModel.selectedStation?.id == station.id ? 1.15 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.selectedStation?.id == station.id)
                .onTapGesture {
                    handleStationTap(station)
                }
            }
        }
    }
    
    @MapContentBuilder
    private var userLocationAnnotation: some MapContent {
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
    
    @ViewBuilder
    private var overlaysContent: some View {
        if viewModel.isLoading && isMapReady {
            LoadingOverlay()
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(1)
        }
        
        if let errorMessage = viewModel.errorMessage {
            ErrorOverlay(message: errorMessage) {
                viewModel.loadChargingStations(forceRefresh: true)
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    
    private var headerContent: some View {
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
            .offset(y: isMapReady ? 0 : -20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: isMapReady)
            
            Spacer()
        }
    }
    
    private var filterOverlay: some View {
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
        .scaleEffect(viewModel.showingFilterOptions ? 1.0 : 0.95)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showingFilterOptions)
        .zIndex(3)
    }
    
    private func handleMapCameraChange(_ context: MapCameraUpdateContext) {
        if !isMapReady {
            withAnimation(.easeOut(duration: 0.5)) {
                isMapReady = true
            }
            return
        }
        
        guard let currentRegion = viewModel.cameraPosition.region else {
            viewModel.updateCurrentRegion(context.region)
            return
        }
        
        let threshold = 0.0001
        let latDiff = abs(context.region.center.latitude - currentRegion.center.latitude)
        let lonDiff = abs(context.region.center.longitude - currentRegion.center.longitude)
        
        guard latDiff > threshold || lonDiff > threshold else { return }
        
        viewModel.updateCurrentRegion(context.region)
    }
    
    private func handleMapReset() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if isStationCardShown {
                isStationCardShown = false
                presentedStation = nil
            }
            
            viewModel.resetToDefaultPosition()
        }
    }
    
    private func handleStationTap(_ station: ChargingStation) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if let currentStation = presentedStation, currentStation.id != station.id {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                viewModel.selectStation(station)
                presentedStation = station
            }
        } else if !isStationCardShown {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                viewModel.selectStation(station)
                presentedStation = station
                isStationCardShown = true
            }
        }
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
                        
                        withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                            viewModel.navigateToStationFromFavorites(station)
                            presentedStation = station
                            isStationCardShown = true
                        }
                    }
                } else {
                    viewModel.loadChargingStations()
                    
                    await MainActor.run {
                        withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                            viewModel.navigateToStationFromFavorites(station)
                            presentedStation = station
                            isStationCardShown = true
                        }
                    }
                }
            }
        } else {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                viewModel.navigateToStationFromFavorites(station)
                presentedStation = station
                isStationCardShown = true
            }
        }
    }
    
    private func handleLocationButtonTap() {
        if let alertType = locationManager.getLocationAlertType() {
            locationAlertType = alertType
            showingLocationAlert = true
            return
        }
        
        if let userLocation = locationManager.userLocation {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
