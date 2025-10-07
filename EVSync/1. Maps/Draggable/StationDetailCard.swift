//
//  StationDetailCard.swift
//  Charge&Go
//
//
//

import SwiftUI

struct StationDetailCard: View {
    let station: ChargingStation
    @Binding var showingDetail: Bool
    @State private var showingFullDetail = false
    @State private var isFavorited = false
    @State private var isLoadingFavorite = false
    @State private var dragOffset: CGFloat = 0
    @State private var connectorPairIndex = 0
    @State private var showingCarSelection = false
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrollAtTop = true
    @State private var lockScroll = false

    @StateObject private var supabaseManager = SupabaseManager.shared
    @StateObject private var languageManager = LanguageManager()
    @AppStorage("selectedCarId") private var selectedCarId: String = ""
    
    private let fontManager = FontManager.shared
    
    let onClose: (() -> Void)?
    
    init(station: ChargingStation, showingDetail: Binding<Bool>, onClose: (() -> Void)? = nil) {
        self.station = station
        self._showingDetail = showingDetail
        self.onClose = onClose
    }
    
    @Namespace private var animationNamespace
    
    var body: some View {
        let collapsedHeight: CGFloat = 310
        let expandedHeight: CGFloat = UIScreen.main.bounds.height * 0.85
        let bottomButtonsHeight: CGFloat = 56
        let bottomButtonsVPadding: CGFloat = 40

        ZStack(alignment: .bottom) {
            cardBackground
                .clipShape(TopRoundedRectangle(cornerRadius: 20))

            VStack(spacing: 0) {
                dragHandle

                if showingFullDetail {
                    ScrollViewWithOffset(offset: $scrollOffset, onOffsetChange: { offset in
                        isScrollAtTop = offset <= 0
                    }) {
                        VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading, spacing: 6) {
                                headerSection
                                connectorBoxes
                                
                                ChargingCompatibilityView(
                                    station: station,
                                    selectedCarId: selectedCarId,
                                    languageManager: languageManager,
                                    fontManager: fontManager,
                                    onCarSelection: {
                                        showingCarSelection = true
                                    }
                                )
                                .padding(.top, 4)
                                
                                expandedContent
                                    .padding(.top, 8)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 0)
                        }
                        .padding(.bottom, bottomButtonsHeight + bottomButtonsVPadding + 12)
                    }
                    .scrollDisabled(lockScroll) // <— ключевая строка
                    .highPriorityGesture(isScrollAtTop ? collapseDragGesture : nil) // <— перехват жеста
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        headerSection
                        connectorBoxes
                        
                        ChargingCompatibilityView(
                            station: station,
                            selectedCarId: selectedCarId,
                            languageManager: languageManager,
                            fontManager: fontManager,
                            onCarSelection: {
                                showingCarSelection = true
                            }
                        )
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 0)
                    .padding(.bottom, bottomButtonsHeight + bottomButtonsVPadding + 12)
                    .contentShape(Rectangle())
                    .gesture(expandDragGesture)
                    
                    Spacer()
                }
            }

            actionButtons
                .padding(.horizontal, 16)
                .padding(.bottom, bottomButtonsVPadding)
        }
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
        .sheet(isPresented: $showingCarSelection) {
            CarSelectionView(
                selectedCarId: $selectedCarId,
                hasInitialSelection: !selectedCarId.isEmpty
            )
            .environmentObject(fontManager)
            .environmentObject(languageManager)
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
        .gesture(dragHandleGesture)
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
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let spacing: CGFloat = 8
            let boxWidth = (totalWidth - spacing) / 2

            ZStack {
                ForEach(Array(connectorPairs.enumerated()), id: \.offset) { idx, pair in
                    HStack(spacing: spacing) {
                        ForEach(Array(pair.enumerated()), id: \.offset) { _, connector in
                            ConnectorBox(
                                connector: connector,
                                power: station.power,
                                price: station.price,
                                languageManager: languageManager,
                                fontManager: fontManager
                            )
                            .frame(width: boxWidth)
                        }
                        if pair.count == 1 {
                            Spacer()
                                .frame(width: boxWidth)
                                .opacity(0)
                        }
                    }
                    .opacity(connectorPairIndex == idx ? 1 : 0)
                    .animation(.easeInOut(duration: 0.35), value: connectorPairIndex)
                }
            }
            .frame(width: totalWidth, height: 92)
        }
        .frame(height: 92)
        .onReceive(Timer.publish(every: 3, on: .main, in: .common).autoconnect()) { _ in
            let count = connectorPairs.count
            guard count > 1 else { return }
            withAnimation(.easeInOut(duration: 0.35)) {
                connectorPairIndex = (connectorPairIndex + 1) % count
            }
        }
        .onTapGesture {
            let count = connectorPairs.count
            guard count > 1 else { return }
            withAnimation(.easeInOut(duration: 0.35)) {
                connectorPairIndex = (connectorPairIndex + 1) % count
            }
        }
    }

    private var connectorPairs: [[ConnectorType]] {
        var result: [[ConnectorType]] = []
        let arr = station.connectorTypes
        var i = 0
        while i < arr.count {
            let end = min(i + 2, arr.count)
            result.append(Array(arr[i..<end]))
            i = end
        }
        return result
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
            
            Button(action: callStation) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(station.hasPhoneNumber ? .teal : .gray)
            }
            .frame(width: 56, height: 56)
            .background(station.hasPhoneNumber ? Color.teal.opacity(0.1) : Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(!station.hasPhoneNumber)
            
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
    
    // Жест для ручки - работает всегда
    private var dragHandleGesture: some Gesture {
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
                handleDragEnd(translation: value.translation.height, velocity: value.predictedEndTranslation.height)
            }
    }
    
    // Жест для разворачивания (когда карточка свернута)
    private var expandDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.height
                
                if !showingFullDetail && dragOffset < -30 && dragOffset > -40 {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onEnded { value in
                handleDragEnd(translation: value.translation.height, velocity: value.predictedEndTranslation.height)
            }
    }
    
    // Жест для сворачивания (когда карточка развернута И скролл наверху)
    private var collapseDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 { // тянем вниз
                    lockScroll = true            // <— глушим bounce
                    dragOffset = value.translation.height
                    if dragOffset > 30 && dragOffset < 40 {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
            .onEnded { value in
                defer {
                    lockScroll = false           // <— возвращаем скролл
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { dragOffset = 0 }
                }
                if value.translation.height > 0 {
                    handleDragEnd(translation: value.translation.height,
                                  velocity: value.predictedEndTranslation.height)
                }
            }
    }

    
    private func handleDragEnd(translation: CGFloat, velocity: CGFloat) {
        // Разворачивание (свайп вверх)
        if !showingFullDetail && (translation < -40 || velocity < -80) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showingFullDetail = true
            }
        }
        // Сворачивание (свайп вниз)
        else if showingFullDetail && (translation > 30 || velocity > 80) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showingFullDetail = false
            }
        }
        // Закрытие карточки (сильный свайп вниз)
        else if abs(translation) > 100 || abs(velocity) > 200 {
            withAnimation(.easeInOut(duration: 0.25)) {
                showingDetail = false
            }
            onClose?()
        }
        
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            dragOffset = 0
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
            isScrollAtTop = true
            scrollOffset = 0
            
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

// MARK: - ScrollView with Offset Tracking
struct ScrollViewWithOffset<Content: View>: View {
    @Binding var offset: CGFloat
    let onOffsetChange: (CGFloat) -> Void
    let content: Content
    
    init(offset: Binding<CGFloat>, onOffsetChange: @escaping (CGFloat) -> Void, @ViewBuilder content: () -> Content) {
        self._offset = offset
        self.onOffsetChange = onOffsetChange
        self.content = content()
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scroll")).minY
                )
            }
            .frame(height: 0)
            
            content
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            offset = value
            onOffsetChange(value)
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
