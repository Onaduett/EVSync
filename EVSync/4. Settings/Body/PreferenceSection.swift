//
//  PreferencesSettingsSection.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct PreferencesSettingsSection: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var locationEnabled: Bool
    
    var body: some View {
        SettingsSection(
            title: languageManager.localizedString("preferences", comment: "Preferences"),
            icon: "slider.horizontal.3"
        ) {
            VStack(spacing: 0) {
                PreferenceRow(
                    title: languageManager.localizedString("location_services", comment: "Location Services"),
                    subtitle: languageManager.localizedString("location_services_subtitle", comment: "Find charging stations"),
                    isOn: $locationEnabled,
                    showDivider: true
                )
                
                // Language Selector
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(languageManager.localizedString("language", comment: "Language"))
                                .customFont(.callout, weight: .medium)
                                .foregroundColor(.primary)
                            
                            Text(languageManager.localizedString("language_subtitle", comment: "Choose your preferred language"))
                                .customFont(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            ForEach(LanguageManager.AppLanguage.allCases, id: \.rawValue) { language in
                                LanguageButton(
                                    language: language,
                                    isSelected: languageManager.currentLanguage == language,
                                    languageManager: languageManager
                                )
                            }
                        }
                    }
                    .padding(.vertical, 14)
                }
            }
        }
    }
}
