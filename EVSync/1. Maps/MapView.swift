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
    @State private var mapContentOpacity: Double = 0.0
    @State private var shouldLoadStations = false
    @State private var showingLocationAlert = false
    @State private var locationAlertType: LocationManager.LocationAlertType = .disabled
    
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
                    
                    // User location annotation - no title
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
                .opacity(mapContentOpacity)
                
                MapGradientOverlay()
                    .opacity(mapContentOpacity)
                
                if viewModel.isLoading {
                    LoadingOverlay()
                        .opacity(mapContentOpacity)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    ErrorOverlay(message: errorMessage) {
                        viewModel.loadChargingStations()
                    }
                    .opacity(mapContentOpacity)
                }
                
                if !viewModel.isLoading && viewModel.errorMessage == nil {
                    VStack {
                        MapHeader(
                            selectedConnectorTypes: viewModel.selectedConnectorTypes,
                            showingFilterOptions: $viewModel.showingFilterOptions,
                            mapStyle: $viewModel.mapStyle,
                            onLocationTap: handleLocationButtonTap,
                            locationManager: locationManager,
                            colorScheme: colorScheme
                        )
                        Spacer()
                    }
                    .opacity(mapContentOpacity)
                }
                
                if viewModel.showingFilterOptions {
                    FilterOptionsOverlay(
                        availableTypes: viewModel.availableConnectorTypes,
                        selectedTypes: $viewModel.selectedConnectorTypes,
                        isShowing: $viewModel.showingFilterOptions
                    )
                    .opacity(mapContentOpacity)
                }
                
                if viewModel.showingStationDetail, let station = viewModel.selectedStation {
                    VStack {
                        Spacer()
                        StationDetailCard(station: station, showingDetail: $viewModel.showingStationDetail)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.showingStationDetail)
                    .opacity(mapContentOpacity)
                }
            }
        }
        .onAppear {
            startMapInitialization()
        }
        .onChange(of: shouldLoadStations) { _, shouldLoad in
            if shouldLoad {
                viewModel.loadChargingStations()
            }
        }
        .onChange(of: viewModel.selectedConnectorTypes) {
            viewModel.applyFilters()
        }
        .onChange(of: selectedStationFromFavorites) { _, station in
            if let station = station {
                viewModel.centerMapOnStation(station)
                viewModel.selectStation(station)
                selectedStationFromFavorites = nil
            }
        }
        .alert(locationAlertType.title, isPresented: $showingLocationAlert) {
            Button(locationAlertType.buttonTitle) {
                locationManager.handleLocationAlert(type: locationAlertType)
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text(locationAlertType.message)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showingFilterOptions)
    }
    
    // MARK: - Private Methods
    
    private func startMapInitialization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.8)) {
                mapContentOpacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                shouldLoadStations = true
            }
        }
        
        if locationManager.isLocationEnabled && (locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways) {
            locationManager.startLocationUpdates()
        }
    }
    
    private func handleLocationButtonTap() {
        if let alertType = locationManager.getLocationAlertType() {
            locationAlertType = alertType
            showingLocationAlert = true
            return
        }
        
        // If user location is available, center on it
        if let userLocation = locationManager.userLocation {
            viewModel.centerOnUserLocation(userLocation)
        } else {
            // Otherwise, start location updates
            locationManager.startLocationUpdates()
        }
    }
    
    // Helper function to get the correct map style
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
