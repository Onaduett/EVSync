//
//  AboutSettingsSection.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct AboutSettingsSection: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        SettingsSection(
            title: languageManager.localizedString("about", comment: "About"),
            icon: "info.circle.fill"
        ) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(languageManager.localizedString("version", comment: "Version"))
                        .customFont(.callout, weight: .medium)
                        .foregroundColor(.primary)
                    Text(languageManager.localizedString("version_subtitle", comment: "Current app version"))
                        .customFont(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("1.1.0")
                    .customFont(.callout, weight: .medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.primary.opacity(0.1))
                    )
            }
        }
    }
}
