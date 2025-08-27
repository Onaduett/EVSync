//
//  MainContentView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct MainContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                NavigationBar()
            } else {
                WelcomeView()
            }
        }
        .environmentObject(authManager)
    }
}

#Preview {
    MainContentView()
}
