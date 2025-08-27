//
//  DBchargingStation.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//


import Foundation
import CoreLocation

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
    let station_operator: String?
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
            provider: station_operator ?? "EVSync Network"
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
