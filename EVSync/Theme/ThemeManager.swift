//
//  ThemeManager.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var selectedTheme: AppTheme = .auto
    @AppStorage("selected_theme") private var storedTheme: String = "auto"
    
    init() {
        selectedTheme = AppTheme(rawValue: storedTheme) ?? .auto
    }
    
    func setTheme(_ theme: AppTheme) {
        selectedTheme = theme
        storedTheme = theme.rawValue
    }
    
    func currentColorScheme(for environment: ColorScheme) -> ColorScheme? {
        switch selectedTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .auto:
            return nil // Follows system
        }
    }
}

// MARK: - App Theme Enum
enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case auto = "auto"
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .auto: return "Auto"
        }
    }
}

// MARK: - Theme Colors
struct AppColors {
    // Glass Effect Colors
    static func glassBackground(for colorScheme: ColorScheme) -> some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.white.opacity(0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.25),
                        Color.white.opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    static func glassBorder(for colorScheme: ColorScheme) -> some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.3),
                        Color.white.opacity(0.05),
                        Color.white.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.8),
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    // Tab Bar Colors
    static func tabBarSelectedColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : .white
    }
    
    static func tabBarUnselectedColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white.opacity(0.6) : .white.opacity(0.7)
    }
    
    // Shadow Colors
    static func primaryShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .black.opacity(0.4) : .black.opacity(0.25)
    }
    
    static func secondaryShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .black.opacity(0.2) : .black.opacity(0.1)
    }
    
    // Material Types
    static func glassMaterial(for colorScheme: ColorScheme) -> Material {
        colorScheme == .dark ? .thinMaterial : .regularMaterial
    }
}

// MARK: - Glass Effect Extension (Updated)
extension View {
    func dynamicGlassEffect(colorScheme: ColorScheme, cornerRadius: CGFloat = 35) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppColors.glassMaterial(for: colorScheme))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(AppColors.glassBackground(for: colorScheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(AppColors.glassBorder(for: colorScheme), lineWidth: 1.2)
                    )
                    .shadow(
                        color: AppColors.primaryShadow(for: colorScheme),
                        radius: 15, x: 0, y: 8
                    )
                    .shadow(
                        color: AppColors.secondaryShadow(for: colorScheme),
                        radius: 3, x: 0, y: 1
                    )
            }
    }
    
    // Convenience method for glass effect without passing colorScheme manually
    func adaptiveGlassEffect(cornerRadius: CGFloat = 35) -> some View {
        AdaptiveGlassView(cornerRadius: cornerRadius) {
            self
        }
    }
}

// MARK: - Adaptive Glass View
struct AdaptiveGlassView<Content: View>: View {
    let cornerRadius: CGFloat
    let content: () -> Content
    @Environment(\.colorScheme) var colorScheme
    
    init(cornerRadius: CGFloat = 35, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content
    }
    
    var body: some View {
        content()
            .dynamicGlassEffect(colorScheme: colorScheme, cornerRadius: cornerRadius)
    }
}

// MARK: - Theme-Aware Components
struct ThemedText: View {
    let text: String
    let style: Font
    let isSelected: Bool
    @Environment(\.colorScheme) var colorScheme
    
    init(_ text: String, style: Font = .body, isSelected: Bool = false) {
        self.text = text
        self.style = style
        self.isSelected = isSelected
    }
    
    var body: some View {
        Text(text)
            .font(style)
            .foregroundColor(
                isSelected
                ? AppColors.tabBarSelectedColor(for: colorScheme)
                : AppColors.tabBarUnselectedColor(for: colorScheme)
            )
    }
}

struct ThemedIcon: View {
    let systemName: String
    let size: CGFloat
    let weight: Font.Weight
    let isSelected: Bool
    @Environment(\.colorScheme) var colorScheme
    
    init(systemName: String, size: CGFloat = 20, weight: Font.Weight = .medium, isSelected: Bool = false) {
        self.systemName = systemName
        self.size = size
        self.weight = weight
        self.isSelected = isSelected
    }
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: weight))
            .foregroundColor(
                isSelected
                ? AppColors.tabBarSelectedColor(for: colorScheme)
                : AppColors.tabBarUnselectedColor(for: colorScheme)
            )
    }
}
