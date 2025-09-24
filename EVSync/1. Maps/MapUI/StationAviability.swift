//
//  StationAvailability.swift
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
    case unknown = "Unknown"
    
    var color: Color {
        switch self {
        case .available: return .green
        case .occupied: return .orange
        case .outOfService: return .red
        case .maintenance: return .yellow
        case .unknown: return .gray
        }
    }
    
    func localizedString(using languageManager: LanguageManager) -> String {
        switch self {
        case .available:
            return languageManager.localizedString("status_available")
        case .occupied:
            return languageManager.localizedString("status_occupied")
        case .outOfService:
            return languageManager.localizedString("status_out_of_service")
        case .maintenance:
            return languageManager.localizedString("status_maintenance")
        case .unknown:
            return languageManager.localizedString("status_unknown")
        }
    }
}
