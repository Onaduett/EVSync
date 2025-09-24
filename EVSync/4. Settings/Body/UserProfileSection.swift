//
//  UserProfileSection.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct UserProfileSection: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingDeleteAccountAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color.primary.opacity(0.15))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String(authManager.user?.email?.prefix(1).uppercased() ?? "GO"))
                        .customFont(.largeTitle, weight: .bold)
                        .foregroundColor(.primary)
                )
            
            VStack(spacing: 6) {
                Text(languageManager.localizedString("account", comment: "Account"))
                    .customFont(.headline)
                    .foregroundColor(.primary)
                
                Text(authManager.user?.email ?? "user@example.com")
                    .customFont(.footnote)
                    .foregroundColor(.secondary)
            }
            
            // Buttons in horizontal layout
            HStack(spacing: 12) {
                // Sign Out Button
                Button(action: {
                    authManager.signOut()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14, weight: .medium))
                        Text(languageManager.localizedString("sign_out", comment: "Sign Out"))
                            .customFont(.footnote, weight: .medium)
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Delete Account Button
                Button(action: {
                    showingDeleteAccountAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                        Text(languageManager.localizedString("delete_account", comment: "Delete Account"))
                            .customFont(.footnote, weight: .medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                .disabled(authManager.isLoading)
            }
            
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .customFont(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.05))
        )
        .padding(.horizontal, 20)
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                authManager.deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.")
        }
    }
}

#Preview {
    UserProfileSection()
        .environmentObject(AuthenticationManager())
        .environmentObject(LanguageManager())
}
