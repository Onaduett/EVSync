//
//  SettingsView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

// MARK: - Settings Gradient Overlay
struct SettingsGradientOverlay: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.teal, location: 0.0),
                .init(color: Color.teal.opacity(0.3), location: 0.0),
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
                .font(.custom("Nunito Sans", size: 20).weight(.bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
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
                            
                            VStack(spacing: 16) {
                                Circle()
                                    .fill(Color.primary.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text(String(authManager.user?.email?.prefix(1).uppercased() ?? "GO"))
                                            .font(.custom("Nunito Sans", size: 32).weight(.bold))
                                            .foregroundColor(.primary)
                                    )
                                
                                VStack(spacing: 6) {
                                    Text(languageManager.localizedString("account", comment: "Account"))
                                        .font(.custom("Nunito Sans", size: 18).weight(.bold))
                                        .foregroundColor(.primary)
                                    
                                    Text(authManager.user?.email ?? "user@example.com")
                                        .font(.custom("Nunito Sans", size: 14))
                                        .foregroundColor(.secondary)
                                }
                                
                                // Sign Out Button
                                Button(action: {
                                    authManager.signOut()
                                }) {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .font(.system(size: 14, weight: .medium))
                                        Text(languageManager.localizedString("sign_out", comment: "Sign Out"))
                                            .font(.custom("Nunito Sans", size: 14).weight(.medium))
                                    }
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.vertical, 24)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.primary.opacity(0.05))
                            )
                            .padding(.horizontal, 20)
                            
                            // Settings Sections
                            VStack(spacing: 16) {
                                // Appearance
                                SettingsSection(
                                    title: languageManager.localizedString("appearance", comment: "Appearance"),
                                    icon: "paintbrush.fill"
                                ) {
                                    VStack(spacing: 12) {
                                        HStack {
                                            Text(languageManager.localizedString("theme", comment: "Theme"))
                                                .font(.custom("Nunito Sans", size: 16).weight(.medium))
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        
                                        HStack(spacing: 8) {
                                            ForEach(ThemeManager.AppTheme.allCases, id: \.rawValue) { theme in
                                                ThemeButton(
                                                    title: getThemeName(for: theme),
                                                    isSelected: themeManager.currentTheme == theme,
                                                    themeManager: themeManager,
                                                    theme: theme
                                                )
                                            }
                                        }
                                    }
                                }
                                
                                // Preferences
                                SettingsSection(
                                    title: languageManager.localizedString("preferences", comment: "Preferences"),
                                    icon: "slider.horizontal.3"
                                ) {
                                    VStack(spacing: 0) {
                                        
                                        PreferenceRow(
                                            title: languageManager.localizedString("location_services", comment: "Location Services"),
                                            subtitle: languageManager.localizedString("location_services_subtitle", comment: "Find nearby charging stations"),
                                            isOn: $locationEnabled,
                                            showDivider: true
                                        )
                                        
                                        // Language Selector
                                        VStack(spacing: 0) {
                                            HStack(spacing: 12) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(languageManager.localizedString("language", comment: "Language"))
                                                        .font(.custom("Nunito Sans", size: 16).weight(.medium))
                                                        .foregroundColor(.primary)
                                                    
                                                    Text(languageManager.localizedString("language_subtitle", comment: "Choose your preferred language"))
                                                        .font(.custom("Nunito Sans", size: 14))
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                Spacer()
                                                
                                                HStack(spacing: 8) {
                                                    ForEach(LanguageManager.AppLanguage.allCases, id: \.rawValue) { language in
                                                        LanguageButton(
                                                            language: language,
                                                            isSelected: languageManager.currentLanguage == language,
                                                            languageManager: languageManager
                                                        )
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 14)
                                        }
                                    }
                                }
                                
                                // Privacy & Legal
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
                                
                                // About
                                SettingsSection(
                                    title: languageManager.localizedString("about", comment: "About"),
                                    icon: "info.circle.fill"
                                ) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(languageManager.localizedString("version", comment: "Version"))
                                                .font(.custom("Nunito Sans", size: 16).weight(.medium))
                                                .foregroundColor(.primary)
                                            Text(languageManager.localizedString("version_subtitle", comment: "Current app version"))
                                                .font(.custom("Nunito Sans", size: 14))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("1.0.0")
                                            .font(.custom("Nunito Sans", size: 16).weight(.medium))
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.primary.opacity(0.1))
                                            )
                                    }
                                }
                            }
                            
                            // Footer Section
                            VStack(spacing: 4) {
                                Text("© Developed by Daulét Yerkinov")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("2025 | Based in Almaty")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 16)
                            .padding(.bottom, 20)
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
        }
    }
    
    private func getThemeName(for theme: ThemeManager.AppTheme) -> String {
        switch theme {
        case .light:
            return languageManager.localizedString("light", comment: "Light")
        case .dark:
            return languageManager.localizedString("dark", comment: "Dark")
        case .auto:
            return languageManager.localizedString("system", comment: "System")
        }
    }
    
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
                        .foregroundColor(.secondary)
                    
                    Text(title)
                        .font(.custom("Nunito Sans", size: 16).weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                VStack(spacing: 0) {
                    content
                        .padding(16)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary.opacity(0.05))
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    struct ThemeButton: View {
        let title: String
        let isSelected: Bool
        let themeManager: ThemeManager
        let theme: ThemeManager.AppTheme
        
        var body: some View {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    themeManager.setTheme(theme)
                }
            }) {
                Text(title)
                    .font(.custom("Nunito Sans", size: 13).weight(.medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.teal : Color.primary.opacity(0.1))
                    )
            }
        }
    }
    
    struct LanguageButton: View {
        let language: LanguageManager.AppLanguage
        let isSelected: Bool
        let languageManager: LanguageManager
        
        var body: some View {
            Button(action: {
                if language != languageManager.currentLanguage {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        languageManager.setLanguage(language)
                    }
                }
            }) {
                VStack(spacing: 4) {
                    Text(language.flag)
                        .font(.system(size: 16))
                    
                    Text(language.shortName)
                        .font(.custom("Nunito Sans", size: 10).weight(.medium))
                        .foregroundColor(isSelected ? .white : .primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.teal : Color.primary.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.teal : Color.clear, lineWidth: 2)
                        )
                )
            }
            .disabled(isSelected)
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.custom("Nunito Sans", size: 16).weight(.medium))
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.custom("Nunito Sans", size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $isOn)
                        .toggleStyle(SwitchToggleStyle(tint: Color.teal))
                        .scaleEffect(0.9)
                }
                .padding(.vertical, 14)
                
                if showDivider {
                    Divider()
                        .background(Color.primary.opacity(0.1))
                }
            }
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
        
        var body: some View {
            SettingsView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .environmentObject(languageManager)
                .onAppear {
                    authManager.isAuthenticated = true
                }
        }
    }
}
