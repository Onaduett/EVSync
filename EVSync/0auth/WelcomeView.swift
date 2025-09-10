//
//  WelcomeView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var authState: AuthState = .enterEmail
    @State private var isCheckingUser = false
    
    enum AuthState {
        case enterEmail
        case signIn
        case signUp
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic background color
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    Spacer()
                    
                    VStack(spacing: 20) {
                        // Logo
                        Text("Charge&Go")
                            .font(.custom("Lexend-SemiBold", size: 48))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 20) {
                            Text(getAuthStateTitle())
                                .font(.custom("Nunito Sans", size: 18))
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 16) {
                                // Email Field
                                VStack(alignment: .leading, spacing: 8) {
                                    if authState != .enterEmail {
                                        Text(languageManager.localizedString("email_label"))
                                            .font(.custom("Nunito Sans", size: 14))
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 16)
                                    }
                                    
                                    TextField(getEmailPlaceholder(), text: $email)
                                        .font(.custom("Nunito Sans", size: 16))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                        .overlay(
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(.secondary.opacity(0.3))
                                                .padding(.horizontal, 16),
                                            alignment: .bottom
                                        )
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .textContentType(.emailAddress)
                                        .disabled(authState != .enterEmail)
                                }
                                
                                // Password Field (appears after email check)
                                if authState == .signIn || authState == .signUp {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(getPasswordLabel())
                                            .font(.custom("Nunito Sans", size: 14))
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 16)
                                        
                                        SecureField(languageManager.localizedString("enter_password_placeholder"), text: $password)
                                            .font(.custom("Nunito Sans", size: 16))
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 16)
                                            .overlay(
                                                Rectangle()
                                                    .frame(height: 1)
                                                    .foregroundColor(.secondary.opacity(0.3))
                                                    .padding(.horizontal, 16),
                                                alignment: .bottom
                                            )
                                            .textContentType(authState == .signUp ? .newPassword : .password)
                                        
                                        if authState == .signUp {
                                            Text(languageManager.localizedString("password_requirement"))
                                                .font(.custom("Nunito Sans", size: 12))
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 16)
                                        }
                                    }
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                }
                                
                                if authState == .signUp {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(languageManager.localizedString("confirm_password_label"))
                                            .font(.custom("Nunito Sans", size: 14))
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 16)
                                        
                                        SecureField(languageManager.localizedString("confirm_password_placeholder"), text: $confirmPassword)
                                            .font(.custom("Nunito Sans", size: 16))
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 16)
                                            .overlay(
                                                Rectangle()
                                                    .frame(height: 1)
                                                    .foregroundColor(.secondary.opacity(0.3)),
                                                alignment: .bottom
                                            )
                                            .textContentType(.newPassword)
                                        
                                        if !confirmPassword.isEmpty {
                                            HStack(spacing: 4) {
                                                Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(password == confirmPassword ? .green : .red)
                                                Text(password == confirmPassword ? languageManager.localizedString("passwords_match") : languageManager.localizedString("passwords_dont_match"))
                                                    .font(.custom("Nunito Sans", size: 12))
                                                    .foregroundColor(password == confirmPassword ? .green : .red)
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                }
                                
                                if authState == .signIn {
                                    HStack {
                                        Spacer()
                                        Button(languageManager.localizedString("forgot_password")) {
                                            authManager.resetPassword(email: email)
                                        }
                                        .font(.custom("Nunito Sans", size: 14))
                                        .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                }
                                
                                if let errorMessage = authManager.errorMessage {
                                    Text(errorMessage)
                                        .font(.custom("Nunito Sans", size: 14))
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            
                            // Continue Button
                            Button(action: handleContinue) {
                                if authManager.isLoading || isCheckingUser {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: continueButtonTextColor))
                                        .scaleEffect(0.9)
                                } else {
                                    Text(getContinueButtonText())
                                        .font(.custom("Nunito Sans", size: 16))
                                        .fontWeight(.medium)
                                        .foregroundColor(continueButtonTextColor)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(continueButtonBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .disabled(!isContinueButtonEnabled || authManager.isLoading || isCheckingUser)
                            .padding(.horizontal, 20)
                            
                            // Back button for password states
                            if authState != .enterEmail {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        resetToEmailEntry()
                                    }
                                }) {
                                    Text(languageManager.localizedString("back_to_email"))
                                        .font(.custom("Nunito Sans", size: 14))
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Social Login (only show in email state)
                            if authState == .enterEmail {
                                VStack(spacing: 16) {
                                    HStack {
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.secondary.opacity(0.3))
                                        
                                        Text(languageManager.localizedString("or_use"))
                                            .font(.custom("Nunito Sans", size: 14))
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 16)
                                        
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.secondary.opacity(0.3))
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    // Social Login Buttons
                                    HStack(spacing: 12) {
                                        // Google Sign In
                                        Button(action: {
                                            authManager.signInWithGoogle()
                                        }) {
                                            HStack(spacing: 8) {
                                                Image("google_logo")
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                                Text(languageManager.localizedString("sign_in_with_google"))
                                                    .font(.custom("Nunito Sans", size: 14))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 44)
                                            .background(Color(UIColor.systemBackground))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        
                                        // Apple Sign In
                                        Button(action: {
                                            authManager.signInWithApple()
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "applelogo")
                                                    .foregroundColor(.primary)
                                                Text(languageManager.localizedString("sign_in_with_apple"))
                                                    .font(.custom("Nunito Sans", size: 14))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 44)
                                            .background(Color(UIColor.systemBackground))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .transition(.asymmetric(
                                    insertion: .opacity,
                                    removal: .opacity
                                ))
                            }
                        }
                    }
                    .padding(.bottom, 40)
                    
                    Spacer()
                    
                    // Terms and conditions (only show in signup state)
                    if authState == .signUp {
                        Text(languageManager.localizedString("terms_and_conditions"))
                            .font(.custom("Nunito Sans", size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 20)
                            .transition(.opacity)
                    }
                }
            }
        }
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .onAppear {
            authManager.errorMessage = nil
        }
        .animation(.easeInOut(duration: 0.3), value: authState)
    }
    
    // MARK: - Computed Properties for Button Styling
    
    private var continueButtonBackgroundColor: Color {
        if isContinueButtonEnabled {
            return .primary
        } else {
            return Color.secondary.opacity(0.3)
        }
    }
    
    private var continueButtonTextColor: Color {
        if isContinueButtonEnabled {
            return Color(UIColor.systemBackground)
        } else {
            return .secondary
        }
    }
    
    // MARK: - Localized Text Methods
    
    private func getAuthStateTitle() -> String {
        switch authState {
        case .enterEmail:
            return languageManager.localizedString("log_in_or_sign_up")
        case .signIn:
            return languageManager.localizedString("welcome_back")
        case .signUp:
            return languageManager.localizedString("create_account_title")
        }
    }
    
    private func getEmailPlaceholder() -> String {
        return authState == .enterEmail ?
            languageManager.localizedString("email_placeholder") :
            languageManager.localizedString("enter_email_placeholder")
    }
    
    private func getPasswordLabel() -> String {
        return authState == .signIn ?
            languageManager.localizedString("password_label") :
            languageManager.localizedString("create_password_label")
    }
    
    private func getContinueButtonText() -> String {
        switch authState {
        case .enterEmail:
            return languageManager.localizedString("continue_button")
        case .signIn:
            return languageManager.localizedString("sign_in_button")
        case .signUp:
            return languageManager.localizedString("create_account_button")
        }
    }
    
    // MARK: - Methods
    
    private func handleContinue() {
        switch authState {
        case .enterEmail:
            checkUserExists()
        case .signIn:
            authManager.signIn(email: email, password: password)
        case .signUp:
            if password != confirmPassword {
                authManager.errorMessage = languageManager.localizedString("passwords_do_not_match_error")
                return
            }
            authManager.signUp(email: email, password: password)
        }
    }
    
    private func checkUserExists() {
        guard isValidEmail(email) else {
            authManager.errorMessage = languageManager.localizedString("invalid_email_error")
            return
        }
        
        isCheckingUser = true
        authManager.errorMessage = nil
        
        Task {
            do {
                let userExists = try await authManager.checkUserExists(email: email)
                
                await MainActor.run {
                    isCheckingUser = false
                    withAnimation(.easeInOut(duration: 0.3)) {
                        authState = userExists ? .signIn : .signUp
                    }
                }
            } catch {
                await MainActor.run {
                    isCheckingUser = false
                    withAnimation(.easeInOut(duration: 0.3)) {
                        authState = .signUp
                    }
                    authManager.errorMessage = languageManager.localizedString("unable_to_verify_account_error")
                }
            }
        }
    }
    
    private func resetToEmailEntry() {
        authState = .enterEmail
        password = ""
        confirmPassword = ""
        authManager.errorMessage = nil
    }
    
    private var isContinueButtonEnabled: Bool {
        switch authState {
        case .enterEmail:
            return isValidEmail(email)
        case .signIn:
            return isValidEmail(email) && !password.isEmpty
        case .signUp:
            return isValidEmail(email) &&
            password.count >= 6 &&
            !confirmPassword.isEmpty &&
            password == confirmPassword
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        return !email.isEmpty && email.contains("@") && email.contains(".")
    }
}
