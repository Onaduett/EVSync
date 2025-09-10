//
//  AuthManager.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import Foundation
import Supabase
import SwiftUI

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
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        Task {
            do {
                let session = try await supabase.auth.session
                self.isAuthenticated = true
                self.user = session.user
            } catch {
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
                
                // Since response.user is not optional, directly assign it
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
            isLoading = true
            errorMessage = nil
            
            do {
                // Note: You'll need to configure Google Sign-In with Supabase
                // This is a placeholder implementation
                try await supabase.auth.signInWithOAuth(
                    provider: .google,
                    redirectTo: URL(string: "your-app://auth-callback")
                )
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
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
