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
    @Binding var dragOffset: CGFloat
    let supabaseManager: SupabaseManager
    let ns: Namespace.ID // Added namespace parameter
    @StateObject private var languageManager = LanguageManager()
    private let fontManager = FontManager.shared
    
    var body: some View {
        let threshold: CGFloat = 60
        let downProgress = min(max(dragOffset / threshold, 0), 1) // 0...1
        
        VStack(alignment: .leading, spacing: 8) {
            // Draggable Handle at top
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .matchedGeometryEffect(id: "grabber", in: ns) // Added matched geometry
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
                        if dragOffset > 25 && dragOffset < 30 {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                            if value.translation.height > 20 || value.predictedEndTranslation.height > 60 {
                                showingFullDetail = false
                            }
                            dragOffset = 0
                        }
                    }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                    showingFullDetail = false
                }
            }
            
            Group {
                // Header with close button
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(station.name)
                            .matchedGeometryEffect(id: "name", in: ns) // Added matched geometry
                            .font(fontManager.font(.title2, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(station.provider)
                            .font(fontManager.font(.subheadline))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingDetail = false
                        }
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
                    
                    Text(station.availability.localizedString(using: languageManager))
                        .font(fontManager.font(.subheadline, weight: .bold))
                        .foregroundColor(station.availability.color)
                    
                    Spacer()
                }
                
                Divider()
                
                // Station Information - Consistent layout
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(
                        icon: "location",
                        title: languageManager.localizedString("station_address"),
                        value: station.address
                    )
                    .matchedGeometryEffect(id: "address", in: ns) // Added matched geometry
                    
                    InfoRow(
                        icon: "clock",
                        title: languageManager.localizedString("operating_hours"),
                        value: station.operatingHours
                    )
                    
                    // Power and Price in consistent style
                    HStack(spacing: 20) {
                        InfoRowWithChip(
                            icon: "bolt",
                            title: languageManager.localizedString("power"),
                            chipIcon: "bolt.fill",
                            chipText: station.power,
                            chipColor: .green
                        )
                        .background(
                            Color.clear
                                .matchedGeometryEffect(id: "powerChip", in: ns) // Added matched geometry
                        )
                        
                        InfoRowWithPriceChip(
                            icon: "creditcard",
                            title: languageManager.localizedString("price"),
                            priceText: station.price
                        )
                        .background(
                            Color.clear
                                .matchedGeometryEffect(id: "priceChip", in: ns) // Added matched geometry
                        )
                    }
                    
                    if let phone = station.phoneNumber {
                        InfoRow(
                            icon: "phone",
                            title: languageManager.localizedString("phone"),
                            value: phone
                        )
                    }
                }
                
                Divider()
                
                // Connector Types
                VStack(alignment: .leading, spacing: 8) {
                    Text(languageManager.localizedString("connector_types"))
                        .font(fontManager.font(.headline, weight: .bold))
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(station.connectorTypes, id: \.self) { connector in
                            HStack(spacing: 8) {
                                Image(connector.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                                    .foregroundColor(.blue)
                                
                                Text(connector.rawValue)
                                    .font(fontManager.font(.footnote, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                }
                .matchedGeometryEffect(id: "connectors", in: ns) // Added matched geometry
                
                Divider()
                
                // Amenities - Updated to use left-aligned flow layout
                if !station.amenities.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(languageManager.localizedString("amenities"))
                            .font(fontManager.font(.headline, weight: .bold))
                            .foregroundColor(.primary)
                        
                        // Use FlowLayout for better left alignment
                        FlowLayout(alignment: .leading, spacing: 6) {
                            ForEach(station.amenities, id: \.self) { amenity in
                                Text(localizedAmenity(amenity))
                                    .font(fontManager.font(.caption, weight: .semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue.opacity(0.1))
                                    )
                                    .foregroundColor(.teal)
                            }
                        }
                    }
                    
                    Divider()
                }
                
                // Action Buttons - Improved layout
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        // Call Button
                        Button(action: {
                            callStation()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 14, weight: .bold))
                                Text(languageManager.localizedString("call"))
                                    .font(fontManager.font(.subheadline, weight: .bold))
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .disabled(station.phoneNumber == nil)
                        
                        // Favorite Button
                        Button(action: {
                            Task {
                                await toggleFavorite()
                            }
                        }) {
                            HStack(spacing: 6) {
                                if isLoadingFavorite {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(isFavorited ? .white : .red)
                                } else {
                                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(isFavorited ? .white : .red)
                                }
                                Text(isFavorited ?
                                    languageManager.localizedString("saved") :
                                    languageManager.localizedString("save")
                                )
                                    .font(fontManager.font(.subheadline, weight: .bold))
                            }
                            .foregroundColor(isFavorited ? .white : .red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isFavorited ? Color.red : Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .disabled(isLoadingFavorite)
                    }
                    
                    // Navigate button (full width) - Updated to match preview exactly
                    Button(action: {
                        navigateToStation()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text(languageManager.localizedString("navigate"))
                        }
                        .font(fontManager.font(.subheadline, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .matchedGeometryEffect(id: "navigate", in: ns) // Added matched geometry
                }
            }
            .opacity(1 - downProgress)
            .animation(.easeOut(duration: 0.15), value: downProgress)
        }
        .padding(16)
    }
    
    // MARK: - Localization Helpers
    private func localizedAmenity(_ amenity: String) -> String {
        let amenityKey = amenity.lowercased().replacingOccurrences(of: " ", with: "_")
        return languageManager.localizedString("amenity_\(amenityKey)")
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
        
        if let dgisAppUrl = URL(string: "dgis://2gis.ru/geo/\(longitude),\(latitude)"),
           UIApplication.shared.canOpenURL(dgisAppUrl) {
            UIApplication.shared.open(dgisAppUrl)
        } else {
            if let dgisWebUrl = URL(string: "https://2gis.com/geo/\(longitude),\(latitude)") {
                UIApplication.shared.open(dgisWebUrl)
            }
        }
    }
    
    private func toggleFavorite() async {
        let id = station.id
        isLoadingFavorite = true
        
        do {
            if isFavorited {
                try await supabaseManager.removeFavorite(stationId: id)
                await MainActor.run {
                    isFavorited = false
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            } else {
                try await supabaseManager.addFavorite(stationId: id)
                await MainActor.run {
                    isFavorited = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        } catch {
            print("Favorite toggle error: \(error)")
            await MainActor.run {
                isFavorited = supabaseManager.favoriteIds.contains(id)
            }
        }
        
        isLoadingFavorite = false
    }
}
