//
//  StationAviability.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

enum StationAvailability: String, CaseIterable {
    case available = "Available"
    case occupied = "Occupied"
    case outOfService = "Out of Service"
    case maintenance = "Maintenance"
    
    var color: Color {
        switch self {
        case .available: return .green
        case .occupied: return .orange
        case .outOfService: return .red
        case .maintenance: return .yellow
        }
    }
}
