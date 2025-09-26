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
    
    // Добавляем callback для очистки выбранной станции
    let onClose: (() -> Void)?
    
    // Инициализатор с опциональным callback
    init(station: ChargingStation, showingDetail: Binding<Bool>, onClose: (() -> Void)? = nil) {
        self.station = station
        self._showingDetail = showingDetail
        self.onClose = onClose
    }
    
    // Namespace для matched geometry
    @Namespace private var animationNamespace
    
    // Фазы анимации
    private enum Phase { case preview, fadingOut, loading, expanded, fadingIn }
    @State private var phase: Phase = .preview
    @State private var contentOpacity: Double = 1.0
    
    private let previewHeight: CGFloat = 220
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Draggable Handle
            dragHandle
            
            VStack(alignment: .leading, spacing: 12) {
                // Header (всегда видимый)
                headerSection
                
                // Basic info (всегда видимый)
                basicInfoSection
                
                // Expanded content (только при полном развертывании)
                if showingFullDetail {
                    Group {
                        expandedContentView
                            .redacted(reason: phase == .loading ? .placeholder : [])
                    }
                    .transition(.opacity)
                }
                
                // Action buttons
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .opacity(contentOpacity)
            .animation(.none, value: showingFullDetail)
        }
        .frame(height: showingFullDetail ? nil : previewHeight, alignment: .top)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .padding(.bottom, -15)
        .opacity(showingDetail ? 1.0 : 0.0)
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
        .onChange(of: showingDetail) { _, isShowing in
            if !isShowing {
                showingFullDetail = false
                phase = .preview
                contentOpacity = 1.0
                
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
        .gesture(dragGesture)
        .onTapGesture {
            if phase == .preview {
                expandWithFade()
            } else if phase == .expanded {
                collapseWithFade()
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
                // Используем matchedGeometryEffect для плавного перехода
                Text(station.name)
                    .font(fontManager.font(showingFullDetail ? .title2 : .headline, weight: .bold))
                    .foregroundColor(.primary)
                    .matchedGeometryEffect(id: "stationName", in: animationNamespace)
                
                if !showingFullDetail {
                    Text(station.address)
                        .font(fontManager.font(.subheadline, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .transition(.opacity)
                } else {
                    Text(station.provider)
                        .font(fontManager.font(.subheadline))
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showingDetail = false
                }
                onClose?()
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
            // Status Badge (только в полном режиме)
            if showingFullDetail {
                statusBadge
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Power and Price - кэшируем с matchedGeometryEffect
            HStack(spacing: 16) {
                DetailChip(icon: "bolt.fill", text: station.power, color: .green)
                    .matchedGeometryEffect(id: "powerChip", in: animationNamespace)
                Spacer()
                PriceChip(text: station.price, languageManager: languageManager)
                    .matchedGeometryEffect(id: "priceChip", in: animationNamespace)
            }
            
            // Connector types (только в свернутом режиме)
            if !showingFullDetail {
                compactConnectorTypes
                    .transition(.opacity)
            }
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
    
    // Кэшированный компонент для connector types
    private var compactConnectorTypes: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(station.connectorTypes, id: \.self) { connector in
                    ConnectorChipView(connector: connector, fontManager: fontManager)
                }
            }
            .padding(.horizontal, 1)
        }
        .id(station.id) // Принудительно пересоздаем при смене станции
    }
    
    // Отдельная View для тяжелого контента
    @ViewBuilder
    private var expandedContentView: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
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
            
            // Phone info - show different content based on availability
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
                fontManager: fontManager
            )
            
            // Amenities
            if !station.amenities.isEmpty {
                Divider()
                AmenitiesView(
                    station: station,
                    languageManager: languageManager,
                    fontManager: fontManager
                )
            }
            
            Divider()
        }
        .transition(.opacity)
        .id(station.id) // Принудительно пересоздаем при смене станции
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if showingFullDetail {
                // Full detail buttons layout
                HStack(spacing: 12) {
                    callButton
                    favoriteButton
                }
                .transition(.opacity)
            }
            
            // Navigate button (всегда видимый)
            navigateButton
        }
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
    
    // MARK: - Helper Methods
    
    private func expandWithFade() {
        guard phase == .preview else { return }
        phase = .fadingOut
        withAnimation(.easeInOut(duration: 0.18)) { contentOpacity = 0 }

        // после фейд-аута монтируем full и "грузим"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            showingFullDetail = true   // монтируем expandedContent
            phase = .loading

            // имитация «подгрузки» тяжёлого UI кадр спустя
            DispatchQueue.main.async {
                phase = .fadingIn
                withAnimation(.easeInOut(duration: 0.22)) {
                    contentOpacity = 1
                }
                // финальная стадия
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                    phase = .expanded
                }
            }
        }
    }

    private func collapseWithFade() {
        guard phase == .expanded else { return }
        phase = .fadingOut
        withAnimation(.easeInOut(duration: 0.18)) { contentOpacity = 0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            showingFullDetail = false  // демонтируем тяжёлый контент пока невидимо
            phase = .fadingIn
            withAnimation(.easeInOut(duration: 0.22)) {
                contentOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                phase = .preview
            }
        }
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
                
                if phase == .preview, (translation < -40 || velocity < -80) {
                    expandWithFade()
                } else if phase == .expanded, (translation > 30 || velocity > 80) {
                    collapseWithFade()
                } else if abs(translation) > 100 || abs(velocity) > 200 {
                    // NEW: Close card with cinematic zoom out
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showingDetail = false
                    }
                    onClose?() // This will trigger subtleZoomOut() in MapView
                } else {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                        dragOffset = 0
                    }
                }
            }
    }
    
    private func handleStationChange() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showingDetail = false
        }
        
        // Небольшая задержка перед показом новой станции
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isFavorited = supabaseManager.favoriteIds.contains(station.id)
            isLoadingFavorite = false
            showingFullDetail = false
            phase = .preview
            contentOpacity = 1.0
            
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
        // Check if phone number is available
        guard station.hasPhoneNumber, let phoneNumber = station.phoneNumber else {
            print("No phone number available for this station")
            return
        }
        
        // Clean the phone number - remove spaces, dashes, parentheses
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
            // Optional: Show an alert to user that calling is not available
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

// MARK: - Extracted Components

// Отдельная View для connector chip для избежания пересоздания
struct ConnectorChipView: View {
    let connector: ConnectorType
    let fontManager: FontManager
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: connector.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundColor(.primary)
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
}

// Отдельная View для grid connector types
struct ConnectorTypesGridView: View {
    let station: ChargingStation
    let languageManager: LanguageManager
    let fontManager: FontManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(languageManager.localizedString("connector_types"))
                .font(fontManager.font(.headline, weight: .bold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(station.connectorTypes, id: \.self) { connector in
                    HStack(spacing: 8) {
                        Image(systemName: connector.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.primary)
                        
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
    }
}

// Отдельная View для amenities
struct AmenitiesView: View {
    let station: ChargingStation
    let languageManager: LanguageManager
    let fontManager: FontManager
    
    var body: some View {
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
    
    private func localizedAmenity(_ amenity: String) -> String {
        let amenityKey = amenity.lowercased().replacingOccurrences(of: " ", with: "_")
        return languageManager.localizedString("amenity_\(amenityKey)")
    }
}
