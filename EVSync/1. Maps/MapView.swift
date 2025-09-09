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
                // Карта занимает весь экран
                Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.filteredStations) { station in
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
                
                // Header с учетом safe area
                if !viewModel.isLoading && viewModel.errorMessage == nil {
                    VStack {
                        MapHeader(
                            selectedConnectorTypes: viewModel.selectedConnectorTypes,
                            showingFilterOptions: $viewModel.showingFilterOptions
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
                
                // Station Detail Card - теперь не нужен дополнительный отступ
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
}

// MARK: - MapViewModel extension
extension MapViewModel {
    func centerMapOnStation(_ station: ChargingStation) {
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(
                center: station.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}
