//
//  FilterExtensions.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 19.09.25.
//

import Foundation
import SwiftUI

// MARK: - Filter State Management Extensions

extension MapViewModel {
    
    /// Get filter summary text for display purposes
    var filterSummaryText: String {
        var components: [String] = []
        
        if !selectedConnectorTypes.isEmpty {
            let connectorText = selectedConnectorTypes.count == 1 ?
                "\(selectedConnectorTypes.count) connector" :
                "\(selectedConnectorTypes.count) connectors"
            components.append(connectorText)
        }
        
        if !selectedOperators.isEmpty {
            let operatorText = selectedOperators.count == 1 ?
                "\(selectedOperators.count) operator" :
                "\(selectedOperators.count) operators"
            components.append(operatorText)
        }
        
        if components.isEmpty {
            return "No filters"
        }
        
        return components.joined(separator: ", ")
    }
    
    /// Reset to default filters
    func resetFilters() {
        selectedConnectorTypes.removeAll()
        selectedOperators.removeAll()
        applyFilters()
    }
    
    /// Apply preset filters for common use cases
    func applyPresetFilter(_ preset: FilterPreset) {
        resetFilters()
        
        switch preset {
        case .fastCharging:
            // Select high-power connectors
            selectedConnectorTypes = Set(availableConnectorTypes.filter { type in
                switch type {
                case .ccs1, .chademo, .tesla:
                    return true
                default:
                    return false
                }
            })
        case .teslaOnly:
            selectedOperators.insert("Tesla")
        case .evSyncOnly:
            selectedOperators.insert("EVSync Network")
        case .all:
            break // No filters applied
        }
        
        applyFilters()
    }
}

// MARK: - Filter Presets

enum FilterPreset: String, CaseIterable {
    case all = "All Stations"
    case fastCharging = "Fast Charging"
    case teslaOnly = "Tesla Only"
    case evSyncOnly = "EVSync Network"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .all:
            return "circle.grid.3x3"
        case .fastCharging:
            return "bolt.circle"
        case .teslaOnly:
            return "car.circle"
        case .evSyncOnly:
            return "network"
        }
    }
}

// MARK: - Operator Display Helpers

extension String {
    /// Clean up operator names for better display
    var displayOperatorName: String {
        switch self.lowercased() {
        case "evsync network":
            return "EVSync"
        case "tesla supercharger":
            return "Tesla"
        default:
            return self
        }
    }
    
    /// Get operator color for UI consistency
    var operatorColor: Color {
        switch self.lowercased() {
        case "tesla", "tesla supercharger":
            return .red
        case "evsync network", "evsync":
            return .blue
        case "electrify america":
            return .green
        case "chargepoint":
            return .orange
        default:
            return .gray
        }
    }
}

// MARK: - Filter Statistics

struct FilterStatistics {
    let totalStations: Int
    let filteredStations: Int
    let connectorTypeBreakdown: [ConnectorType: Int]
    let operatorBreakdown: [String: Int]
    
    var filteredPercentage: Double {
        guard totalStations > 0 else { return 0 }
        return (Double(filteredStations) / Double(totalStations)) * 100
    }
}

extension MapViewModel {
    
    /// Get current filter statistics
    var filterStatistics: FilterStatistics {
        let connectorBreakdown = Dictionary(
            grouping: filteredStations.flatMap { $0.connectorTypes },
            by: { $0 }
        ).mapValues { $0.count }
        
        let operatorBreakdown = Dictionary(
            grouping: filteredStations,
            by: { $0.provider }
        ).mapValues { $0.count }
        
        return FilterStatistics(
            totalStations: chargingStations.count,
            filteredStations: filteredStations.count,
            connectorTypeBreakdown: connectorBreakdown,
            operatorBreakdown: operatorBreakdown
        )
    }
}
