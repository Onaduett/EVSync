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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Card
                    VStack(spacing: 16) {
                        // Avatar placeholder
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(authManager.user?.email?.prefix(1).uppercased() ?? "U"))
                                    .font(.custom("Nunito Sans", size: 32).weight(.bold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 6) {
                            Text("Account")
                                .font(.custom("Nunito Sans", size: 18).weight(.bold))
                                .foregroundColor(.white)
                            
                            Text(authManager.user?.email ?? "user@example.com")
                                .font(.custom("Nunito Sans", size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        // Sign Out Button
                        Button(action: {
                            authManager.signOut()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Sign Out")
                                    .font(.custom("Nunito Sans", size: 14).weight(.medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                    )
                    .padding(.horizontal, 20)
                    
                    // Settings Sections
                    VStack(spacing: 16) {
                        // Appearance
                        SettingsSection(title: "Appearance", icon: "paintbrush.fill") {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Theme")
                                        .font(.custom("Nunito Sans", size: 14).weight(.medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                HStack(spacing: 8) {
                                    ForEach(ThemeManager.AppTheme.allCases, id: \.rawValue) { theme in
                                        ThemeButton(
                                            title: theme.name,
                                            isSelected: themeManager.currentTheme == theme
                                        ) {
                                            themeManager.setTheme(theme)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Preferences
                        SettingsSection(title: "Preferences", icon: "slider.horizontal.3") {
                            VStack(spacing: 0) {
                                PreferenceRow(
                                    title: "Notifications",
                                    subtitle: "Get alerts for charging status",
                                    isOn: $notificationsEnabled,
                                    showDivider: true
                                )
                                
                                PreferenceRow(
                                    title: "Location Services",
                                    subtitle: "Find nearby charging stations",
                                    isOn: $locationEnabled,
                                    showDivider: false
                                )
                            }
                        }
                        
                        // Map Settings
                        SettingsSection(title: "Map", icon: "map.fill") {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Map Type")
                                        .font(.custom("Nunito Sans", size: 14).weight(.medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                HStack(spacing: 6) {
                                    ForEach(0..<mapTypes.count, id: \.self) { index in
                                        MapTypeButton(
                                            title: mapTypes[index],
                                            isSelected: selectedMapType == index
                                        ) {
                                            selectedMapType = index
                                        }
                                    }
                                }
                            }
                        }
                        
                        // About
                        SettingsSection(title: "About", icon: "info.circle.fill") {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Version")
                                        .font(.custom("Nunito Sans", size: 14).weight(.medium))
                                        .foregroundColor(.white)
                                    Text("Current app version")
                                        .font(.custom("Nunito Sans", size: 12))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text("1.0.0")
                                    .font(.custom("Nunito Sans", size: 14).weight(.medium))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
}

// MARK: - Supporting Views
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(title)
                    .font(.custom("Nunito Sans", size: 16).weight(.semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                content
                    .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .padding(.horizontal, 20)
        }
    }
}

struct ThemeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Nunito Sans", size: 12).weight(.medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.teal : Color.white.opacity(0.1))
                )
        }
    }
}

struct MapTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Nunito Sans", size: 11).weight(.medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.teal : Color.white.opacity(0.1))
                )
        }
    }
}

struct PreferenceRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let showDivider: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("Nunito Sans", size: 14).weight(.medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.custom("Nunito Sans", size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .toggleStyle(SwitchToggleStyle(tint: Color.teal))
                    .scaleEffect(0.8)
            }
            .padding(.vertical, 12)
            
            if showDivider {
                Divider()
                    .background(Color.white.opacity(0.1))
            }
        }
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
