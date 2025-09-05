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
                            Text(authState == .enterEmail ? "Log in or Sign up" : (authState == .signIn ? "Welcome back!" : "Create your account"))
                                .font(.custom("Nunito Sans", size: 18))
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 16) {
                                // Email Field
                                VStack(alignment: .leading, spacing: 8) {
                                    if authState != .enterEmail {
                                        Text("Email")
                                            .font(.custom("Nunito Sans", size: 14))
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 16)
                                    }
                                    
                                    TextField(authState == .enterEmail ? "Email" : "Enter your email", text: $email)
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
                                        Text(authState == .signIn ? "Password" : "Create a password")
                                            .font(.custom("Nunito Sans", size: 14))
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 16)
                                        
                                        SecureField("Enter your password", text: $password)
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
                                            Text("Password must be at least 6 characters")
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
                                        Text("Confirm password")
                                            .font(.custom("Nunito Sans", size: 14))
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 16)
                                        
                                        SecureField("Confirm your password", text: $confirmPassword)
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
                                                Text(password == confirmPassword ? "Passwords match" : "Passwords don't match")
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
                                        Button("Forgot Password?") {
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
                                    Text("← Back to email")
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
                                        
                                        Text("or use")
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
                                                Image("google_logo") // You'll need to add this image asset
                                                    .resizable()
                                                    .frame(width: 16, height: 16)
                                                Text("Sign in with Google")
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
                                                Text("Sign in with Apple")
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
                        Text("By signing up, you agree to our Terms of Service and Privacy Policy")
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
            // Активная кнопка: в светлой теме черный фон с белым текстом, в темной - белый фон с черным текстом
            return Color(UIColor.systemBackground)
        } else {
            // Неактивная кнопка: серый текст в любой теме
            return .secondary
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
                authManager.errorMessage = "Passwords do not match"
                return
            }
            authManager.signUp(email: email, password: password)
        }
    }
    
    private func checkUserExists() {
        guard isValidEmail(email) else {
            authManager.errorMessage = "Please enter a valid email address"
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
                    authManager.errorMessage = "Unable to verify account status"
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
    
    private func getContinueButtonText() -> String {
        switch authState {
        case .enterEmail:
            return "Continue"
        case .signIn:
            return "Sign In"
        case .signUp:
            return "Create Account"
        }
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
