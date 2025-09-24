//
//  DeleteAccountSection.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 24.09.25.
//

import SwiftUI

struct DeleteAccountSection: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingDeleteAccountPopup = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                showingDeleteAccountPopup = true
            }) {
                HStack {
                    Text(languageManager.localizedString("delete_account", comment: "Delete Account"))
                        .customFont(.callout, weight: .medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary.opacity(0.6))
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                .contentShape(Rectangle())
            }
            .disabled(authManager.isLoading)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.05))
        )
        .padding(.horizontal, 20)
        .sheet(isPresented: $showingDeleteAccountPopup) {
            DeleteAccountPopup(isPresented: $showingDeleteAccountPopup)
                .environmentObject(authManager)
                .environmentObject(languageManager)
        }
    }
}

#Preview {
    DeleteAccountSection()
        .environmentObject(AuthenticationManager())
        .environmentObject(LanguageManager())
}
