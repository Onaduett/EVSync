//
//  SettingsView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var fontManager: FontManager
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("locationEnabled") private var locationEnabled = false
    @State private var showingPrivacyLegal = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 20)
                            
                            UserProfileSection()
                            
                            VStack(spacing: 16) {
                                AppearanceSettingsSection()
                                
                                PreferencesSettingsSection(locationEnabled: $locationEnabled)
                                
                                PrivacyLegalSettingsSection(showingPrivacyLegal: $showingPrivacyLegal)
                                
                                AboutSettingsSection()
                            }
                            
                            SettingsFooter()
                        }
                        .padding(.top, 20)
                    }
                }
                
                SettingsGradientOverlay()
                SettingsHeader()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showingPrivacyLegal) {
            PrivacyLegalView()
                .environmentObject(fontManager)
        }
    }
}

#Preview {
    SettingsView.PreviewWrapper()
}

extension SettingsView {
    struct PreviewWrapper: View {
        @StateObject private var authManager = AuthenticationManager()
        @StateObject private var themeManager = ThemeManager()
        @StateObject private var languageManager = LanguageManager()
        @StateObject private var fontManager = FontManager.shared
        
        var body: some View {
            SettingsView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .environmentObject(languageManager)
                .environmentObject(fontManager)
                .onAppear {
                    authManager.isAuthenticated = true
                }
        }
    }
}
