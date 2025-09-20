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
    @State private var showingFullDetail = false
    @State private var isFavorited = false
    @State private var isLoadingFavorite = false
    @State private var dragOffset: CGFloat = 0
    @StateObject private var supabaseManager = SupabaseManager.shared
    @StateObject private var languageManager = LanguageManager()
    private let fontManager = FontManager.shared
    
    private let previewHeight: CGFloat = 220
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Draggable Handle
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .scaleEffect(dragOffset != 0 ? 1.2 : 1.0)
                    .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8)) {
                    showingFullDetail.toggle()
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Header (always visible)
                headerSection
                
                // Basic info (always visible)
                basicInfoSection
                
                // Expanded content (only when full detail)
                if showingFullDetail {
                    expandedContent
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity
                        ))
                }
                
                // Action buttons
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(height: showingFullDetail ? nil : previewHeight, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(
                    color: Color.black.opacity(0.12),
                    radius: 15,
                    x: 0,
                    y: 8
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .padding(.bottom, -15)
        .opacity(showingDetail ? 1.0 : 0.0)
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.8), value: showingFullDetail)
        .animation(.easeInOut(duration: 0.3), value: showingDetail)
        .onAppear {
            // Анимируем появление карточки
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if !showingDetail {
                        showingDetail = true
                    }
                }
            }
        }
        .task {
            await syncFavoriteStatus()
        }
        .onChange(of: station.id) { _, _ in
            // ÐÐ½Ð¸Ð¼Ð°Ñ†Ð¸Ñ Ð¿Ñ€Ð¸ Ð¿ÐµÑ€ÐµÐºÐ»ÑŽÑ‡ÐµÐ½Ð¸Ð¸ ÑÑ‚Ð°Ð½Ñ†Ð¸Ð¹
            withAnimation(.easeInOut(duration: 0.2)) {
                showingDetail = false
            }
            
            // ÐÐµÐ±Ð¾Ð»ÑŒÑˆÐ°Ñ Ð·Ð°Ð´ÐµÑ€Ð¶ÐºÐ° Ð¿ÐµÑ€ÐµÐ´ Ð¿Ð¾ÐºÐ°Ð·Ð¾Ð¼ Ð½Ð¾Ð²Ð¾Ð¹ ÑÑ‚Ð°Ð½Ñ†Ð¸Ð¸
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFavorited = supabaseManager.favoriteIds.contains(station.id)
                isLoadingFavorite = false
                showingFullDetail = false
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingDetail = true
                }
            }
        }
        .onChange(of: showingDetail) { _, isShowing in
            if !isShowing {
                showingFullDetail = false
            }
        }
        .onReceive(supabaseManager.$favoriteIds) { ids in
            isFavorited = ids.contains(station.id)
        }
    }
    
    // MARK: - UI Components
    
    @ViewBuilder
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(fontManager.font(showingFullDetail ? .title2 : .headline, weight: .bold))
                    .foregroundColor(.primary)
                    .animation(.none, value: showingFullDetail)
                
                if !showingFullDetail {
                    Text(station.address)
                        .font(fontManager.font(.subheadline, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    Text(station.provider)
                        .font(fontManager.font(.subheadline))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeOut(duration: 0.25)) {
                    showingDetail = false
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(showingFullDetail ? .title2 : .title3)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status Badge (only in full detail)
            if showingFullDetail {
                HStack {
                    Circle()
                        .fill(station.availability.color)
                        .frame(width: 12, height: 12)
                    
                    Text(station.availability.localizedString(using: languageManager))
                        .font(fontManager.font(.subheadline, weight: .bold))
                        .foregroundColor(station.availability.color)
                    
                    Spacer()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Power and Price
            HStack(spacing: 16) {
                DetailChip(icon: "bolt.fill", text: station.power, color: .green)
                Spacer()
                PriceChip(text: station.price, languageManager: languageManager)
            }
            
            // Connector types
            if !showingFullDetail {
                // Compact horizontal scroll for preview
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(station.connectorTypes, id: \.self) { connector in
                            connectorChip(connector)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
    
    @ViewBuilder
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            
            // Full address info
            InfoRow(
                icon: "location",
                title: languageManager.localizedString("station_address"),
                value: station.address
            )
            
            InfoRow(
                icon: "clock",
                title: languageManager.localizedString("operating_hours"),
                value: station.operatingHours
            )
            
            if let phone = station.phoneNumber {
                InfoRow(
                    icon: "phone",
                    title: languageManager.localizedString("phone"),
                    value: phone
                )
            }
            
            Divider()
            
            // Connector types (grid layout for full view)
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
            
            // Amenities
            if !station.amenities.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(languageManager.localizedString("amenities"))
                        .font(fontManager.font(.headline, weight: .bold))
                        .foregroundColor(.primary)
                    
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
            }
            
            Divider()
        }
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if showingFullDetail {
                // Full detail buttons layout
                HStack(spacing: 12) {
                    // Call Button
                    Button(action: callStation) {
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
                        Task { await toggleFavorite() }
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
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            // Navigate button (always visible)
            Button(action: navigateToStation) {
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
        }
    }
    
    // MARK: - Helper Methods
    
    @ViewBuilder
    private func connectorChip(_ connector: ConnectorType) -> some View {
        HStack(spacing: 4) {
            Image(connector.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundColor(.blue)
            Text(connector.rawValue)
                .font(fontManager.font(.caption, weight: .bold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.height
                dragOffset = translation
                
                // Reduced haptic feedback frequency
                let threshold: CGFloat = 30
                if !showingFullDetail && translation < -threshold && translation > -(threshold + 10) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else if showingFullDetail && translation > threshold && translation < (threshold + 10) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onEnded { value in
                let translation = value.translation.height
                let velocity = value.predictedEndTranslation.height
                
                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8)) {
                    if !showingFullDetail && (translation < -40 || velocity < -80) {
                        showingFullDetail = true
                    } else if showingFullDetail && (translation > 30 || velocity > 80) {
                        showingFullDetail = false
                    }
                    dragOffset = 0
                }
            }
    }
    
    private func localizedAmenity(_ amenity: String) -> String {
        let amenityKey = amenity.lowercased().replacingOccurrences(of: " ", with: "_")
        return languageManager.localizedString("amenity_\(amenityKey)")
    }
    
    private func syncFavoriteStatus() async {
        isFavorited = supabaseManager.favoriteIds.contains(station.id)
        if supabaseManager.favoriteIds.isEmpty {
            await supabaseManager.syncFavorites()
            isFavorited = supabaseManager.favoriteIds.contains(station.id)
        }
    }
    
    private func callStation() {
        guard let phone = station.phoneNumber,
              let url = URL(string: "tel://\(phone)") else { return }
        UIApplication.shared.open(url)
    }
    
    private func navigateToStation() {
        let latitude = station.coordinate.latitude
        let longitude = station.coordinate.longitude
        
        if let dgisRouteUrl = URL(string: "dgis://2gis.ru/routeSearch/rsType/car/to/\(longitude),\(latitude)"),
           UIApplication.shared.canOpenURL(dgisRouteUrl) {
            UIApplication.shared.open(dgisRouteUrl)
        } else if let dgisGeoUrl = URL(string: "dgis://2gis.ru/geo/\(longitude),\(latitude)"),
                  UIApplication.shared.canOpenURL(dgisGeoUrl) {
            UIApplication.shared.open(dgisGeoUrl)
        } else if let dgisWebUrl = URL(string: "https://2gis.com/geo/\(longitude),\(latitude)") {
            UIApplication.shared.open(dgisWebUrl)
        }
    }
    
    private func toggleFavorite() async {
        let id = station.id
        isLoadingFavorite = true
        
        do {
            if isFavorited {
                try await supabaseManager.removeFavorite(stationId: id)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } else {
                try await supabaseManager.addFavorite(stationId: id)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        } catch {
            print("Favorite toggle error: \(error)")
            isFavorited = supabaseManager.favoriteIds.contains(id)
        }
        
        isLoadingFavorite = false
    }
}
