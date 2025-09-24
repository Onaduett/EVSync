//
//  ChargingStation.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import Foundation
import CoreLocation
import SwiftUI

struct ChargingStation: Identifiable, Equatable {
    let id: UUID
    let name: String
    let address: String
    let provider: String
    let power: String
    let price: String
    let availability: StationAvailability
    let connectorTypes: [ConnectorType]
    let latitude: Double
    let longitude: Double
    
    // Computed property for backward compatibility
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Additional properties from original structure
    var amenities: [String] {
        return generateAmenities()
    }
    
    var operatingHours: String {
        return "24/7" // Default value
    }
    
    var phoneNumber: String? {
        return nil // Default value
    }
    
    var hasPhoneNumber: Bool {
        return phoneNumber != nil && !phoneNumber!.isEmpty
    }
    
    var pricePerKWh: Double? {
        let cleanPrice = price.replacingOccurrences(of: "₸/kWh", with: "")
            .replacingOccurrences(of: "₸", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(cleanPrice)
    }
    
    var maxPower: Double? {
        let cleanPower = power.replacingOccurrences(of: "kW", with: "")
            .replacingOccurrences(of: "AC", with: "")
            .replacingOccurrences(of: "DC", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanPower.contains("/") {
            let components = cleanPower.components(separatedBy: "/")
            let powers = components.compactMap { Double($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
            return powers.max()
        }
        
        return Double(cleanPower)
    }
    
    // Primary initializer (for API data)
    init(id: UUID, name: String, address: String, provider: String, power: String, price: String, availability: StationAvailability, connectorTypes: [ConnectorType], latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.provider = provider
        self.power = power
        self.price = price
        self.availability = availability
        self.connectorTypes = connectorTypes
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Convenience initializer for backward compatibility
    init(id: UUID, name: String, address: String, coordinate: CLLocationCoordinate2D, connectorTypes: [ConnectorType], availability: StationAvailability, power: String, price: String, amenities: [String], operatingHours: String, phoneNumber: String?, provider: String) {
        self.id = id
        self.name = name
        self.address = address
        self.provider = provider
        self.power = power
        self.price = price
        self.availability = availability
        self.connectorTypes = connectorTypes
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    private func generateAmenities() -> [String] {
        var amenities = ["EV Charging"]
        
        if name.lowercased().contains("mall") || address.lowercased().contains("mall") {
            amenities.append(contentsOf: ["Shopping Mall", "Restaurant", "WiFi"])
        }
        if name.lowercased().contains("airport") || address.lowercased().contains("airport") {
            amenities.append(contentsOf: ["Airport", "24h Service"])
        }
        if name.lowercased().contains("park") {
            amenities.append("Parking")
        }
        if let maxPowerValue = maxPower, maxPowerValue >= 100 {
            amenities.append("Fast Charging")
        }
        
        return amenities
    }
    
    static func == (lhs: ChargingStation, rhs: ChargingStation) -> Bool {
        return lhs.id == rhs.id
    }
}
