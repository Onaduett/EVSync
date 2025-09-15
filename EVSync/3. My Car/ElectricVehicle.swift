//
//  ElectricVehicle.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import Foundation

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