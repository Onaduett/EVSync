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
    // ПРЕМИУМ СЕДАНЫ
    ElectricVehicle(
        make: "Tesla",
        model: "Model 3",
        year: 2023,
        batteryCapacity: 75.0,
        range: 448,
        efficiency: 14.3,
        supportedChargers: [.ccs2, .tesla, .type2], // Tesla поддерживает свои + стандартные через адаптер
        maxChargingSpeed: 250,
        image: "tesla_model3"
    ),
    ElectricVehicle(
        make: "Tesla",
        model: "Model S",
        year: 2024,
        batteryCapacity: 100.0,
        range: 652,
        efficiency: 15.3,
        supportedChargers: [.ccs2, .tesla, .type2],
        maxChargingSpeed: 250,
        image: "tesla_models"
    ),
    ElectricVehicle(
        make: "Mercedes",
        model: "EQS",
        year: 2024,
        batteryCapacity: 107.8,
        range: 770,
        efficiency: 14.0,
        supportedChargers: [.ccs2, .type2], // Европейские стандарты + бытовая розетка
        maxChargingSpeed: 200,
        image: "mercedes_eqs"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "iX",
        year: 2024,
        batteryCapacity: 111.5,
        range: 630,
        efficiency: 17.7,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 195,
        image: "bmw_ix"
    ),
    
    // КИТАЙСКИЕ БРЕНДЫ (популярные в КZ)
    ElectricVehicle(
        make: "BYD",
        model: "Seal",
        year: 2024,
        batteryCapacity: 82.5,
        range: 570,
        efficiency: 14.5,
        supportedChargers: [.ccs2, .type2, .gbT], // Китайские авто часто поддерживают GB/T
        maxChargingSpeed: 150,
        image: "byd_seal"
    ),
    ElectricVehicle(
        make: "BYD",
        model: "Han",
        year: 2024,
        batteryCapacity: 85.4,
        range: 605,
        efficiency: 14.1,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 120,
        image: "byd_han"
    ),
    ElectricVehicle(
        make: "NIO",
        model: "ET7",
        year: 2024,
        batteryCapacity: 100.0,
        range: 580,
        efficiency: 17.2,
        supportedChargers: [.ccs2, .type2, .gbT, .chademo], // NIO часто поддерживает CHAdeMO
        maxChargingSpeed: 126,
        image: "nio_et7"
    ),
    ElectricVehicle(
        make: "Zeekr",
        model: "001",
        year: 2024,
        batteryCapacity: 100.0,
        range: 620,
        efficiency: 16.1,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 200,
        image: "zeekr_001"
    ),
    
    // КОРЕЙСКИЕ БРЕНДЫ
    ElectricVehicle(
        make: "Hyundai",
        model: "IONIQ 5",
        year: 2023,
        batteryCapacity: 72.6,
        range: 481,
        efficiency: 15.1,
        supportedChargers: [.ccs2, .type2], // Корейцы любят совместимость
        maxChargingSpeed: 233,
        image: "ioniq5"
    ),
    ElectricVehicle(
        make: "Hyundai",
        model: "IONIQ 6",
        year: 2024,
        batteryCapacity: 77.4,
        range: 614,
        efficiency: 12.6,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 233,
        image: "ioniq6"
    ),
    ElectricVehicle(
        make: "Kia",
        model: "EV6",
        year: 2024,
        batteryCapacity: 77.4,
        range: 528,
        efficiency: 14.7,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 233,
        image: "kia_ev6"
    ),
    ElectricVehicle(
        make: "Genesis",
        model: "GV70",
        year: 2024,
        batteryCapacity: 77.4,
        range: 455,
        efficiency: 17.0,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 233,
        image: "genesis_gv70"
    ),
    
    // НЕМЕЦКИЕ ПРЕМИУМ
    ElectricVehicle(
        make: "BMW",
        model: "iX3",
        year: 2023,
        batteryCapacity: 80.0,
        range: 460,
        efficiency: 17.4,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 150,
        image: "bmw_ix3"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "i4",
        year: 2024,
        batteryCapacity: 83.9,
        range: 590,
        efficiency: 14.2,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 205,
        image: "bmw_i4"
    ),
    ElectricVehicle(
        make: "Audi",
        model: "e-tron GT",
        year: 2024,
        batteryCapacity: 93.4,
        range: 488,
        efficiency: 19.1,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 270,
        image: "audi_etron_gt"
    ),
    ElectricVehicle(
        make: "Porsche",
        model: "Taycan",
        year: 2024,
        batteryCapacity: 93.4,
        range: 504,
        efficiency: 18.5,
        supportedChargers: [.ccs2, .type2], // Порше может поддерживать мощные CEE
        maxChargingSpeed: 270,
        image: "porsche_taycan"
    ),
    
    // ЯПОНСКИЕ БРЕНДЫ (с CHAdeMO)
    ElectricVehicle(
        make: "Nissan",
        model: "Ariya",
        year: 2024,
        batteryCapacity: 87.0,
        range: 500,
        efficiency: 17.4,
        supportedChargers: [.ccs2, .chademo, .type2], // Nissan исторически CHAdeMO
        maxChargingSpeed: 130,
        image: "nissan_ariya"
    ),
    ElectricVehicle(
        make: "Nissan",
        model: "Leaf",
        year: 2023,
        batteryCapacity: 62.0,
        range: 385,
        efficiency: 16.1,
        supportedChargers: [.chademo, .type2, .type1], // Старый Leaf поддерживал Type1
        maxChargingSpeed: 100,
        image: "nissan_leaf"
    ),
    ElectricVehicle(
        make: "Lexus",
        model: "RZ 450e",
        year: 2024,
        batteryCapacity: 71.4,
        range: 440,
        efficiency: 16.2,
        supportedChargers: [.ccs2, .chademo, .type2], // Lexus переходит на CCS но оставляет CHAdeMO
        maxChargingSpeed: 150,
        image: "lexus_rz"
    ),
    
    // АМЕРИКАНСКИЕ БРЕНДЫ
    ElectricVehicle(
        make: "Ford",
        model: "Mustang Mach-E",
        year: 2024,
        batteryCapacity: 91.0,
        range: 600,
        efficiency: 15.2,
        supportedChargers: [.ccs2, .type2], // Ford переходит на NACS для совместимости с Tesla
        maxChargingSpeed: 150,
        image: "ford_mach_e"
    ),
    ElectricVehicle(
        make: "Cadillac",
        model: "Lyriq",
        year: 2024,
        batteryCapacity: 102.0,
        range: 502,
        efficiency: 20.3,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 190,
        image: "cadillac_lyriq"
    ),
    
    // БЮДЖЕТНЫЕ ВАРИАНТЫ (больше стандартных разъемов)
    ElectricVehicle(
        make: "Dacia",
        model: "Spring",
        year: 2024,
        batteryCapacity: 26.8,
        range: 230,
        efficiency: 11.7,
        supportedChargers: [.ccs2, .type2], // Бюджетники поддерживают больше "простых" разъемов
        maxChargingSpeed: 30,
        image: "dacia_spring"
    ),
    ElectricVehicle(
        make: "Citroen",
        model: "e-C4",
        year: 2024,
        batteryCapacity: 54.0,
        range: 420,
        efficiency: 12.9,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 100,
        image: "citroen_ec4"
    ),
    
    // ВНЕДОРОЖНИКИ/КРОССОВЕРЫ
    ElectricVehicle(
        make: "Volkswagen",
        model: "ID.4",
        year: 2024,
        batteryCapacity: 77.0,
        range: 520,
        efficiency: 14.8,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 135,
        image: "vw_id4"
    ),
    ElectricVehicle(
        make: "Volvo",
        model: "XC40 Recharge",
        year: 2024,
        batteryCapacity: 82.0,
        range: 460,
        efficiency: 17.8,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 150,
        image: "volvo_xc40"
    ),
    
    // КОММЕРЧЕСКИЙ ТРАНСПОРТ (мощные разъемы)
    ElectricVehicle(
        make: "Mercedes",
        model: "eSprinter",
        year: 2024,
        batteryCapacity: 113.0,
        range: 440,
        efficiency: 25.7,
        supportedChargers: [.ccs2, .type2], // Коммерческий транспорт нуждается в мощных разъемах
        maxChargingSpeed: 115,
        image: "mercedes_esprinter"
    ),
    ElectricVehicle(
        make: "Rivian",
        model: "R1T",
        year: 2024,
        batteryCapacity: 135.0,
        range: 516,
        efficiency: 26.2,
        supportedChargers: [.ccs2, .type2], // Американские пикапы
        maxChargingSpeed: 210,
        image: "rivian_r1t"
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
