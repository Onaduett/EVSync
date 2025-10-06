import SwiftUI
import MapKit

struct NavigationBar: View {
    @State private var selectedTab = 0
    @State private var selectedStationFromFavorites: ChargingStation?
    @State private var isTransitioning = false
    
    @State private var presentedStation: ChargingStation?
    @State private var isStationCardShown = false
    
    @State private var shouldResetMap = false
    @State private var shouldZoomOut = false
    
    @StateObject private var mapViewModel = MapViewModel()
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager

    
    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case 0:
                    MapViewWrapper(
                        selectedStationFromFavorites: $selectedStationFromFavorites,
                        presentedStation: $presentedStation,
                        isStationCardShown: $isStationCardShown,
                        shouldResetMap: $shouldResetMap,
                        shouldZoomOut: $shouldZoomOut,
                        mapViewModel: mapViewModel
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
                    MapViewWrapper(
                        selectedStationFromFavorites: $selectedStationFromFavorites,
                        presentedStation: $presentedStation,
                        isStationCardShown: $isStationCardShown,
                        shouldResetMap: $shouldResetMap,
                        shouldZoomOut: $shouldZoomOut,
                        mapViewModel: mapViewModel
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: 70)
            }
            .zIndex(0)
            
            if let station = presentedStation, isStationCardShown {
                StationCardOverlay(
                    station: station,
                    onClose: closeStationCard
                )
                .zIndex(2)
            }
            
            VStack {
                Spacer()
                CustomGlassTabBar(
                    selectedTab: $selectedTab,
                    isTransitioning: $isTransitioning,
                    mapStyle: mapViewModel.mapStyle,
                    onMapTabTapped: {
                        if selectedTab == 0 {
                            shouldResetMap = true
                        }
                    }
                )
                .padding(.bottom, -15)
                .allowsHitTesting(!isStationCardShown)
            }
            .zIndex(1)
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: selectedTab) { oldValue, newValue in
            handleTabChange(from: oldValue, to: newValue)
        }
    }
    
    // MARK: - Private Methods
    
    private func closeStationCard() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isStationCardShown = false
            presentedStation = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            shouldZoomOut = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                shouldZoomOut = false
            }
        }
    }
    
    private func handleTabChange(from oldTab: Int, to newTab: Int) {
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

#Preview {
    NavigationBar()
        .environmentObject(AuthenticationManager())
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
        .environmentObject(FontManager.shared)
}
