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
                                isSelected: viewModel.selectedStation?.id == station.id
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
                
                if viewModel.showingFilterOptions {
                    FilterOptionsOverlay(
                        availableTypes: viewModel.availableConnectorTypes,
                        selectedTypes: $viewModel.selectedConnectorTypes,
                        isShowing: $viewModel.showingFilterOptions
                    )
                }
                
                if viewModel.showingStationDetail, let station = viewModel.selectedStation {
                    VStack {
                        Spacer()
                        StationDetailCard(station: station, showingDetail: $viewModel.showingStationDetail)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.9), value: viewModel.showingStationDetail)
                }
            }
        }
        .onAppear {
            startMapInitialization()
        }
        .onChange(of: viewModel.selectedConnectorTypes) {
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
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.showingFilterOptions)
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
