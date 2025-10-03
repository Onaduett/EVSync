//
//  FontManager.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 16.09.25.
//

import SwiftUI

class FontManager: ObservableObject {
    static let shared = FontManager()
    
    private let primaryFontFamily = "NT Somic"
    
    enum FontWeight {
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        
        var swiftUIWeight: Font.Weight {
            switch self {
            case .light: return .regular
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .medium
            case .bold: return .bold
            case .heavy: return .bold
            }
        }
        
        var uiKitWeight: UIFont.Weight {
            switch self {
            case .light: return .regular
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .medium
            case .bold: return .bold
            case .heavy: return .bold
            }
        }
    }
    
    enum Typography {
        case largeTitle    // 34pt
        case title         // 28pt
        case title2        // 22pt
        case title3        // 20pt
        case headline      // 17pt, semibold
        case body          // 17pt
        case callout       // 16pt
        case subheadline   // 15pt
        case footnote      // 13pt
        case caption       // 12pt
        case caption2      // 11pt
        
        var size: CGFloat {
            switch self {
            case .largeTitle: return 34
            case .title: return 28
            case .title2: return 22
            case .title3: return 20
            case .headline: return 17
            case .body: return 17
            case .callout: return 16
            case .subheadline: return 15
            case .footnote: return 13
            case .caption: return 12
            case .caption2: return 11
            }
        }
        
        var defaultWeight: FontWeight {
            switch self {
            case .largeTitle, .title, .title2, .title3: return .bold
            case .headline: return .bold
            case .body, .callout, .subheadline: return .regular
            case .footnote, .caption, .caption2: return .regular
            }
        }
    }
    
    private init() {}
    
    // MARK: - Font Creation Methods
    
    func font(_ typography: Typography, weight: FontWeight? = nil) -> Font {
        let fontWeight = weight ?? typography.defaultWeight
        return Font.custom(primaryFontFamily, size: typography.size).weight(fontWeight.swiftUIWeight)
    }
    
    func uiFont(_ typography: Typography, weight: FontWeight? = nil) -> UIFont {
        let fontWeight = weight ?? typography.defaultWeight
        return UIFont(name: primaryFontFamily, size: typography.size)?.withWeight(fontWeight.uiKitWeight) ??
               UIFont.systemFont(ofSize: typography.size, weight: fontWeight.uiKitWeight)
    }
    

    func isCustomFontAvailable() -> Bool {
        return UIFont(name: primaryFontFamily, size: 17) != nil
    }
    
    func availableFontNames() -> [String] {
        return UIFont.fontNames(forFamilyName: primaryFontFamily)
    }
    
    func printAvailableFonts() {
        print("Available fonts for \(primaryFontFamily):")
        availableFontNames().forEach { print("- \($0)") }
    }
}

// MARK: - UIFont Extension
extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

// MARK: - Font Environment Key
struct FontManagerKey: EnvironmentKey {
    static let defaultValue = FontManager.shared
}

extension EnvironmentValues {
    var fontManager: FontManager {
        get { self[FontManagerKey.self] }
        set { self[FontManagerKey.self] = newValue }
    }
}

// MARK: - View Extension for Easy Access
extension View {
    func fontManagerEnvironment() -> some View {
        self.environmentObject(FontManager.shared)
    }
}

// MARK: - Text Extension for Convenient Font Application
extension Text {
    func customFont(_ typography: FontManager.Typography, weight: FontManager.FontWeight? = nil) -> Text {
        self.font(FontManager.shared.font(typography, weight: weight))
    }
}
