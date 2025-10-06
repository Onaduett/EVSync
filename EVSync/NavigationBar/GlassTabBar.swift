//
//  GlassTabBar.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 06.10.25.
//

import SwiftUI
import MapKit

struct CustomGlassTabBar: View {
    @Binding var selectedTab: Int
    @Binding var isTransitioning: Bool
    let mapStyle: MKMapType
    var onMapTabTapped: () -> Void
    
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
        if selectedTab == 0 {
            return effectiveColorScheme == .dark
                ? .white
                : (mapStyle == .standard ? .black : .white)
        } else {
            return effectiveColorScheme == .dark ? .white : .primary
        }
    }
    
    private var unselectedIconColor: Color {
        if selectedTab == 0 {
            return effectiveColorScheme == .dark
                ? .white.opacity(0.7)
                : (mapStyle == .standard ? .black.opacity(0.7) : .white.opacity(0.7))
        } else {
            return effectiveColorScheme == .dark ? .white.opacity(0.7) : .primary.opacity(0.7)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tag) { tab in
                Button(action: {
                    handleTabTap(tab: tab)
                }) {
                    TabBarItem(
                        icon: tab.icon,
                        title: tab.title,
                        isSelected: selectedTab == tab.tag,
                        selectedColor: selectedIconColor,
                        unselectedColor: unselectedIconColor
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 330, height: 70)
        .background {
            RoundedRectangle(cornerRadius: 35)
                .fill(.ultraThinMaterial)
                .glassEffect()
                .shadow(color: .black.opacity(0.25), radius: 15, x: 0, y: 8)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
        .animation(.easeInOut(duration: 0.3), value: themeManager.currentTheme)
        .animation(.easeInOut(duration: 0.3), value: mapStyle)
    }
    
    private func handleTabTap(tab: (icon: String, title: String, tag: Int)) {
        if tab.tag == 2 || tab.tag == 3 {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = tab.tag
            }
        } else if tab.tag == 0 {
            if selectedTab == 0 {
                onMapTabTapped()
            } else {
                guard !isTransitioning else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = tab.tag
                }
            }
        } else {
            guard !isTransitioning else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab.tag
            }
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let selectedColor: Color
    let unselectedColor: Color
    
    @EnvironmentObject var fontManager: FontManager
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isSelected ? selectedColor : unselectedColor)
                .scaleEffect(isSelected ? 1.05 : 1.0)
            
            Text(title)
                .font(fontManager.font(.caption2, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? selectedColor : unselectedColor)
        }
        .frame(width: 80, height: 50)
    }
}
