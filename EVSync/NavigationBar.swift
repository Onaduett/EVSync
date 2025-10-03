import SwiftUI

struct NavigationBar: View {
    @State private var selectedTab = 0
    @State private var selectedStationFromFavorites: ChargingStation?
    @State private var isTransitioning = false
    
    @State private var presentedStation: ChargingStation?
    @State private var isStationCardShown = false
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    
    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case 0:
                    // Прокидываем биндинги для управления карточкой
                    MapView(
                        selectedStationFromFavorites: $selectedStationFromFavorites,
                        presentedStation: $presentedStation,
                        isStationCardShown: $isStationCardShown
                    )
                case 1:
                    FavoriteStationsView(
                        selectedTab: $selectedTab,
                        selectedStationFromFavorites: $selectedStationFromFavorites
                    )
                case 2:
                    MyCarView()
                case 3:
                    SettingsView()
                default:
                    MapView(
                        selectedStationFromFavorites: $selectedStationFromFavorites,
                        presentedStation: $presentedStation,
                        isStationCardShown: $isStationCardShown
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: 70)
            }
            .zIndex(0)
            
            // NEW: Карточка станции ПОВЕРХ таббара
            if let station = presentedStation, isStationCardShown {
                ZStack {
                    // Затемнение фона
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isStationCardShown = false
                                presentedStation = nil
                            }
                        }
                    
                    VStack {
                        Spacer()
                        
                        StationDetailCard(
                            station: station,
                            showingDetail: .constant(true),
                            onClose: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    isStationCardShown = false
                                    presentedStation = nil
                                }
                            }
                        )
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    )
                )
                .zIndex(2)
            }
            
            // Таббар — между контентом и карточкой
            VStack {
                Spacer()
                CustomGlassTabBar(
                    selectedTab: $selectedTab,
                    isTransitioning: $isTransitioning
                )
                .padding(.bottom, -15)
                // Отключаем взаимодействие с таббаром, когда открыта карточка
                .allowsHitTesting(!isStationCardShown)
            }
            .zIndex(1)
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: selectedTab) { oldValue, newValue in
            handleTabChange(from: oldValue, to: newValue)
        }
    }
    
    private func handleTabChange(from oldTab: Int, to newTab: Int) {
        // Закрываем карточку при смене таба
        if isStationCardShown {
            withAnimation(.easeInOut(duration: 0.2)) {
                isStationCardShown = false
                presentedStation = nil
            }
        }
        
        guard !isTransitioning else { return }
        
        if (oldTab == 0 && newTab == 1) || (oldTab == 1 && newTab == 0) {
            isTransitioning = true
            
            if oldTab == 0 && newTab == 1 {
                NotificationCenter.default.post(name: NSNotification.Name("HideStationAnnotations"), object: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isTransitioning = false
                }
            }
            else if oldTab == 1 && newTab == 0 {
                NotificationCenter.default.post(name: NSNotification.Name("ShowStationAnnotations"), object: nil)
                isTransitioning = false
            }
        }
        else if oldTab == 0 && newTab != 1 {
            isTransitioning = true
            NotificationCenter.default.post(name: NSNotification.Name("HideStationAnnotations"), object: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTransitioning = false
            }
        }
        else if oldTab != 1 && newTab == 0 {
            isTransitioning = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                NotificationCenter.default.post(name: NSNotification.Name("ShowStationAnnotations"), object: nil)
                isTransitioning = false
            }
        }
        else {
            isTransitioning = false
        }
    }
}

// CustomGlassTabBar остаётся без изменений
struct CustomGlassTabBar: View {
    @Binding var selectedTab: Int
    @Binding var isTransitioning: Bool
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var fontManager: FontManager
    @Environment(\.colorScheme) var colorScheme
    
    private var tabs: [(icon: String, title: String, tag: Int)] {
        [
            (icon: "map", title: languageManager.localizedString("maps_tool"), tag: 0),
            (icon: "ev.charger", title: languageManager.localizedString("favourite_tool"), tag: 1),
            (icon: "suv.side.roof.cargo.carrier", title: languageManager.localizedString("my_car_tool"), tag: 2),
            (icon: "person.crop.circle", title: languageManager.localizedString("account"), tag: 3)
        ]
    }
    
    private var effectiveColorScheme: ColorScheme {
        switch themeManager.currentTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .auto:
            return colorScheme
        }
    }
    
    private var selectedIconColor: Color {
        effectiveColorScheme == .dark ? .white : .primary
    }
    
    private var unselectedIconColor: Color {
        effectiveColorScheme == .dark ? .white.opacity(0.7) : .primary.opacity(0.7)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tag) { tab in
                Button(action: {
                    if tab.tag == 2 || tab.tag == 3 {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedTab = tab.tag
                        }
                    } else {
                        guard !isTransitioning else { return }
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab.tag
                        }
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(selectedTab == tab.tag ? selectedIconColor : unselectedIconColor)
                            .scaleEffect(selectedTab == tab.tag ? 1.05 : 1.0)
                        
                        Text(tab.title)
                            .font(fontManager.font(.caption2, weight: selectedTab == tab.tag ? .semibold : .medium))
                            .foregroundColor(selectedTab == tab.tag ? selectedIconColor : unselectedIconColor)
                    }
                    .frame(width: 80, height: 50)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 330, height: 70)
        .background {
            RoundedRectangle(cornerRadius: 35)
                .fill(.regularMaterial)
                .glassEffect()
                .shadow(color: .black.opacity(0.25), radius: 15, x: 0, y: 8)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
        .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
    }
}

extension View {
    func glassEffect() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 35)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.primary.opacity(0.15),
                                Color.primary.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 35)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.primary.opacity(0.6),
                                Color.primary.opacity(0.1),
                                Color.primary.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
            .environmentObject(AuthenticationManager())
            .environmentObject(ThemeManager())
            .environmentObject(LanguageManager())
            .environmentObject(FontManager.shared)
    }
}
