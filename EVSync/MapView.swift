//
//  MapView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI
import MapKit
import Supabase

// MARK: - Database Models
struct DatabaseChargingStation: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let connector_types: [String]
    let power_kw: Int?
    let is_available: Bool
    let price_per_kwh: Double?
    let station_operator: String? // Changed from 'operator' to 'station_operator'
    let created_at: String
    let updated_at: String
    
    // Convert to UI model
    func toChargingStation() -> ChargingStation {
        let connectorTypes = connector_types.compactMap { ConnectorType(rawValue: $0) }
        let availability: StationAvailability = is_available ? .available : .occupied
        
        return ChargingStation(
            id: id,
            name: name,
            address: address,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            connectorTypes: connectorTypes,
            availability: availability,
            power: power_kw != nil ? "\(power_kw!) kW" : "Unknown",
            price: price_per_kwh != nil ? String(format: "%.1f ₸/kWh", price_per_kwh!) : "Contact for pricing",
            amenities: generateAmenities(),
            operatingHours: "24/7", // Default since not in DB
            phoneNumber: nil, // Not in current DB schema
            provider: station_operator ?? "EVSync Network" // Fixed: using station_operator instead of operator
        )
    }
    
    private func generateAmenities() -> [String] {
        var amenities = ["EV Charging"]
        
        // Add amenities based on location name/address
        if name.lowercased().contains("mall") || address.lowercased().contains("mall") {
            amenities.append(contentsOf: ["Shopping Mall", "Restaurant", "WiFi"])
        }
        if name.lowercased().contains("airport") || address.lowercased().contains("airport") {
            amenities.append(contentsOf: ["Airport", "24h Service"])
        }
        if name.lowercased().contains("park") {
            amenities.append("Parking")
        }
        if power_kw != nil && power_kw! >= 100 {
            amenities.append("Fast Charging")
        }
        
        return amenities
    }
}

// Alternative approach if you cannot change the database column name:
// Use CodingKeys to map the 'operator' database field to a different property name
/*
struct DatabaseChargingStation: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let connector_types: [String]
    let power_kw: Int?
    let is_available: Bool
    let price_per_kwh: Double?
    let stationOperator: String? // Different property name
    let created_at: String
    let updated_at: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, latitude, longitude, connector_types, power_kw, is_available, price_per_kwh, created_at, updated_at
        case stationOperator = "operator" // Map database 'operator' field to 'stationOperator' property
    }
    
    // Then use stationOperator in your conversion method
    func toChargingStation() -> ChargingStation {
        // ... other code ...
        return ChargingStation(
            // ... other parameters ...
            provider: stationOperator ?? "EVSync Network"
        )
    }
}
*/

// MARK: - Charging Station UI Model
struct ChargingStation: Identifiable, Equatable {
    let id: UUID
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let connectorTypes: [ConnectorType]
    let availability: StationAvailability
    let power: String
    let price: String
    let amenities: [String]
    let operatingHours: String
    let phoneNumber: String?
    let provider: String
    
    // Equatable conformance
    static func == (lhs: ChargingStation, rhs: ChargingStation) -> Bool {
        return lhs.id == rhs.id
    }
}

enum ConnectorType: String, CaseIterable {
    case ccs = "CCS"
    case chademo = "CHAdeMO"
    case type2 = "Type2"
    case tesla = "Tesla"
    
    var icon: String {
        switch self {
        case .ccs: return "bolt.car"
        case .chademo: return "bolt.car.fill"
        case .type2: return "car.2"
        case .tesla: return "bolt.slash"
        }
    }
}

enum StationAvailability: String, CaseIterable {
    case available = "Available"
    case occupied = "Occupied"
    case outOfService = "Out of Service"
    case maintenance = "Maintenance"
    
    var color: Color {
        switch self {
        case .available: return .green
        case .occupied: return .orange
        case .outOfService: return .red
        case .maintenance: return .yellow
        }
    }
}

// MARK: - Custom Map Annotation
struct ChargingStationAnnotation: View {
    let station: ChargingStation
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(station.availability.color)
                .frame(width: isSelected ? 24 : 20, height: isSelected ? 24 : 20)
                .shadow(radius: isSelected ? 6 : 3)
            
            Image(systemName: "bolt.fill")
                .foregroundColor(.white)
                .font(.system(size: isSelected ? 14 : 12, weight: .bold))
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Station Detail Card
struct StationDetailCard: View {
    let station: ChargingStation
    @Binding var showingDetail: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(station.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(station.provider)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingDetail = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Status Badge
            HStack {
                Circle()
                    .fill(station.availability.color)
                    .frame(width: 12, height: 12)
                
                Text(station.availability.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(station.availability.color)
                
                Spacer()
            }
            
            Divider()
            
            // Station Info
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(icon: "location", title: "Address", value: station.address)
                InfoRow(icon: "clock", title: "Hours", value: station.operatingHours)
                InfoRow(icon: "bolt", title: "Power", value: station.power)
                InfoRow(icon: "tenge.circle", title: "Price", value: station.price)
                
                if let phone = station.phoneNumber {
                    InfoRow(icon: "phone", title: "Phone", value: phone)
                }
            }
            
            Divider()
            
            // Connector Types
            VStack(alignment: .leading, spacing: 8) {
                Text("Connector Types")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(station.connectorTypes, id: \.self) { connector in
                        HStack {
                            Image(systemName: connector.icon)
                                .foregroundColor(.blue)
                            Text(connector.rawValue)
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
            }
            
            Divider()
            
            // Amenities
            if !station.amenities.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amenities")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 6) {
                        ForEach(station.amenities, id: \.self) { amenity in
                            Text(amenity)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Divider()
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    // Navigate to station
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Navigate")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                
                Button(action: {
                    // Call station
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(25)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.subheadline)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Main MapView
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
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        loadChargingStations()
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .padding()
            }
            
            // Header with glassmorphism effect
            if !isLoading && errorMessage == nil {
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("EV Charging Stations")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("\(chargingStations.count) stations nearby")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Refresh button
                        Button(action: {
                            loadChargingStations()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        // Filter/Search button
                        Button(action: {
                            // Add filter functionality
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
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
