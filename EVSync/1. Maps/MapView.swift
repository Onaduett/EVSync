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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Map with dynamic style
                Map(coordinateRegion: $viewModel.region,
                    interactionModes: .all,
                    annotationItems: viewModel.filteredStations) { station in
                    MapAnnotation(coordinate: station.coordinate) {
                        ChargingStationAnnotation(
                            station: station,
                            isSelected: viewModel.selectedStation?.id == station.id
                        )
                        .onTapGesture {
                            viewModel.selectStation(station)
                        }
                    }
                }
                .mapStyle(mapStyleForType(viewModel.mapStyle))
                .ignoresSafeArea()
                
                MapGradientOverlay()
                
                if viewModel.isLoading {
                    LoadingOverlay()
                }
                
                // Error overlay
                if let errorMessage = viewModel.errorMessage {
                    ErrorOverlay(message: errorMessage) {
                        viewModel.loadChargingStations()
                    }
                }
                
                // Header with new layout: Filter left, Theme toggle right
                if !viewModel.isLoading && viewModel.errorMessage == nil {
                    VStack {
                        MapHeader(
                            selectedConnectorTypes: viewModel.selectedConnectorTypes,
                            showingFilterOptions: $viewModel.showingFilterOptions,
                            mapStyle: $viewModel.mapStyle
                        )
                        Spacer()
                    }
                }
                
                // Filter options sheet
                if viewModel.showingFilterOptions {
                    FilterOptionsOverlay(
                        availableTypes: viewModel.availableConnectorTypes,
                        selectedTypes: $viewModel.selectedConnectorTypes,
                        isShowing: $viewModel.showingFilterOptions
                    )
                }
                
                // Station Detail Card
                if viewModel.showingStationDetail, let station = viewModel.selectedStation {
                    VStack {
                        Spacer()
                        StationDetailCard(station: station, showingDetail: $viewModel.showingStationDetail)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.showingStationDetail)
                }
            }
        }
        .onAppear {
            viewModel.loadChargingStations()
        }
        .onChange(of: viewModel.selectedConnectorTypes) { _ in
            viewModel.applyFilters()
        }
        .onChange(of: selectedStationFromFavorites) { station in
            if let station = station {
                viewModel.centerMapOnStation(station)
                viewModel.selectStation(station)
                selectedStationFromFavorites = nil
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showingFilterOptions)
    }
    
    // Helper function to get the correct map style
    private var mapStyleForType: (MKMapType) -> MapStyle {
        return { mapType in
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
}
