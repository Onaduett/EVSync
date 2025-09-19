//
//  DetailChips.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

// MARK: - Detail Chip
struct DetailChip: View {
    let icon: String
    let text: String
    let color: Color
    @StateObject private var fontManager = FontManager.shared
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
            
            Text(text)
                .customFont(.footnote, weight: .bold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Price Chip
struct PriceChip: View {
    let text: String
    let languageManager: LanguageManager
    @StateObject private var fontManager = FontManager.shared
    
    var body: some View {
        HStack(spacing: 0) {
            Text(text.replacingOccurrences(of: "/kWh", with: ""))
                .customFont(.footnote, weight: .bold)
                .foregroundColor(.primary)
            
            Text("/\(languageManager.localizedString("kwh"))")
                .customFont(.footnote, weight: .bold)
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.15))
        .clipShape(Capsule())
    }
}