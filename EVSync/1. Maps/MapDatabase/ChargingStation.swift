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
    
    // Equatable conformance
    static func == (lhs: ChargingStation, rhs: ChargingStation) -> Bool {
        return lhs.id == rhs.id
    }
}
