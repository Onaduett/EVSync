//
//  FavoriteHeader.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

// MARK: - Custom Header
struct FavoriteHeader: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        HStack {
            Text("Charge&Go")
                .font(.custom("Lexend-SemiBold", size: 20))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(languageManager.localizedString("favorites_title"))
                .font(.custom("Nunito Sans", size: 20).weight(.bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}