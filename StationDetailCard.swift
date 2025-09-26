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
    @State private var isFavorited = false
    @State private var isLoadingFavorite = false
    @State private var dragOffset: CGFloat = 0
    @StateObject private var supabaseManager = SupabaseManager.shared
    @StateObject private var languageManager = LanguageManager()
    private let fontManager = FontManager.shared
    
    // Interactive progress state
    @State private var progress: CGFloat = 0  // 0 = collapsed, 1 = expanded
    @State private var expandedContentHeight: CGFloat = 0
    private let previewHeight: CGFloat = 220
    
    // Layout constants
    private let bottomNavigateHeight: CGFloat = 72 // высота Navigate кнопки + отступы
    
    private var currentHeight: CGFloat {
        // Calculate target height based on content
        let targetHeight = max(previewHeight, previewHeight + expandedContentHeight + 140) // +140 for buttons + bottom space
        return previewHeight + (targetHeight - previewHeight) * progress
    }
    
    // Legacy states for compatibility (can be removed later)
    @State private var showingFullDetail = false
    
    let onClose: (() -> Void)?
    
    init(station: ChargingStation, showingDetail: Binding<Bool>, onClose: (() -> Void)? = nil) {
        self.station = station
        self._showingDetail = showingDetail
        self.onClose = onClose
    }
    
    @Namespace private var animationNamespace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Draggable Handle
            dragHandle
            
            VStack(alignment: .leading, spacing: 12) {
                // Header (always visible)
                headerSection
                
                // Basic info (always visible)
                basicInfoSection
                
                // Expanded content (smoothly revealed)
                expandedContentView
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear { expandedContentHeight = geo.size.height }
                                .onChange(of: geo.size.height) { _, newHeight in
                                    expandedContentHeight = newHeight
                                }
                        }
                    )
                    .opacity(progress)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .black.opacity(min(progress / 0.3, 1.0)), location: 0.0),
                                .init(color: .black, location: 0.35),
                                .init(color: .black, location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .allowsHitTesting(progress > 0.8)
                
                // Action buttons with smooth transitions (Call & Favorite only)
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.bottom, bottomNavigateHeight + (progress > 0.5 ? 20 : 8)) // Адаптивный отступ под Navigate
        }
        .frame(height: currentHeight, alignment: .top)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .bottom) {
            // Закреплённая Navigate кнопка
            navigateButton
                .opacity(0.7 + 0.3 * (1.0 - progress))
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .background(
                    // Мягкий градиент для лучшей читаемости
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.04)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                    .allowsHitTesting(false)
                )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, -15)
        .opacity(showingDetail ? 1.0 : 0.0)
        .onAppear {
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
        .onChange(of: showingDetail) { _, isShowing in
            if !isShowing {
                // Reset states when closing
                withAnimation(.easeInOut(duration: 0.2)) {
                    progress = 0
                }
                showingFullDetail = false
                onClose?()
            }
        }
        .onChange(of: station.id) { _, _ in
            handleStationChange()
        }
        .onReceive(supabaseManager.$favoriteIds) { ids in
            isFavorited = ids.contains(station.id)
        }
    }
    
    // MARK: - UI Components
    
    private var dragHandle: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .scaleEffect(dragOffset != 0 ? 1.2 : 1.0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .gesture(interactiveDragGesture)
        .onTapGesture {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                progress = progress < 0.5 ? 1 : 0
                showingFullDetail = (progress > 0.5)
            }
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.regularMaterial)
            .shadow(
                color: Color.black.opacity(0.12),
                radius: 15,
                x: 0,
                y: 8
            )
    }
    
    @ViewBuilder
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(fontManager.font(progress > 0.5 ? .title2 : .headline, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .matchedGeometryEffect(id: "stationName", in: animationNamespace)
                    .animation(.easeInOut(duration: 0.2), value: progress)
                
                Text(progress > 0.5 ? station.provider : station.address)
                    .font(fontManager.font(.subheadline, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .animation(.easeInOut(duration: 0.2), value: progress)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showingDetail = false
                }
                onClose?()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(progress > 0.5 ? .title2 : .title3)
                    .foregroundColor(.secondary)
                    .animation(.easeInOut(duration: 0.2), value: progress)
            }
        }
    }
    
    @ViewBuilder
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) { // Уменьшили spacing до 8
            // Status Badge (visible when expanded)
            if progress > 0.3 {
                statusBadge
                    .opacity(progress)
                    .scaleEffect(0.8 + 0.2 * progress)
            }
            
            // Power and Price chips
            HStack(spacing: 16) {
                DetailChip(
                    icon: "bolt.fill",
                    text: station.power,
                    color: .green,
                    id: "powerChip",
                    namespace: animationNamespace
                )
                
                Spacer()
                
                PriceChip(
                    text: station.price,
                    languageManager: languageManager,
                    id: "priceChip",
                    namespace: animationNamespace
                )
            }
            
            // Connector types (visible when collapsed)
            compactConnectorTypes
                .opacity(1.0 - progress * 1.4)
        }
    }
    
    private var statusBadge: some View {
        HStack {
            Circle()
                .fill(station.availability.color)
                .frame(width: 12, height: 12)
            
            Text(station.availability.localizedString(using: languageManager))
                .font(fontManager.font(.subheadline, weight: .bold))
                .foregroundColor(station.availability.color)
            
            Spacer()
        }
    }
    
    private var compactConnectorTypes: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(Array(station.connectorTypes.enumerated()), id: \.offset) { index, connector in
                    ConnectorChipView(
                        connector: connector,
                        fontManager: fontManager,
                        id: "connector_\(index)",
                        namespace: animationNamespace
                    )
                }
            }
            .padding(.horizontal, 1)
        }
        .frame(height: 32) // Фиксированная высота для предотвращения схлопывания
        .id(station.id)
    }
    
    @ViewBuilder
    private var expandedContentView: some View {
        LazyVStack(alignment: .leading, spacing: 8) { // Уменьшили spacing до 8
            Divider()
                .padding(.top, 4) // Минимальный отступ сверху
            
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
            
            InfoRow(
                icon: "phone",
                title: languageManager.localizedString("phone"),
                value: station.hasPhoneNumber ? station.phoneNumber! : languageManager.localizedString("no_support_number")
            )
            
            Divider()
            
            // Connector types (grid layout)
            ConnectorTypesGridView(
                station: station,
                languageManager: languageManager,
                fontManager: fontManager,
                namespace: animationNamespace
            )
            
            // Amenities
            if !station.amenities.isEmpty {
                Divider()
                AmenitiesView(
                    station: station,
                    languageManager: languageManager,
                    fontManager: fontManager,
                    namespace: animationNamespace
                )
            }
            
            Divider()
        }
        .id(station.id)
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 8) { // Компактнее spacing
            // Call and Favorite buttons (fade in when expanded)
            HStack(spacing: 12) {
                callButton
                favoriteButton
            }
            .opacity(progress)
            .allowsHitTesting(progress > 0.8)
        }
        .padding(.top, 4) // Минимальный отступ сверху
    }
    
    private var callButton: some View {
        Button(action: callStation) {
            HStack(spacing: 6) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 14, weight: .bold))
                Text(languageManager.localizedString("call"))
                    .font(fontManager.font(.subheadline, weight: .bold))
            }
            .foregroundColor(station.hasPhoneNumber ? .blue : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(station.hasPhoneNumber ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .disabled(!station.hasPhoneNumber)
    }
    
    private var favoriteButton: some View {
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
    
    private var navigateButton: some View {
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
    
    // MARK: - Gestures
    
    private var interactiveDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.height
                dragOffset = translation
                
                // Interactive progress update
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    let dragProgress = -translation / max(expandedContentHeight + 100, 200)  // Use dynamic height
                    progress = (progress + dragProgress * 0.01).clamped(to: 0...1)
                }
                
                // Haptic feedback at thresholds
                let threshold: CGFloat = 30
                if progress < 0.5 && translation < -threshold && translation > -(threshold + 10) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else if progress > 0.5 && translation > threshold && translation < (threshold + 10) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onEnded { value in
                let translation = value.translation.height
                let velocity = -value.velocity.height  // upward velocity = positive
                
                // Project final position based on velocity
                let projected = progress + velocity / 2500
                let target: CGFloat = projected > 0.5 ? 1 : 0
                
                // Smooth animation to target
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    progress = target
                    dragOffset = 0
                }
                
                // Sync legacy state
                showingFullDetail = (target > 0.5)
                
                // Handle dismissal on strong downward drag
                if abs(translation) > 100 || abs(-velocity) > 200 {
                    if translation > 0 && progress < 0.3 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showingDetail = false
                        }
                        onClose?()
                    }
                }
            }
    }
    
    // MARK: - Helper Methods
    
    private func handleStationChange() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showingDetail = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isFavorited = supabaseManager.favoriteIds.contains(station.id)
            isLoadingFavorite = false
            progress = 0
            showingFullDetail = false
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showingDetail = true
            }
        }
    }
    
    private func syncFavoriteStatus() async {
        isFavorited = supabaseManager.favoriteIds.contains(station.id)
        if supabaseManager.favoriteIds.isEmpty {
            await supabaseManager.syncFavorites()
            isFavorited = supabaseManager.favoriteIds.contains(station.id)
        }
    }
    
    private func callStation() {
        guard station.hasPhoneNumber, let phoneNumber = station.phoneNumber else {
            print("No phone number available for this station")
            return
        }
        
        let cleanPhoneNumber = phoneNumber
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        guard let url = URL(string: "tel://\(cleanPhoneNumber)") else {
            print("Invalid phone number: \(phoneNumber)")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot open phone URL: \(url)")
        }
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

// MARK: - Extensions

extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Extracted Components (keeping the same as original)

struct ConnectorChipView: View {
    let connector: ConnectorType
    let fontManager: FontManager
    let id: String
    let namespace: Namespace.ID
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: connector.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundColor(.primary)
            Text(connector.rawValue)
                .font(fontManager.font(.caption, weight: .bold))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
        .matchedGeometryEffect(id: id, in: namespace)
    }
}

