//
//  SettingsButtons.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct ThemeButton: View {
    let title: String
    let isSelected: Bool
    let themeManager: ThemeManager
    let theme: ThemeManager.AppTheme
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                themeManager.setTheme(theme)
            }
        }) {
            Text(title)
                .font(.custom("Nunito Sans", size: 13).weight(.medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.teal : Color.primary.opacity(0.1))
                )
        }
    }
}

struct LanguageButton: View {
    let language: LanguageManager.AppLanguage
    let isSelected: Bool
    let languageManager: LanguageManager
    
    var body: some View {
        Button(action: {
            if language != languageManager.currentLanguage {
                withAnimation(.easeInOut(duration: 0.3)) {
                    languageManager.setLanguage(language)
                }
            }
        }) {
            VStack(spacing: 4) {
                Text(language.flag)
                    .font(.system(size: 16))
                
                Text(language.shortName)
                    .font(.custom("Nunito Sans", size: 10).weight(.medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.teal : Color.primary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.teal : Color.clear, lineWidth: 2)
                    )
            )
        }
        .disabled(isSelected)
    }
}