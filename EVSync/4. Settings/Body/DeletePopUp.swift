//
//  DeletePopUp.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 24.09.25.
//

import SwiftUI

struct DeleteAccountPopup: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "trash")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                
                Text(languageManager.localizedString("delete_account", comment: "Delete Account"))
                    .customFont(.title2, weight: .bold)
                    .foregroundColor(.primary)
                
                Text(languageManager.localizedString("delete_account_subtitle", comment: "This action cannot be undone"))
                    .customFont(.subheadline, weight: .medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
            
            // Description boxes
            VStack(spacing: 9) {
                // First box - main description
                VStack(alignment: .leading, spacing: 0) {
                    Text(languageManager.localizedString("delete_account_description", comment: "Once you delete your account, you will lose access to all data and features of the app. This action is irreversible."))
                        .customFont(.body, weight: .medium)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary.opacity(0.05))
                )
                
                // Second box - what will be deleted title + list
                VStack(alignment: .leading, spacing: 16) {
                    Text(languageManager.localizedString("what_will_be_deleted", comment: "What exactly will be deleted:"))
                        .customFont(.body, weight: .medium)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        LossItem(
                            icon: "heart.fill",
                            text: languageManager.localizedString("lose_favorite_stations", comment: "Your **favorite stations** the list will no longer be available."),
                            color: .teal
                        )
                        
                        LossItem(
                            icon: "map.fill",
                            text: languageManager.localizedString("lose_charging_map", comment: "The entire **charging map linked to your profile**."),
                            color: .teal
                        )
                        
                        LossItem(
                            icon: "gearshape.fill",
                            text: languageManager.localizedString("lose_settings", comment: "Your **settings and personalization** (theme, language, notifications, etc.)."),
                            color: .teal
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary.opacity(0.05))
                )
                
                // Third box - warning
                VStack(alignment: .leading, spacing: 0) {
                    Text(languageManager.localizedString("delete_account_warning", comment: "After confirmation, we will completely delete your account and all related data from the system. Nothing will be kept, and it will not be possible to recover any information."))
                        .customFont(.subheadline, weight: .medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary.opacity(0.05))
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    authManager.deleteAccount()
                    isPresented = false
                }) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        Text(languageManager.localizedString("see_you_again_then", comment: "Delete Account"))
                            .customFont(.callout, weight: .semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red)
                    )
                }
                .disabled(authManager.isLoading)
                
                Button(action: {
                    isPresented = false
                }) {
                    Text(languageManager.localizedString("cancel", comment: "Cancel"))
                        .customFont(.callout, weight: .medium)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct LossItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .customFont(.subheadline, weight: .medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

#Preview {
    DeleteAccountPopup(isPresented: .constant(true))
        .environmentObject(AuthenticationManager())
        .environmentObject(LanguageManager())
}
