//
//  ThemeManager.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI
import Foundation

// Theme Manager to handle app-wide theme changes
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .auto
    
    enum AppTheme: Int, CaseIterable {
        case light = 0
        case dark = 1
        case auto = 2
        
        var name: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .auto: return "Auto"
            }
        }
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .auto: return nil // Uses system setting
            }
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"
    
    init() {
        // Load saved theme preference
        let savedTheme = userDefaults.integer(forKey: themeKey)
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .auto
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        userDefaults.set(theme.rawValue, forKey: themeKey)
    }
}
