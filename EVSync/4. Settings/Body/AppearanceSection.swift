//
//  AppearanceSettingsSection.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct AppearanceSettingsSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        SettingsSection(
            title: languageManager.localizedString("appearance", comment: "Appearance"),
            icon: "paintbrush.fill"
        ) {
            VStack(spacing: 12) {
                HStack {
                    Text(languageManager.localizedString("theme", comment: "Theme"))
                        .customFont(.callout, weight: .medium)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    ForEach(ThemeManager.AppTheme.allCases, id: \.rawValue) { theme in
                        ThemeButton(
                            title: getThemeName(for: theme),
                            isSelected: themeManager.currentTheme == theme,
                            themeManager: themeManager,
                            theme: theme
                        )
                    }
                }
            }
        }
    }
    
    private func getThemeName(for theme: ThemeManager.AppTheme) -> String {
        switch theme {
        case .light:
            return languageManager.localizedString("light", comment: "Light")
        case .dark:
            return languageManager.localizedString("dark", comment: "Dark")
        case .auto:
            return languageManager.localizedString("system", comment: "System")
        }
    }
}
