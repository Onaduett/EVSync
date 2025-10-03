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
    
    let onClose: (() -> Void)?
    
    init(station: ChargingStation, showingDetail: Binding<Bool>, onClose: (() -> Void)? = nil) {
        self.station = station
        self._showingDetail = showingDetail
        self.onClose = onClose
    }
    
    @Namespace private var animationNamespace
    
    var body: some View {
        // Константы высоты
        let collapsedHeight: CGFloat = 280
        let expandedHeight: CGFloat = UIScreen.main.bounds.height * 0.85
        let bottomButtonsHeight: CGFloat = 56
        let bottomButtonsVPadding: CGFloat = 40

        ZStack(alignment: .bottom) {
            // Фон + форма
            cardBackground
                .clipShape(TopRoundedRectangle(cornerRadius: 20))

            // Контент
            VStack(spacing: 0) {
                // Drag handle + жест
                dragHandle

                if showingFullDetail {
                    // Полная версия со скроллом
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading, spacing: 6) {
                                headerSection
                                connectorBoxes
                                compatibilitySection
                                    .padding(.top, 2)
                                
                                expandedContent
                                    .padding(.top, 8)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 0)
                        }
                        // чтобы контент не уезжал под кнопки
                        .padding(.bottom, bottomButtonsHeight + bottomButtonsVPadding + 12)
                    }
                } else {
                    // Превью без скролла
                    VStack(alignment: .leading, spacing: 6) {
                        headerSection
                        connectorBoxes
                        compatibilitySection
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 0)
                    .padding(.bottom, bottomButtonsHeight + bottomButtonsVPadding + 12)
                    
                    Spacer()
                }
            }

            // Кнопки — ПРИШИТЫ к низу
            actionButtons
                .padding(.horizontal, 10)
                .padding(.bottom, bottomButtonsVPadding)
        }
        // Вся карточка растёт вверх; низ остаётся на месте
        .frame(
            height: showingFullDetail ? expandedHeight : collapsedHeight,
            alignment: .bottom
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .opacity(showingDetail ? 1.0 : 0.0)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: showingFullDetail)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if !showingDetail { showingDetail = true }
                }
            }
        }
        .task { await syncFavoriteStatus() }
        .onChange(of: showingDetail) { _, isShowing in
            if !isShowing {
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
        .gesture(dragGesture)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showingFullDetail.toggle()
            }
        }
    }
    
    private var cardBackground: some View {
        TopRoundedRectangle(cornerRadius: 20)
            .fill(.regularMaterial)
            .shadow(
                color: Color.black.opacity(0.12),
                radius: 15,
                x: 0,
                y: -8
            )
    }
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(fontManager.font(.title2, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(station.address)
                    .font(fontManager.font(.subheadline, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Оператор в боке
            Text(station.provider)
                .font(fontManager.font(.caption, weight: .bold))
                .foregroundColor(.teal)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
        }
    }
    
    private var connectorBoxes: some View {
        HStack(spacing: 8) {
            ForEach(Array(station.connectorTypes.prefix(2).enumerated()), id: \.element) { index, connector in
                ConnectorBox(
                    connector: connector,
                    power: station.power,
                    price: station.price,
                    languageManager: languageManager,
                    fontManager: fontManager
                )
            }
        }
    }
    
    private var compatibilitySection: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
                .font(.system(size: 16, weight: .semibold))
            
            Text("Совместимо с вашим автомобилем")
                .font(fontManager.font(.subheadline, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()
            
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
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 10) {
            // Favorite button
            Button(action: {
                Task { await toggleFavorite() }
            }) {
                if isLoadingFavorite {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(isFavorited ? .white : .red)
                } else {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isFavorited ? .white : .red)
                }
            }
            .frame(width: 56, height: 56)
            .background(isFavorited ? Color.red : Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(isLoadingFavorite)
            
            // Call button
            Button(action: callStation) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(station.hasPhoneNumber ? .teal : .gray)
            }
            .frame(width: 56, height: 56)
            .background(station.hasPhoneNumber ? Color.teal.opacity(0.1) : Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(!station.hasPhoneNumber)
            
            // Navigate button
            Button(action: navigateToStation) {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text(languageManager.localizedString("navigate"))
                        .font(fontManager.font(.subheadline, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.teal)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Gestures
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.height
                
                let threshold: CGFloat = 30
                if !showingFullDetail && dragOffset < -threshold && dragOffset > -(threshold + 10) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else if showingFullDetail && dragOffset > threshold && dragOffset < (threshold + 10) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onEnded { value in
                let translation = value.translation.height
                let velocity = value.predictedEndTranslation.height
                
                if !showingFullDetail && (translation < -40 || velocity < -80) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showingFullDetail = true
                    }
                } else if showingFullDetail && (translation > 30 || velocity > 80) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showingFullDetail = false
                    }
                } else if abs(translation) > 100 || abs(velocity) > 200 {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showingDetail = false
                    }
                    onClose?()
                }
                
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    dragOffset = 0
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
    
    private func localizedAmenity(_ amenity: String) -> String {
        let amenityKey = amenity.lowercased().replacingOccurrences(of: " ", with: "_")
        return languageManager.localizedString("amenity_\(amenityKey)")
    }
}

// MARK: - Connector Box Component

struct ConnectorBox: View {
    let connector: ConnectorType
    let power: String
    let price: String
    let languageManager: LanguageManager
    let fontManager: FontManager
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 6) {
                Image(systemName: connector.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.primary)
                
                Text(connector.rawValue)
                    .font(fontManager.font(.caption, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .alignmentGuide(.top) { $0[.top] }
            
            // Правая часть - мощность и цена
            VStack(alignment: .trailing, spacing: 6) {
                DetailChip(icon: "bolt.fill", text: power, color: .green)
                    .frame(width: 90, alignment: .trailing)

                PriceChip(text: price, languageManager: languageManager)
                    .frame(width: 90, alignment: .trailing)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .frame(height: 92)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Custom Shape for Top Rounded Corners

struct TopRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}
