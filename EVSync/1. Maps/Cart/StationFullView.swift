//
//  StationFullDetailView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

struct StationFullDetailView: View {
    let station: ChargingStation
    @Binding var showingDetail: Bool
    @Binding var showingFullDetail: Bool
    @Binding var isFavorited: Bool
    @Binding var isLoadingFavorite: Bool
    let supabaseManager: SupabaseManager
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Draggable Handle at top
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .scaleEffect(dragOffset != 0 ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: dragOffset)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 1)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                        
                        // Haptic feedback when reaching threshold
                        if dragOffset > 50 && dragOffset < 55 {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            if value.translation.height > 50 || value.predictedEndTranslation.height > 100 {
                                showingFullDetail = false
                            }
                            dragOffset = 0
                        }
                    }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showingFullDetail = false
                }
            }
            
            // Header with close button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(station.name)
                        .font(.custom("Nunito Sans", size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(station.provider)
                        .font(.custom("Nunito Sans", size: 15))
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
                    .font(.custom("Nunito Sans", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(station.availability.color)
                
                Spacer()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(icon: "location", title: "Address", value: station.address)
                
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(icon: "clock", title: "Hours", value: station.operatingHours)
                        InfoRow(icon: "bolt", title: "Power", value: station.power)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(icon: "tenge.circle", title: "Price", value: station.price)
                        InfoRow(icon: "building.2", title: "Company", value: station.provider)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if let phone = station.phoneNumber {
                    InfoRow(icon: "phone", title: "Phone", value: phone)
                }
            }
            
            Divider()
            
            // Connector Types
            VStack(alignment: .leading, spacing: 6) {
                Text("Connector Types")
                    .font(.custom("Nunito Sans", size: 17))
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 6) {
                    ForEach(station.connectorTypes, id: \.self) { connector in
                        HStack {
                            Image(systemName: connector.icon)
                                .foregroundColor(.blue)
                            Text(connector.rawValue)
                                .font(.custom("Nunito Sans", size: 15))
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
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
                VStack(alignment: .leading, spacing: 6) {
                    Text("Amenities")
                        .font(.custom("Nunito Sans", size: 17))
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
                        ForEach(station.amenities, id: \.self) { amenity in
                            Text(amenity)
                                .font(.custom("Nunito Sans", size: 12))
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
            
            // Action Buttons - Three button layout
            VStack(spacing: 12) {
                // Top row with Call and Add/Remove Favorites
                HStack(spacing: 12) {
                    Button(action: {
                        callStation()
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Call")
                        }
                        .font(.custom("Nunito Sans", size: 15))
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .disabled(station.phoneNumber == nil)
                    
                    Button(action: {
                        Task {
                            await toggleFavorite()
                        }
                    }) {
                        HStack {
                            if isLoadingFavorite {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(isFavorited ? .white : .red)
                            } else {
                                Image(systemName: isFavorited ? "heart.fill" : "heart")
                                    .foregroundColor(isFavorited ? .white : .red)
                            }
                            Text(isFavorited ? "Saved" : "Save")
                        }
                        .font(.custom("Nunito Sans", size: 15))
                        .fontWeight(.semibold)
                        .foregroundColor(isFavorited ? .white : .red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isFavorited ? Color.red : Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .animation(.easeInOut(duration: 0.2), value: isFavorited)
                    }
                    .disabled(isLoadingFavorite)
                }
                
                // Bottom row with Navigate button (full width)
                Button(action: {
                    navigateToStation()
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Navigate")
                    }
                    .font(.custom("Nunito Sans", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
    }
    
    // MARK: - Action Methods
    private func callStation() {
        if let phone = station.phoneNumber {
            if let url = URL(string: "tel://\(phone)") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func navigateToStation() {
        let latitude = station.coordinate.latitude
        let longitude = station.coordinate.longitude
        let url = URL(string: "maps://?daddr=\(latitude),\(longitude)")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback to Google Maps or web maps
            let googleMapsUrl = URL(string: "https://maps.google.com/?daddr=\(latitude),\(longitude)")!
            UIApplication.shared.open(googleMapsUrl)
        }
    }
    
    @MainActor
    private func toggleFavorite() async {
        let stationId = station.id
        
        isLoadingFavorite = true
        
        do {
            // Use the new toggle method that handles everything
            let newStatus = try await supabaseManager.toggleStationFavorite(stationId: stationId)
            isFavorited = newStatus
            
            // Post notification to refresh favorites list
            NotificationCenter.default.post(name: .favoritesChanged, object: nil)
            
            print("✅ Successfully toggled favorite to: \(newStatus)")
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: newStatus ? .medium : .light)
            impactFeedback.impactOccurred()
            
        } catch {
            print("❌ Error toggling favorite: \(error)")
            // On error, re-check the actual status from database
            do {
                let actualStatus = try await supabaseManager.isStationFavorited(stationId: stationId)
                isFavorited = actualStatus
                print("🔄 Re-checked status after error: \(actualStatus)")
            } catch {
                print("❌ Error re-checking status: \(error)")
            }
        }
        
        isLoadingFavorite = false
    }
}
