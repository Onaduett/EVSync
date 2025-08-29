//
//  SettingsView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct SettingsHeader: View {
    var body: some View {
        HStack {
            Text("Charge&Go")
                .font(.custom("Nunito Sans", size: 20).weight(.bold))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text("Settings")
                .font(.custom("Nunito Sans", size: 20).weight(.bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("locationEnabled") private var locationEnabled = false
    @AppStorage("selectedMapType") private var selectedMapType = 0
    
    let mapTypes = ["Standard", "Satellite", "Hybrid"]
    
    var body: some View {
        VStack(spacing: 0) {
            SettingsHeader()
            
            Form {
                Section("Account") {
                    if let user = authManager.user {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email ?? "N/A")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        authManager.signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { themeManager.currentTheme.rawValue },
                        set: { newValue in
                            if let theme = ThemeManager.AppTheme(rawValue: newValue) {
                                themeManager.setTheme(theme)
                            }
                        }
                    )) {
                        ForEach(ThemeManager.AppTheme.allCases, id: \.rawValue) { theme in
                            Text(theme.name).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("General") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Location Services", isOn: $locationEnabled)
                }
                
                Section("Map Settings") {
                    Picker("Map Type", selection: $selectedMapType) {
                        ForEach(0..<mapTypes.count, id: \.self) { index in
                            Text(mapTypes[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
}

#Preview {
    PreviewWrapper()
}

struct PreviewWrapper: View {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        SettingsView()
            .environmentObject(authManager)
            .environmentObject(themeManager)
            .onAppear {
                authManager.isAuthenticated = true
            }
    }
}
