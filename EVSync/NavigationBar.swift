import SwiftUI

struct NavigationBar: View {
    @State private var selectedTab = 0
    @State private var selectedStationFromFavorites: ChargingStation?
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    
    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case 0:
                    MapView(selectedStationFromFavorites: $selectedStationFromFavorites)
                case 1:
                    FavoriteStationsView(
                        selectedTab: $selectedTab, selectedStationFromFavorites: $selectedStationFromFavorites)
                case 2:
                    MyCarView()
                case 3:
                    SettingsView()
                default:
                    MapView(selectedStationFromFavorites: $selectedStationFromFavorites)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: 70)
            }
            
            VStack {
                Spacer()
                CustomGlassTabBar(selectedTab: $selectedTab)
                    .padding(.bottom, -15)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomGlassTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) var colorScheme
    
    private var tabs: [(icon: String, title: String, tag: Int)] {
        [
            (icon: "map", title: languageManager.localizedString("maps_tool"), tag: 0),
            (icon: "ev.charger", title: languageManager.localizedString("favourite_tool"), tag: 1),
            (icon: "car.side", title: languageManager.localizedString("my_car_tool"), tag: 2),
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
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab.tag
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(selectedTab == tab.tag ? selectedIconColor : unselectedIconColor)
                            .scaleEffect(selectedTab == tab.tag ? 1.05 : 1.0)
                        
                        Text(tab.title)
                            .font(.system(size: 11, weight: selectedTab == tab.tag ? .semibold : .medium))
                            .foregroundColor(selectedTab == tab.tag ? selectedIconColor : unselectedIconColor)
                    }
                    .frame(width: 80, height: 50)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 330, height: 70)
        .background {
            // Glass effect
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
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
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
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.3)
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
    }
}
