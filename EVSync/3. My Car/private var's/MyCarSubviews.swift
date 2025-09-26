//
//  MyCarView+Subviews.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

// MARK: - MyCarView Subviews
extension MyCarView {
    
    // MARK: - Car Info Card
    var carInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: {
                showingCarSelection = true
            }) {
                HStack(spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedCar.displayName)
                            .customFont(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.05))
        )
    }
    
    // MARK: - Specifications Section
    var specificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Technical Specifications
            VStack(alignment: .leading, spacing: 12) {
                Text(languageManager.localizedString("specifications"))
                    .customFont(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    SpecificationItem(
                        icon: "batteryblock.stack",
                        title: languageManager.localizedString("battery_capacity"),
                        value: "\(Int(selectedCar.batteryCapacity)) \(languageManager.localizedString("kwh_unit"))",
                        iconColor: .teal,
                        languageManager: languageManager
                    )
                    
                    SpecificationItem(
                        icon: "speedometer",
                        title: languageManager.localizedString("efficiency"),
                        value: String(format: "%.1f %@", selectedCar.efficiency, languageManager.localizedString("efficiency_unit")),
                        iconColor: .teal,
                        languageManager: languageManager
                    )
                    
                    SpecificationItem(
                        icon: "bolt.fill",
                        title: languageManager.localizedString("max_charging"),
                        value: "\(selectedCar.maxChargingSpeed) \(languageManager.localizedString("kw_unit"))",
                        iconColor: .green,
                        languageManager: languageManager
                    )
                    
                    SpecificationItem(
                        icon: "road.lanes",
                        title: languageManager.localizedString("range"),
                        value: "\(selectedCar.range) \(languageManager.localizedString("km_unit"))",
                        iconColor: .green,
                        languageManager: languageManager
                    )
                }
            }
            
            Divider()
            
            // Supported Chargers
            VStack(alignment: .leading, spacing: 12) {
                Text(languageManager.localizedString("compatible_connectors"))
                    .customFont(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(selectedCar.supportedChargers, id: \.self) { connector in
                        HStack {
                            Image(systemName: connector.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.primary)
                            Text(connector.rawValue)
                                .customFont(.subheadline)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.05))
        )
    }
}
