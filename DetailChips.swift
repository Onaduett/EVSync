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
    let id: String? // Опциональный идентификатор для matchedGeometryEffect
    let namespace: Namespace.ID?
    @StateObject private var fontManager = FontManager.shared
    
    // Инициализатор с matchedGeometryEffect
    init(icon: String, text: String, color: Color, id: String, namespace: Namespace.ID) {
        self.icon = icon
        self.text = text
        self.color = color
        self.id = id
        self.namespace = namespace
    }
    
    // Инициализатор без matchedGeometryEffect (для обратной совместимости)
    init(icon: String, text: String, color: Color) {
        self.icon = icon
        self.text = text
        self.color = color
        self.id = nil
        self.namespace = nil
    }
    
    var body: some View {
        let chipView = HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
            
            Text(text)
                .customFont(.footnote, weight: .bold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
        
        // Применяем matchedGeometryEffect только если есть id и namespace
        if let id = id, let namespace = namespace {
            chipView.matchedGeometryEffect(id: id, in: namespace)
        } else {
            chipView
        }
    }
}

// MARK: - Price Chip
struct PriceChip: View {
    let text: String
    let languageManager: LanguageManager
    let id: String? // Опциональный идентификатор для matchedGeometryEffect
    let namespace: Namespace.ID?
    @StateObject private var fontManager = FontManager.shared
    
    // Инициализатор с matchedGeometryEffect
    init(text: String, languageManager: LanguageManager, id: String, namespace: Namespace.ID) {
        self.text = text
        self.languageManager = languageManager
        self.id = id
        self.namespace = namespace
    }
    
    // Инициализатор без matchedGeometryEffect (для обратной совместимости)
    init(text: String, languageManager: LanguageManager) {
        self.text = text
        self.languageManager = languageManager
        self.id = nil
        self.namespace = nil
    }
    
    var body: some View {
        let chipView = HStack(spacing: 0) {
            Text(text.replacingOccurrences(of: "/kWh", with: ""))
                .customFont(.footnote, weight: .bold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            
            Text("/\(languageManager.localizedString("kwh"))")
                .customFont(.footnote, weight: .bold)
                .foregroundColor(.blue)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.15))
            .clipShape(Capsule())
        
        // Применяем matchedGeometryEffect только если есть id и namespace
        if let id = id, let namespace = namespace {
            chipView.matchedGeometryEffect(id: id, in: namespace)
        } else {
            chipView
        }
    }
}
