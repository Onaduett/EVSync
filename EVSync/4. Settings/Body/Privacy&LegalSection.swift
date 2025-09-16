//
//  PrivacyLegalSettingsSection.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct PrivacyLegalSettingsSection: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var showingPrivacyLegal: Bool
    
    var body: some View {
        SettingsSection(
            title: languageManager.localizedString("privacy_legal", comment: "Privacy & Legal"),
            icon: "lock.shield.fill"
        ) {
            Button(action: {
                showingPrivacyLegal = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(languageManager.localizedString("privacy_legal", comment: "Privacy & Legal"))
                            .font(.custom("Nunito Sans", size: 16).weight(.medium))
                            .foregroundColor(.primary)
                        Text(languageManager.localizedString("privacy_policy_subtitle", comment: "Read our privacy policy"))
                            .font(.custom("Nunito Sans", size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}