struct ConnectorTypesGridView: View {
    let station: ChargingStation
    let languageManager: LanguageManager
    let fontManager: FontManager
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(languageManager.localizedString("connector_types"))
                .font(fontManager.font(.headline, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(Array(station.connectorTypes.enumerated()), id: \.offset) { index, connector in
                    HStack(spacing: 8) {
                        Image(systemName: connector.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.primary)
                        
                        Text(connector.rawValue)
                            .font(fontManager.font(.footnote, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                    .matchedGeometryEffect(id: "expanded_connector_\(index)", in: namespace)
                }
            }
        }
    }
}

struct AmenitiesView: View {
    let station: ChargingStation
    let languageManager: LanguageManager
    let fontManager: FontManager
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(languageManager.localizedString("amenities"))
                .font(fontManager.font(.headline, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            FlowLayout(alignment: .leading, spacing: 6) {
                ForEach(Array(station.amenities.enumerated()), id: \.offset) { index, amenity in
                    Text(localizedAmenity(amenity))
                        .font(fontManager.font(.caption, weight: .semibold))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                        .foregroundColor(.teal)
                        .matchedGeometryEffect(id: "amenity_\(index)", in: namespace)
                }
            }
        }
    }
    
    private func localizedAmenity(_ amenity: String) -> String {
        let amenityKey = amenity.lowercased().replacingOccurrences(of: " ", with: "_")
        return languageManager.localizedString("amenity_\(amenityKey)")
    }
}
