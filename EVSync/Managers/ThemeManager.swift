//
//  ThemeManager.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI
import Foundation

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .auto {
        didSet {
            userDefaults.set(currentTheme.rawValue, forKey: themeKey)
            
            objectWillChange.send()
        }
    }
    
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
            if let savedThemeValue = userDefaults.object(forKey: themeKey) as? Int,
               let savedTheme = AppTheme(rawValue: savedThemeValue) {
                self.currentTheme = savedTheme
            } else {
                self.currentTheme = .auto
            }
        }
    
    func setTheme(_ theme: AppTheme) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.currentTheme = theme
            }
        }
    }
}
