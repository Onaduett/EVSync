//
//  FavoriteHeader.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

// MARK: - Custom Header
struct FavoriteHeader: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager // Changed to @EnvironmentObject
    
    var body: some View {
        HStack {
            Text("Charge&Go")
                .font(.custom("Lexend-SemiBold", size: 20))
                .foregroundColor(brandColor)
            
            Spacer()
            
            Text(languageManager.localizedString("favorites_title"))
                .font(.custom("Nunito Sans", size: 20).weight(.bold))
                .foregroundColor(titleColor)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    // MARK: - Theme-based colors
    private var brandColor: Color {
        return .gray
    }
    
    private var titleColor: Color {
        switch themeManager.currentTheme {
        case .light:
            return .black
        case .dark:
            return .white
        case .auto:
            return Color.primary
        }
    }
}
