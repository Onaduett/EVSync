//
//  InfoRowComponents.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

struct InfoRow: View {
    @Environment(\.fontManager) var fontManager
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.primary)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(fontManager.font(.caption, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(fontManager.font(.subheadline, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

// MARK: - InfoRowWithChip Component
struct InfoRowWithChip: View {
    let icon: String
    let title: String
    let chipIcon: String
    let chipText: String
    let chipColor: Color
    @StateObject private var fontManager = FontManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 16)
                
                Text(title)
                    .customFont(.footnote, weight: .semibold)
                    .foregroundColor(.secondary)
            }
            
            DetailChip(icon: chipIcon, text: chipText, color: chipColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - InfoRowWithPriceChip Component
struct InfoRowWithPriceChip: View {
    let icon: String
    let title: String
    let priceText: String
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var fontManager = FontManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 16)
                
                Text(title)
                    .customFont(.footnote, weight: .semibold)
                    .foregroundColor(.secondary)
            }
            
            PriceChip(text: priceText, languageManager: languageManager)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
