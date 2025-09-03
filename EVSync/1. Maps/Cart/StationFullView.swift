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
            
            // Station Information - Consistent layout
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(icon: "location", title: "Address", value: station.address)
                InfoRow(icon: "clock", title: "Hours", value: station.operatingHours)
                
                // Power and Price in consistent style
                HStack(spacing: 20) {
                    InfoRowWithChip(
                        icon: "bolt",
                        title: "Power",
                        chipIcon: "bolt.fill",
                        chipText: station.power,
                        chipColor: .green
                    )
                    
                    InfoRowWithPriceChip(
                        icon: "creditcard",
                        title: "Price",
                        priceText: station.price
                    )
                }
                
                if let phone = station.phoneNumber {
                    InfoRow(icon: "phone", title: "Phone", value: phone)
                }
            }
            
            Divider()
            
            // Connector Types
            VStack(alignment: .leading, spacing: 8) {
                Text("Connector Types")
                    .font(.custom("Nunito Sans", size: 17))
                    .fontWeight(.semibold)
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
                                .font(.custom("Nunito Sans", size: 14))
                                .fontWeight(.medium)
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
            
            Divider()
            
            // Amenities - Updated to use left-aligned flow layout
            if !station.amenities.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amenities")
                        .font(.custom("Nunito Sans", size: 17))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // Use FlowLayout for better left alignment
                    FlowLayout(alignment: .leading, spacing: 6) {
                        ForEach(station.amenities, id: \.self) { amenity in
                            Text(amenity)
                                .font(.custom("Nunito Sans", size: 12))
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
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
            
            // Action Buttons - Improved layout
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Call Button
                    Button(action: {
                        callStation()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Call")
                                .font(.custom("Nunito Sans", size: 15))
                                .fontWeight(.semibold)
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
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(isFavorited ? .white : .red)
                            }
                            Text(isFavorited ? "Saved" : "Save")
                                .font(.custom("Nunito Sans", size: 15))
                                .fontWeight(.semibold)
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
                        Text("Navigate")
                    }
                    .font(.custom("Nunito Sans", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
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
    
    private func toggleFavorite() async {
        let stationId = station.id
        
        isLoadingFavorite = true
        
        do {
            if isFavorited {
                let favorites = try await supabaseManager.getFavoriteStations()
                if let favorite = favorites.first(where: { $0.stationId == stationId }) {
                    try await supabaseManager.removeFromFavorites(favoriteId: favorite.id)
                    isFavorited = false
                    
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            } else {
                try await supabaseManager.addToFavorites(stationId: stationId)
                isFavorited = true
                
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
        } catch {
            print("Error toggling favorite: \(error)")
        }
        
        isLoadingFavorite = false
    }
}

// MARK: - FlowLayout for Amenities
struct FlowLayout: Layout {
    var alignment: Alignment = .center
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        return result.bounds
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        for index in subviews.indices {
            let offset = result.offsets[index]
            subviews[index].place(at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y), proposal: .unspecified)
        }
    }
}

struct FlowResult {
    var bounds = CGSize.zero
    var offsets: [CGPoint] = []
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, alignment: Alignment, spacing: CGFloat) {
        var currentPosition = CGPoint.zero
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            if currentPosition.x + subviewSize.width > maxWidth && currentPosition.x > 0 {
                // Move to next line
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            offsets.append(currentPosition)
            
            currentPosition.x += subviewSize.width + spacing
            lineHeight = max(lineHeight, subviewSize.height)
            maxX = max(maxX, currentPosition.x - spacing)
        }
        
        bounds = CGSize(width: maxX, height: currentPosition.y + lineHeight)
    }
}

// MARK: - InfoRowWithChip Component
struct InfoRowWithChip: View {
    let icon: String
    let title: String
    let chipIcon: String
    let chipText: String
    let chipColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 16)
                
                Text(title)
                    .font(.custom("Nunito Sans", size: 13))
                    .foregroundColor(.secondary)
            }
            
            DetailChip(icon: chipIcon, text: chipText, color: chipColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - InfoRowWithPriceChip Component
struct InfoRowWithPriceChip: View {
    let icon: String
    let title: String
    let priceText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 16)
                
                Text(title)
                    .font(.custom("Nunito Sans", size: 13))
                    .foregroundColor(.secondary)
            }
            
            PriceChip(text: priceText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Detail Chip
struct DetailChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
            
            Text(text)
                .font(.custom("Nunito Sans", size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Price Chip
struct PriceChip: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(text.replacingOccurrences(of: "/kWh", with: ""))
                .font(.custom("Nunito Sans", size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("/kWh")
                .font(.custom("Nunito Sans", size: 14))
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.15))
        .clipShape(Capsule())
    }
}
