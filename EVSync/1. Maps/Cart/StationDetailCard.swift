//
//  StationDetailCard.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

struct StationDetailCard: View {
    let station: ChargingStation
    @Binding var showingDetail: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(station.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(station.provider)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingDetail = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Status Badge
            HStack {
                Circle()
                    .fill(station.availability.color)
                    .frame(width: 12, height: 12)
                
                Text(station.availability.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(station.availability.color)
                
                Spacer()
            }
            
            Divider()
            
            // Station Info
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(icon: "location", title: "Address", value: station.address)
                InfoRow(icon: "clock", title: "Hours", value: station.operatingHours)
                InfoRow(icon: "bolt", title: "Power", value: station.power)
                InfoRow(icon: "tenge.circle", title: "Price", value: station.price)
                
                if let phone = station.phoneNumber {
                    InfoRow(icon: "phone", title: "Phone", value: phone)
                }
            }
            
            Divider()
            
            // Connector Types
            VStack(alignment: .leading, spacing: 8) {
                Text("Connector Types")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(station.connectorTypes, id: \.self) { connector in
                        HStack {
                            Image(systemName: connector.icon)
                                .foregroundColor(.blue)
                            Text(connector.rawValue)
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
            }
            
            Divider()
            
            // Amenities
            if !station.amenities.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amenities")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 6) {
                        ForEach(station.amenities, id: \.self) { amenity in
                            Text(amenity)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Divider()
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    // Navigate to station
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Navigate")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                
                Button(action: {
                    // Call station
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(25)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 16)
    }
}
