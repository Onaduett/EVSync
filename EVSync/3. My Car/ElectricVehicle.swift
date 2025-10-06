//
//  ElectricVehicle.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import Foundation

extension ConnectorType: Codable {}

struct ElectricVehicle: Identifiable, Codable {
    let id: String
    let make: String
    let model: String
    let year: Int
    let batteryCapacity: Double // kWh
    let range: Int // km
    let efficiency: Double // kWh/100km
    let supportedChargers: [ConnectorType]
    let maxChargingSpeed: Int // kW
    let image: String
    let logo: String // Brand logo image name
    
    init(id: String, make: String, model: String, year: Int, batteryCapacity: Double, range: Int, efficiency: Double, supportedChargers: [ConnectorType], maxChargingSpeed: Int, image: String, logo: String = "") {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.batteryCapacity = batteryCapacity
        self.range = range
        self.efficiency = efficiency
        self.supportedChargers = supportedChargers
        self.maxChargingSpeed = maxChargingSpeed
        self.image = image
        self.logo = logo.isEmpty ? "\(make.lowercased())_logo" : logo
    }
    
    var displayName: String {
        return "\(year) \(make) \(model)"
    }
}
