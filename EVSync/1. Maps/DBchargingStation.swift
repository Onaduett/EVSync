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
    let phone_number: String?
    let created_at: String
    let updated_at: String
    
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
            price: {
                if let price = price_per_kwh {
                    if price.truncatingRemainder(dividingBy: 1) == 0 {
                        return String(format: "%.0f ₸/kWh", price) // без .0
                    } else {
                        return String(format: "%.1f ₸/kWh", price) // с одной цифрой после запятой
                    }
                } else {
                    return "Contact for pricing"
                }
            }(),

            amenities: generateAmenities(),
            operatingHours: "24/7",
            phoneNumber: phone_number,
            provider: station_operator ?? "Charge&Go Network"
        )
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
        if power_kw != nil && power_kw! >= 100 {
            amenities.append("Fast Charging")
        }
        
        return amenities
    }
}
