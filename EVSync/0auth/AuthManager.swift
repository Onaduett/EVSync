//
//  AuthManager.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import Foundation
import Supabase
import SwiftUI
import GoogleSignIn
import UIKit
import AuthenticationServices
import CryptoKit

@MainActor
class AuthenticationManager: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: User?
    @Published var showSeeYouAgain = false
    private var currentNonce: String?
    
    private var presentationContextProvider: ApplePresentationContextProvider?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://ncuoknogwyjvdikoysfa.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jdW9rbm9nd3lqdmRpa295c2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDU2ODAsImV4cCI6MjA3MTg4MTY4MH0.FwzpAeHXVQWsWuD2jjDZAdMw_anIT0_uFf9P-aAe0zA"
    )
    
    override init() {
        super.init()
        // Configure Google Sign-In
        configureGoogleSignIn()
    }
    
    private func configureGoogleSignIn() {
        // Try to get client ID from the plist file first
        var clientId: String?
        
        // Try different possible file names for your Google config file
        let possibleFileNames = [
            "client_678345122697-4b7g72q8lok56lnm65spt1rqih51g0j5.apps.googleusercontent.com",
            "GoogleService-Info",
            "GoogleService"
        ]
        
        for fileName in possibleFileNames {
            if let path = Bundle.main.path(forResource: fileName, ofType: "plist"),
               let plist = NSDictionary(contentsOfFile: path),
               let id = plist["CLIENT_ID"] as? String {
                clientId = id
                print("Found Google config in file: \(fileName).plist")
                break
            }
        }
        
        // Fallback to hardcoded client ID if file not found
        if clientId == nil {
            clientId = "678345122697-4b7g72q8lok56lnm65spt1rqih51g0j5.apps.googleusercontent.com"
            print("Using hardcoded Google Client ID")
        }
        
        guard let finalClientId = clientId else {
            print("Error: No Google Client ID found")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: finalClientId)
        print("Google Sign-In configured with client ID: \(finalClientId)")
    }
    
    // MARK: - Apple Sign In Helper Methods
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    // MARK: - Auth Methods
    
    func checkAuthStatus() {
        Task {
            await checkAuthStatusAsync()
        }
    }
    
    func checkAuthStatusAsync() async {
        do {
            let session = try await supabase.auth.session
            

            do {
                _ = try await supabase.auth.user()
                await MainActor.run {
                    self.isAuthenticated = true
                    self.user = session.user
                }
            } catch {
                print("Token validation failed: \(error)")
                try? await supabase.auth.signOut()
                await MainActor.run {
                    self.isAuthenticated = false
                    self.user = nil
                }
            }
            
        } catch {
            await MainActor.run {
                self.isAuthenticated = false
                self.user = nil
            }
        }
    }
    
    func checkUserExists(email: String) async throws -> Bool {
        do {
            let response = try await supabase.rpc("check_user_exists", params: ["email_input": email]).execute()
            
            let jsonString = String(data: response.data, encoding: .utf8) ?? ""
            let exists = jsonString.trimmingCharacters(in: .whitespacesAndNewlines) == "true"
            
            return exists
        } catch {
            print("Error checking user exists: \(error)")
            return false
        }
    }
    
    func signUp(email: String, password: String) {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await supabase.auth.signUp(
                    email: email,
                    password: password
                )
                
                let user = response.user
                self.user = user
                self.isAuthenticated = true
                
                let profile: [String: AnyJSON] = [
                    "id": AnyJSON.string(user.id.uuidString),
                    "email": AnyJSON.string(email),
                    "created_at": AnyJSON.string(ISO8601DateFormatter().string(from: Date()))
                ]
                
                do {
                    try await supabase
                        .from("profiles")
                        .upsert(profile)
                        .execute()
                } catch {
                    print("Error creating/updating profile: \(error)")
                }
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func signIn(email: String, password: String) {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await supabase.auth.signIn(
                    email: email,
                    password: password
                )
                
                self.user = response.user
                self.isAuthenticated = true
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func signOut() {
        Task {
            do {
                try await supabase.auth.signOut()
                
                GIDSignIn.sharedInstance.signOut()
                
                self.isAuthenticated = false
                self.user = nil
                self.errorMessage = nil
                
                self.presentationContextProvider = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func resetPassword(email: String) {
        Task {
            do {
                try await supabase.auth.resetPasswordForEmail(email)
                self.errorMessage = "Password reset email sent"
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func signInWithGoogle() {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }
            
            do {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootViewController = window.rootViewController else {
                    throw NSError(domain: "GoogleSignIn", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "No presenting view controller found"])
                }
                
                var topViewController = rootViewController
                while let presentedViewController = topViewController.presentedViewController {
                    topViewController = presentedViewController
                }
                
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
                
                guard let idToken = result.user.idToken?.tokenString else {
                    throw NSError(domain: "GoogleSignIn", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])
                }
                
                let accessToken = result.user.accessToken.tokenString
                
                let response = try await supabase.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .google,
                        idToken: idToken,
                        accessToken: accessToken
                    )
                )
                
                await MainActor.run {
                    self.user = response.user
                    self.isAuthenticated = true
                }
                
                // Create or update user profile in profiles table
                let user = response.user
                let profile: [String: AnyJSON] = [
                    "id": AnyJSON.string(user.id.uuidString),
                    "email": AnyJSON.string(user.email ?? ""),
                    "full_name": AnyJSON.string(result.user.profile?.name ?? ""),
                    "avatar_url": AnyJSON.string(result.user.profile?.imageURL(withDimension: 200)?.absoluteString ?? ""),
                    "provider": AnyJSON.string("google"),
                    "created_at": AnyJSON.string(ISO8601DateFormatter().string(from: Date()))
                ]
                
                do {
                    try await supabase
                        .from("profiles")
                        .upsert(profile)
                        .execute()
                } catch {
                    print("Error creating/updating profile: \(error)")
                    // Don't fail the authentication if profile creation fails
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    print("Google Sign-In Error: \(error)")
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        
        // Create and store presentation context provider to prevent deallocation
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            self.presentationContextProvider = ApplePresentationContextProvider(window: window)
            authorizationController.presentationContextProvider = self.presentationContextProvider
        }
        
        isLoading = true
        errorMessage = nil
        authorizationController.performRequests()
    }
    
    func completeSeeYouAgain() {
        showSeeYouAgain = false
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthenticationManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            do {
                guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    await MainActor.run {
                        self.errorMessage = "Failed to get Apple ID credential"
                        self.isLoading = false
                    }
                    return
                }
                
                guard let nonce = currentNonce else {
                    await MainActor.run {
                        self.errorMessage = "Invalid state: A login callback was received, but no login request was sent."
                        self.isLoading = false
                    }
                    return
                }
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    await MainActor.run {
                        self.errorMessage = "Unable to fetch identity token"
                        self.isLoading = false
                    }
                    return
                }
                
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    await MainActor.run {
                        self.errorMessage = "Unable to serialize token string from data"
                        self.isLoading = false
                    }
                    return
                }
                
                // Sign in with Supabase using the Apple ID token
                let response = try await supabase.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: idTokenString,
                        nonce: nonce
                    )
                )
                
                await MainActor.run {
                    self.user = response.user
                    self.isAuthenticated = true
                }
                
                // Create or update user profile in profiles table
                let user = response.user
                var fullName = ""
                if let givenName = appleIDCredential.fullName?.givenName,
                   let familyName = appleIDCredential.fullName?.familyName {
                    fullName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
                }
                
                let profile: [String: AnyJSON] = [
                    "id": AnyJSON.string(user.id.uuidString),
                    "email": AnyJSON.string(appleIDCredential.email ?? user.email ?? ""),
                    "full_name": AnyJSON.string(fullName),
                    "provider": AnyJSON.string("apple"),
                    "created_at": AnyJSON.string(ISO8601DateFormatter().string(from: Date()))
                ]
                
                do {
                    try await supabase
                        .from("profiles")
                        .upsert(profile)
                        .execute()
                } catch {
                    print("Error creating/updating profile: \(error)")
                    // Don't fail the authentication if profile creation fails
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    print("Apple Sign-In Error: \(error)")
                }
            }
            
            await MainActor.run {
                self.isLoading = false
                self.currentNonce = nil
                // Clean up presentation context provider after completion
                self.presentationContextProvider = nil
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task {
            await MainActor.run {
                self.isLoading = false
                self.currentNonce = nil
                // Clean up presentation context provider after error
                self.presentationContextProvider = nil
                
                if let authError = error as? ASAuthorizationError {
                    switch authError.code {
                    case .canceled:
                        // User canceled, don't show error
                        return
                    case .unknown:
                        self.errorMessage = "Unknown Apple Sign-In error occurred"
                    case .invalidResponse:
                        self.errorMessage = "Invalid Apple Sign-In response"
                    case .notHandled:
                        self.errorMessage = "Apple Sign-In request not handled"
                    case .failed:
                        self.errorMessage = "Apple Sign-In request failed"
                    case .notInteractive:
                        self.errorMessage = "Apple Sign-In not available in current context"
                    case .matchedExcludedCredential:
                        self.errorMessage = "The request was canceled because a credential was matched in the excluded credentials list"
                    default:
                        self.errorMessage = "Apple Sign-In failed with unknown error"
                    }
                } else {
                    self.errorMessage = error.localizedDescription
                }
                
                print("Apple Sign-In Error: \(error)")
            }
        }
    }

    func deleteAccount() {
        Task {
            await MainActor.run {
                self.isLoading = true
                self.errorMessage = nil
            }
            
            do {
                guard let session = try? await supabase.auth.session else {
                    await MainActor.run {
                        self.errorMessage = "No active session found"
                        self.isLoading = false
                    }
                    return
                }
                
                guard let url = URL(string: "https://ncuoknogwyjvdikoysfa.supabase.co/functions/v1/delete-user") else {
                    await MainActor.run {
                        self.errorMessage = "Invalid function URL"
                        self.isLoading = false
                    }
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jdW9rbm9nd3lqdmRpa295c2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDU2ODAsImV4cCI6MjA3MTg4MTY4MH0.FwzpAeHXVQWsWuD2jjDZAdMw_anIT0_uFf9P-aAe0zA", forHTTPHeaderField: "apikey")
                
                request.httpBody = "{}".data(using: .utf8)
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let success = json["success"] as? Bool, success {
                            
                            // ВАЖНО: Сначала выйти из Supabase сессии
                            try await supabase.auth.signOut()
                            
                            // Выйти из Google Sign-In
                            GIDSignIn.sharedInstance.signOut()
                            
                            // Очистить локальное состояние
                            await MainActor.run {
                                self.isAuthenticated = false
                                self.user = nil
                                self.errorMessage = nil
                                self.showSeeYouAgain = true
                                self.presentationContextProvider = nil
                                print("Account successfully deleted")
                            }
                            
                        } else {
                            let errorMsg = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"] as? String ?? "Unknown error"
                            await MainActor.run {
                                self.errorMessage = "Failed to delete account: \(errorMsg)"
                            }
                        }
                    } else {
                        await MainActor.run {
                            self.errorMessage = "Server error: \(httpResponse.statusCode)"
                        }
                    }
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("Delete account error: \(error)")
                }
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
}

// MARK: - Presentation Context Provider

class ApplePresentationContextProvider: NSObject, ASAuthorizationControllerPresentationContextProviding {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return window
    }
}
