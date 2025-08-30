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
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.25552, longitude: 76.930076),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @State private var selectedStation: ChargingStation?
    @State private var showingStationDetail = false
    @State private var chargingStations: [ChargingStation] = []
    @State private var filteredStations: [ChargingStation] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingFilterOptions = false
    @State private var selectedConnectorTypes: Set<ConnectorType> = []
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://ncuoknogwyjvdikoysfa.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jdW9rbm9nd3lqdmRpa295c2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDU2ODAsImV4cCI6MjA3MTg4MTY4MH0.FwzpAeHXVQWsWuD2jjDZAdMw_anIT0_uFf9P-aAe0zA"
    )
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: $region, annotationItems: filteredStations) { station in
                MapAnnotation(coordinate: station.coordinate) {
                    ChargingStationAnnotation(
                        station: station,
                        isSelected: selectedStation?.id == station.id
                    )
                    .onTapGesture {
                        selectedStation = station
                        showingStationDetail = true
                        
                        // Animate to selected station
                        withAnimation(.easeInOut(duration: 0.5)) {
                            region.center = station.coordinate
                        }
                    }
                }
            }
            .ignoresSafeArea()
            
            // Top gradient overlay
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: colorScheme == .dark ? .black : .white, location: 0.0),
                    .init(color: colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5), location: 0.3),
                    .init(color: .clear, location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .ignoresSafeArea(edges: .top)
            
            // Loading overlay
            if isLoading {
                VStack {
                    ProgressView("Loading charging stations...")
                        .font(.custom("Nunito Sans", size: 16))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.3))
            }
            
            // Error overlay
            if let errorMessage = errorMessage {
                VStack {
                    Text("Error")
                        .font(.custom("Nunito Sans", size: 18).weight(.bold))
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.custom("Nunito Sans", size: 14))
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        loadChargingStations()
                    }
                    .font(.custom("Nunito Sans", size: 16))
                    .padding(.top, 8)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .padding()
            }
            
            // Header with title and filter button
            if !isLoading && errorMessage == nil {
                VStack {
                    ZStack {
                        // Centered title
                        HStack {
                            Spacer()
                            Text("Charge&Go")
                                .font(.custom("Nunito Sans", size: 20).weight(.bold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                        }
                        
                        // Filter button aligned to trailing edge
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showingFilterOptions.toggle()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .font(.system(size: 18))
                                    if !selectedConnectorTypes.isEmpty {
                                        Text("\(selectedConnectorTypes.count)")
                                            .font(.custom("Nunito Sans", size: 12).weight(.semibold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .clipShape(Circle())
                                    }
                                }
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                )
                            }
                            .padding(.trailing, 16)
                        }
                    }
                    .padding(.top, 0)
                    
                }
            }
            
            // Filter options sheet
            if showingFilterOptions {
                VStack {
                    FilterOptionsView(
                        availableTypes: availableConnectorTypes,
                        selectedTypes: $selectedConnectorTypes,
                        isShowing: $showingFilterOptions
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                }
                .background(Color.black.opacity(0.3))
                .onTapGesture {
                    showingFilterOptions = false
                }
            }
            
            // Station Detail Card
            if showingStationDetail, let station = selectedStation {
                VStack {
                    Spacer()
                    StationDetailCard(station: station, showingDetail: $showingStationDetail)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingStationDetail)
            }
        }
        .onAppear {
            loadChargingStations()
        }
        .onChange(of: selectedConnectorTypes) { _ in
            applyFilters()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingFilterOptions)
    }
    
    // MARK: - Computed Properties
    private var availableConnectorTypes: [ConnectorType] {
        let allTypes = chargingStations.flatMap { $0.connectorTypes }
        return Array(Set(allTypes)).sorted { $0.rawValue < $1.rawValue }
    }
    
    // MARK: - Data Loading
    private func loadChargingStations() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response: [DatabaseChargingStation] = try await supabase.database
                    .from("charging_stations")
                    .select()
                    .execute()
                    .value
                
                await MainActor.run {
                    self.chargingStations = response.map { $0.toChargingStation() }
                    self.filteredStations = self.chargingStations
                    self.isLoading = false
                    
                    // Update map region to show all stations
                    if !chargingStations.isEmpty {
                        updateMapRegion()
                    }
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load charging stations: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func applyFilters() {
        if selectedConnectorTypes.isEmpty {
            filteredStations = chargingStations
        } else {
            filteredStations = chargingStations.filter { station in
                return !Set(station.connectorTypes).isDisjoint(with: selectedConnectorTypes)
            }
        }
        
        // Update map region for filtered stations
        if !filteredStations.isEmpty {
            updateMapRegionForFiltered()
        }
    }
    
    private func updateMapRegion() {
        let coordinates = chargingStations.map { $0.coordinate }
        guard !coordinates.isEmpty else { return }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? 43.0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 44.0
        let minLon = coordinates.map { $0.longitude }.min() ?? 76.0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 78.0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat + 0.02, 0.05),
            longitudeDelta: max(maxLon - minLon + 0.02, 0.05)
        )
        
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(center: center, span: span)
        }
    }
    
    private func updateMapRegionForFiltered() {
        let coordinates = filteredStations.map { $0.coordinate }
        guard !coordinates.isEmpty else { return }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? 43.0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 44.0
        let minLon = coordinates.map { $0.longitude }.min() ?? 76.0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 78.0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat + 0.02, 0.05),
            longitudeDelta: max(maxLon - minLon + 0.02, 0.05)
        )
        
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(center: center, span: span)
        }
    }
}

// MARK: - Filter Options View
struct FilterOptionsView: View {
    @Environment(\.colorScheme) var colorScheme
    let availableTypes: [ConnectorType]
    @Binding var selectedTypes: Set<ConnectorType>
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Filter by Connector Type")
                    .font(.custom("Nunito Sans", size: 18).weight(.bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                Button("Clear All") {
                    selectedTypes.removeAll()
                }
                .font(.custom("Nunito Sans", size: 14).weight(.medium))
                .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(availableTypes, id: \.self) { type in
                    Button(action: {
                        if selectedTypes.contains(type) {
                            selectedTypes.remove(type)
                        } else {
                            selectedTypes.insert(type)
                        }
                    }) {
                        HStack {
                            Image(systemName: selectedTypes.contains(type) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedTypes.contains(type) ? .blue : .gray)
                            
                            Text(type.displayName)
                                .font(.custom("Nunito Sans", size: 14))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTypes.contains(type) ?
                                      Color.blue.opacity(0.1) :
                                      (colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTypes.contains(type) ? Color.blue : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            HStack {
                Button("Cancel") {
                    isShowing = false
                }
                .font(.custom("Nunito Sans", size: 16))
                .foregroundColor(.gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                )
                
                Spacer()
                
                Button("Apply") {
                    isShowing = false
                }
                .font(.custom("Nunito Sans", size: 16).weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 16)
        .padding(.top, 100)
    }
}
