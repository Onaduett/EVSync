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
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.25552, longitude: 76.930076),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @State private var selectedStation: ChargingStation?
    @State private var showingStationDetail = false
    @State private var chargingStations: [ChargingStation] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://ncuoknogwyjvdikoysfa.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jdW9rbm9nd3lqdmRpa295c2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDU2ODAsImV4cCI6MjA3MTg4MTY4MH0.FwzpAeHXVQWsWuD2jjDZAdMw_anIT0_uFf9P-aAe0zA"
    )
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: $region, annotationItems: chargingStations) { station in
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
            
            // Centered title on map
            if !isLoading && errorMessage == nil {
                VStack {
                    HStack {
                        Spacer()
                        Text("Charge&Go")
                            .font(.custom("Nunito Sans", size: 20).weight(.bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.top, 1)
                    
                    Spacer()
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
}
