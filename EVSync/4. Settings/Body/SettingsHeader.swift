//
//  SettingsHeader.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

// MARK: - Settings Header Components
struct SettingsGradientOverlay: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.teal, location: 0.0),
                .init(color: Color.teal.opacity(0.1), location: 0.0),
                .init(color: .clear, location: 0.5)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 120)
        .ignoresSafeArea(edges: .top)
    }
}

struct SettingsHeader: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        HStack {
            Text("Charge&Go")
                .font(.custom("Lexend-SemiBold", size: 20))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(languageManager.localizedString("account", comment: "Account"))
                .font(.custom("NT Somic", size: 20).weight(.bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}
