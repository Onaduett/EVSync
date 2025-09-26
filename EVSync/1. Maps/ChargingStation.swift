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
    let coordinate: CLLocationCoordinate2D
    let connectorTypes: [ConnectorType]
    let availability: StationAvailability
    let power: String
    let price: String
    let amenities: [String]
    let operatingHours: String
    let phoneNumber: String?
    let provider: String
    
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
    
    static func == (lhs: ChargingStation, rhs: ChargingStation) -> Bool {
        return lhs.id == rhs.id
    }
}
