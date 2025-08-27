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

// MARK: - Main MyCarView
struct MyCarView: View {
    @State private var selectedCar: ElectricVehicle = sampleCars[0]
    @State private var currentBatteryLevel: Double = 75.0 // percentage
    @State private var showingCarSelection = false
    @State private var showingChargingHistory = false
    @State private var chargingSessions: [ChargingSession] = sampleChargingSessions
    
    private var carStats: CarStats {
        calculateStats()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Car Info Card
                carInfoCard
                
                // Battery Status
                batteryStatusCard
                
                // Quick Stats
                quickStatsGrid
                
                // Charging History
                chargingHistorySection
                
                // Environmental Impact
                environmentalImpactCard
                
                Spacer(minLength: 100) // Space for navigation bar
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(isPresented: $showingCarSelection) {
            CarSelectionView(selectedCar: $selectedCar)
        }
        .sheet(isPresented: $showingChargingHistory) {
            ChargingHistoryView(sessions: chargingSessions)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Vehicle")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Manage your EV")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                showingCarSelection = true
            }) {
                Image(systemName: "car.2")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Car Info Card
    private var carInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Car Image and Basic Info
            HStack(spacing: 16) {
                // Car illustration
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "car.side.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedCar.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Electric Vehicle")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        Label("\(selectedCar.range) km", systemImage: "gauge.with.dots.needle.bottom.100percent")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Label("\(Int(selectedCar.batteryCapacity)) kWh", systemImage: "battery.100")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
            }
            
            Divider()
            
            // Technical Specifications
            VStack(alignment: .leading, spacing: 12) {
                Text("Specifications")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    SpecificationItem(
                        icon: "battery.100",
                        title: "Battery Capacity",
                        value: "\(Int(selectedCar.batteryCapacity)) kWh"
                    )
                    
                    SpecificationItem(
                        icon: "speedometer",
                        title: "Efficiency",
                        value: String(format: "%.1f kWh/100km", selectedCar.efficiency)
                    )
                    
                    SpecificationItem(
                        icon: "bolt.fill",
                        title: "Max Charging",
                        value: "\(selectedCar.maxChargingSpeed) kW"
                    )
                    
                    SpecificationItem(
                        icon: "road.lanes",
                        title: "Range",
                        value: "\(selectedCar.range) km"
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
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Battery Status Card
    private var batteryStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Battery Status")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(currentBatteryLevel))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(batteryColor)
            }
            
            // Battery visualization
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 24)
                    
                    // Battery level
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            colors: [batteryColor.opacity(0.8), batteryColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * (currentBatteryLevel / 100), height: 24)
                        .animation(.easeInOut(duration: 0.3), value: currentBatteryLevel)
                    
                    // Battery level text
                    HStack {
                        Spacer()
                        Text("\(Int(currentBatteryLevel))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
            }
            .frame(height: 24)
            
            // Range and charging info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estimated Range")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(Double(selectedCar.range) * (currentBatteryLevel / 100))) km")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Energy Available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f kWh", selectedCar.batteryCapacity * (currentBatteryLevel / 100)))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            // Charging time estimates
            if currentBatteryLevel < 100 {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Charging Time to 100%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        ChargingTimeEstimate(
                            power: 7,
                            time: calculateChargingTime(to: 100, at: 7),
                            type: "Home"
                        )
                        
                        ChargingTimeEstimate(
                            power: 50,
                            time: calculateChargingTime(to: 100, at: 50),
                            type: "Fast"
                        )
                        
                        ChargingTimeEstimate(
                            power: selectedCar.maxChargingSpeed,
                            time: calculateChargingTime(to: 100, at: selectedCar.maxChargingSpeed),
                            type: "Ultra"
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Quick Stats Grid
    private var quickStatsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            StatCard(
                icon: "bolt.fill",
                title: "Total Sessions",
                value: "\(carStats.totalSessions)",
                color: .blue
            )
            
            StatCard(
                icon: "battery.100",
                title: "Energy Charged",
                value: String(format: "%.0f kWh", carStats.totalEnergyCharged),
                color: .green
            )
            
            StatCard(
                icon: "tenge.circle.fill",
                title: "Total Cost",
                value: String(format: "%.0f ₸", carStats.totalCost),
                color: .orange
            )
            
            StatCard(
                icon: "leaf.fill",
                title: "CO₂ Saved",
                value: String(format: "%.0f kg", carStats.co2Saved),
                color: .mint
            )
        }
    }
    
    // MARK: - Charging History Section
    private var chargingHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Charging")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("View All") {
                    showingChargingHistory = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(chargingSessions.prefix(3)) { session in
                    ChargingSessionRow(session: session)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Environmental Impact Card
    private var environmentalImpactCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Environmental Impact")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                EnvironmentalStat(
                    icon: "cloud.slash.fill",
                    title: "CO₂ Emissions Avoided",
                    value: String(format: "%.0f kg", carStats.co2Saved),
                    description: "vs gasoline equivalent"
                )
                
                EnvironmentalStat(
                    icon: "fuelpump.slash.fill",
                    title: "Gasoline Equivalent Saved",
                    value: String(format: "%.0f L", carStats.equivalentGasoline),
                    description: "based on average consumption"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [Color.green.opacity(0.1), Color.mint.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Helper Properties
    private var batteryColor: Color {
        switch currentBatteryLevel {
        case 0..<20: return .red
        case 20..<50: return .orange
        case 50..<80: return .yellow
        default: return .green
        }
    }
    
    // MARK: - Helper Functions
    private func calculateChargingTime(to targetLevel: Double, at power: Int) -> String {
        let energyNeeded = selectedCar.batteryCapacity * ((targetLevel - currentBatteryLevel) / 100)
        let hours = energyNeeded / Double(power)
        
        if hours < 1 {
            return "\(Int(hours * 60))min"
        } else {
            let h = Int(hours)
            let m = Int((hours - Double(h)) * 60)
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
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
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
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

// MARK: - Charging History View
struct ChargingHistoryView: View {
    let sessions: [ChargingSession]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(sessions) { session in
                ChargingSessionRow(session: session)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Charging History")
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

// MARK: - Sample Data
let sampleCars: [ElectricVehicle] = [
    ElectricVehicle(
        make: "Tesla",
        model: "Model 3",
        year: 2023,
        batteryCapacity: 75.0,
        range: 448,
        efficiency: 14.3,
        supportedChargers: [.ccs, .tesla],
        maxChargingSpeed: 250,
        image: "tesla_model3"
    ),
    ElectricVehicle(
        make: "BYD",
        model: "Seal",
        year: 2024,
        batteryCapacity: 82.5,
        range: 570,
        efficiency: 14.5,
        supportedChargers: [.ccs, .type2],
        maxChargingSpeed: 150,
        image: "byd_seal"
    ),
    ElectricVehicle(
        make: "Hyundai",
        model: "IONIQ 5",
        year: 2023,
        batteryCapacity: 72.6,
        range: 481,
        efficiency: 15.1,
        supportedChargers: [.ccs, .type2],
        maxChargingSpeed: 233,
        image: "ioniq5"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "iX3",
        year: 2023,
        batteryCapacity: 80.0,
        range: 460,
        efficiency: 17.4,
        supportedChargers: [.ccs, .type2],
        maxChargingSpeed: 150,
        image: "bmw_ix3"
    )
]

let sampleChargingSessions: [ChargingSession] = [
    ChargingSession(
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
        location: "Mega Mall Almaty",
        energyAdded: 45.2,
        cost: 2260,
        duration: 2400, // 40 minutes
        chargingSpeed: 50
    ),
    ChargingSession(
        date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
        location: "Dostyk Plaza",
        energyAdded: 32.1,
        cost: 1605,
        duration: 1800, // 30 minutes
        chargingSpeed: 75
    ),
    ChargingSession(
        date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
        location: "APORT Mall",
        energyAdded: 38.7,
        cost: 1935,
        duration: 2100, // 35 minutes
        chargingSpeed: 60
    ),
    ChargingSession(
        date: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
        location: "Almaty Mall",
        energyAdded: 41.5,
        cost: 2075,
        duration: 2700, // 45 minutes
        chargingSpeed: 50
    ),
    ChargingSession(
        date: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date(),
        location: "Esentai Mall",
        energyAdded: 52.3,
        cost: 2615,
        duration: 3000, // 50 minutes
        chargingSpeed: 65
    )
]
