//
//  MyCarView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

extension ConnectorType: Codable {}

struct ElectricVehicle: Identifiable, Codable {
    let id: UUID
    let make: String
    let model: String
    let year: Int
    let batteryCapacity: Double // kWh
    let range: Int // km
    let efficiency: Double // kWh/100km
    let supportedChargers: [ConnectorType]
    let maxChargingSpeed: Int // kW
    let image: String
    
    // Custom initializer to generate UUID
    init(make: String, model: String, year: Int, batteryCapacity: Double, range: Int, efficiency: Double, supportedChargers: [ConnectorType], maxChargingSpeed: Int, image: String) {
        self.id = UUID()
        self.make = make
        self.model = model
        self.year = year
        self.batteryCapacity = batteryCapacity
        self.range = range
        self.efficiency = efficiency
        self.supportedChargers = supportedChargers
        self.maxChargingSpeed = maxChargingSpeed
        self.image = image
    }
    
    var displayName: String {
        return "\(year) \(make) \(model)"
    }
}

struct ChargingSession: Identifiable {
    let id = UUID()
    let date: Date
    let location: String
    let energyAdded: Double // kWh
    let cost: Double // ₸
    let duration: TimeInterval // seconds
    let chargingSpeed: Int // kW
}

struct CarStats {
    let totalSessions: Int
    let totalEnergyCharged: Double // kWh
    let totalCost: Double // ₸
    let averageCost: Double // ₸/kWh
    let co2Saved: Double // kg
    let equivalentGasoline: Double // liters
}

struct MyVehicleHeader: View {
    var body: some View {
        HStack {
            Text("Charge&Go")
                .font(.custom("Lexend-SemiBold", size: 20))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text("My Car")
                .font(.custom("Nunito Sans", size: 20).weight(.bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

struct MyCarView: View {
    @AppStorage("selectedCarId") private var selectedCarId: String = ""
    @State private var selectedCar: ElectricVehicle = sampleCars[0]
    @State private var showingCarSelection = false
    @State private var chargingSessions: [ChargingSession] = sampleChargingSessions
    @State private var imageOpacity: Double = 0.0
    
    private var carStats: CarStats {
        calculateStats()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 9) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 50)
                            
                            ZStack {
                                Image(selectedCar.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: geometry.size.width * 0.7) // Make height proportional to screen width
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(12)
                                    .opacity(imageOpacity)
                                    .animation(.easeInOut(duration: 0.8), value: imageOpacity)
                                
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(.systemBackground), location: 0.0),
                                        .init(color: Color(.systemBackground).opacity(0.8), location: 0.1),
                                        .init(color: Color(.systemBackground).opacity(0.5), location: 0.25),
                                        .init(color: Color(.systemBackground).opacity(0.2), location: 0.4),
                                        .init(color: Color.clear, location: 0.6)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(height: geometry.size.width * 0.7) // Same proportional height
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                                .opacity(imageOpacity)
                                .animation(.easeInOut(duration: 0.5), value: imageOpacity)
                            }
                            
                            carInfoCard
                            
                            specificationsSection
                            
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
                
                MyVehicleHeader()
            }
        }
        .onAppear {
            loadSelectedCar()
            withAnimation(.easeInOut(duration: 0.8)) {
                imageOpacity = 1.0
            }
        }
        .onChange(of: selectedCar.id) { _ in
            saveSelectedCar()
            imageOpacity = 0.0
            withAnimation(.easeInOut(duration: 0.8)) {
                imageOpacity = 1.0
            }
        }
        .sheet(isPresented: $showingCarSelection) {
            CarSelectionView(selectedCar: $selectedCar)
        }
    }
    
    // MARK: - Persistence Methods
    private func loadSelectedCar() {
        if !selectedCarId.isEmpty,
           let savedCar = sampleCars.first(where: { $0.id.uuidString == selectedCarId }) {
            selectedCar = savedCar
        }
    }
    
    private func saveSelectedCar() {
        selectedCarId = selectedCar.id.uuidString
    }
    
    // MARK: - Car Info Card
    private var carInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: {
                showingCarSelection = true
            }) {
                HStack(spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedCar.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        

                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.05))
        )
    }
    
    // MARK: - Specifications Section (moved to bottom)
    private var specificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Technical Specifications
            VStack(alignment: .leading, spacing: 12) {
                Text("Specifications")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    SpecificationItem(
                        icon: "battery.100",
                        title: "Battery Capacity",
                        value: "\(Int(selectedCar.batteryCapacity)) kWh",
                        iconColor: .teal
                    )
                    
                    SpecificationItem(
                        icon: "speedometer",
                        title: "Efficiency",
                        value: String(format: "%.1f kWh/100km", selectedCar.efficiency),
                        iconColor: .teal
                    )
                    
                    SpecificationItem(
                        icon: "bolt.fill",
                        title: "Max Charging",
                        value: "\(selectedCar.maxChargingSpeed) kW",
                        iconColor: .green
                    )
                    
                    SpecificationItem(
                        icon: "road.lanes",
                        title: "Range",
                        value: "\(selectedCar.range) km",
                        iconColor: .green
                    )
                }
            }
            
            Divider()
            
            // Supported Chargers
            VStack(alignment: .leading, spacing: 12) {
                Text("Compatible Connectors")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(selectedCar.supportedChargers, id: \.self) { connector in
                        HStack {
                            Image(connector.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.blue)
                            Text(connector.rawValue)
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.05))
        )
    }
    
    private func calculateStats() -> CarStats {
        let totalSessions = chargingSessions.count
        let totalEnergy = chargingSessions.reduce(0) { $0 + $1.energyAdded }
        let totalCost = chargingSessions.reduce(0) { $0 + $1.cost }
        let averageCost = totalEnergy > 0 ? totalCost / totalEnergy : 0
        
        // CO2 savings: ~0.5 kg CO2 per kWh vs gasoline equivalent
        let co2Saved = totalEnergy * 0.5
        
        // Gasoline equivalent: ~2.3 kWh per liter of gasoline
        let equivalentGas = totalEnergy / 2.3
        
        return CarStats(
            totalSessions: totalSessions,
            totalEnergyCharged: totalEnergy,
            totalCost: totalCost,
            averageCost: averageCost,
            co2Saved: co2Saved,
            equivalentGasoline: equivalentGas
        )
    }
}

// MARK: - Supporting Views
struct SpecificationItem: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

struct ChargingTimeEstimate: View {
    let power: Int
    let time: String
    let type: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(power) kW")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(time)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(type)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(radius: 4, x: 0, y: 2)
        )
    }
}

struct ChargingSessionRow: View {
    let session: ChargingSession
    
    var body: some View {
        HStack(spacing: 12) {
            // Date and time
            VStack(alignment: .leading, spacing: 2) {
                Text(session.date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(session.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Location
            VStack(alignment: .trailing, spacing: 2) {
                Text(session.location)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text("\(String(format: "%.1f", session.energyAdded)) kWh")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Cost
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(session.cost)) ₸")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("\(session.chargingSpeed) kW")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

struct EnvironmentalStat: View {
    let icon: String
    let title: String
    let value: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green.opacity(0.1))
        )
    }
}

// MARK: - Car Selection View
struct CarSelectionView: View {
    @Binding var selectedCar: ElectricVehicle
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(sampleCars) { car in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "car.side.fill")
                                .foregroundColor(.blue)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(car.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(car.range) km range • \(Int(car.batteryCapacity)) kWh")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if selectedCar.id == car.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCar = car
                    dismiss()
                }
            }
            .navigationTitle("Select Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
