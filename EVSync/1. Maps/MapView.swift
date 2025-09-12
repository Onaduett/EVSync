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
    @Binding var selectedStationFromFavorites: ChargingStation?
    @State private var mapContentOpacity: Double = 0.0
    @State private var shouldLoadStations = false
    
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
                            mapStyle: $viewModel.mapStyle
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
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showingFilterOptions)
    }
    
    private func startMapInitialization() {
        // Delay the loading and appearance to ensure smooth transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.8)) {
                mapContentOpacity = 1.0
            }
            
            // Start loading stations after the map appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                shouldLoadStations = true
            }
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
