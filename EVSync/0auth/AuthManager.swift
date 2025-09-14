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

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: User?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://ncuoknogwyjvdikoysfa.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jdW9rbm9nd3lqdmRpa295c2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMDU2ODAsImV4cCI6MjA3MTg4MTY4MH0.FwzpAeHXVQWsWuD2jjDZAdMw_anIT0_uFf9P-aAe0zA"
    )
    
    init() {
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
    
    func checkAuthStatus() {
        Task {
            await checkAuthStatusAsync()
        }
    }
    
    func checkAuthStatusAsync() async {
        do {
            let session = try await supabase.auth.session
            await MainActor.run {
                self.isAuthenticated = true
                self.user = session.user
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
                
                // Insert user profile into profiles table
                let profile: [String: AnyJSON] = [
                    "id": AnyJSON.string(user.id.uuidString),
                    "email": AnyJSON.string(email),
                    "created_at": AnyJSON.string(ISO8601DateFormatter().string(from: Date()))
                ]
                
                try await supabase
                    .from("profiles")
                    .insert(profile)
                    .execute()
                
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
                
                // Also sign out from Google
                GIDSignIn.sharedInstance.signOut()
                
                self.isAuthenticated = false
                self.user = nil
                self.errorMessage = nil
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
                // Get the presenting view controller
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootViewController = window.rootViewController else {
                    throw NSError(domain: "GoogleSignIn", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "No presenting view controller found"])
                }
                
                // Get the top-most view controller
                var topViewController = rootViewController
                while let presentedViewController = topViewController.presentedViewController {
                    topViewController = presentedViewController
                }
                
                // Start Google Sign-In flow
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
                
                guard let idToken = result.user.idToken?.tokenString else {
                    throw NSError(domain: "GoogleSignIn", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])
                }
                
                let accessToken = result.user.accessToken.tokenString
                
                // Sign in with Supabase using the Google tokens (no custom nonce needed)
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
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                // Note: You'll need to configure Apple Sign-In with Supabase
                // This is a placeholder implementation
                try await supabase.auth.signInWithOAuth(
                    provider: .apple,
                    redirectTo: URL(string: "your-app://auth-callback")
                )
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}
