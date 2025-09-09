//
//  Privacy&Legal.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 08.09.25.
//

import SwiftUI

struct PrivacyLegalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingDataPolicy = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.teal)
                            .padding(.top, 20)
                        
                        Text(languageManager.localizedString("privacy_legal", comment: "Privacy & Legal"))
                            .font(.custom("Nunito Sans", size: 28).weight(.bold))
                            .foregroundColor(.primary)
                        
                        Text(languageManager.localizedString("privacy_legal_subtitle", comment: "Your privacy and security matter to us"))
                            .font(.custom("Nunito Sans", size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                    
                    // Legal Documents
                    VStack(spacing: 12) {
                        LegalDocumentRow(
                            title: languageManager.localizedString("privacy_policy", comment: "Privacy Policy"),
                            subtitle: languageManager.localizedString("privacy_policy_description", comment: "How we handle your personal data"),
                            icon: "doc.text.fill",
                            action: {
                                showingPrivacyPolicy = true
                            }
                        )
                        
                        LegalDocumentRow(
                            title: languageManager.localizedString("terms_of_service", comment: "Terms of Service"),
                            subtitle: languageManager.localizedString("terms_of_service_description", comment: "Terms and conditions of use"),
                            icon: "doc.plaintext.fill",
                            action: {
                                showingTermsOfService = true
                            }
                        )
                        
                        LegalDocumentRow(
                            title: languageManager.localizedString("data_protection", comment: "Data Protection"),
                            subtitle: languageManager.localizedString("data_protection_description", comment: "Your rights and our commitments"),
                            icon: "checkmark.shield.fill",
                            action: {
                                showingDataPolicy = true
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.localizedString("done", comment: "Done")) {
                        dismiss()
                    }
                    .font(.custom("Nunito Sans", size: 16).weight(.medium))
                    .foregroundColor(.teal)
                }
            }
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showingDataPolicy) {
            DataProtectionView()
        }
    }
}

struct LegalDocumentRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.teal)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Nunito Sans", size: 16).weight(.medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.custom("Nunito Sans", size: 14))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(languageManager.localizedString("privacy_policy", comment: "Privacy Policy"))
                        .font(.custom("Nunito Sans", size: 28).weight(.bold))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                    
                    Text(languageManager.localizedString("last_updated", comment: "Last updated: September 2025"))
                        .font(.custom("Nunito Sans", size: 14))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PrivacySection(
                            title: languageManager.localizedString("information_we_collect", comment: "Information We Collect"),
                            content: languageManager.localizedString("information_we_collect_content", comment: "We collect information you provide directly to us, such as when you create an account, update your profile, or contact us for support.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("how_we_use_information", comment: "How We Use Your Information"),
                            content: languageManager.localizedString("how_we_use_information_content", comment: "We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("location_data", comment: "Location Data"),
                            content: languageManager.localizedString("location_data_content", comment: "With your permission, we collect location data to help you find nearby charging stations. You can disable location services at any time in your device settings.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("data_security", comment: "Data Security"),
                            content: languageManager.localizedString("data_security_content", comment: "We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("contact_us", comment: "Contact Us"),
                            content: languageManager.localizedString("contact_us_content", comment: "If you have any questions about this Privacy Policy, please contact us at privacy@chargeandgo.com")
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.localizedString("done", comment: "Done")) {
                        dismiss()
                    }
                    .font(.custom("Nunito Sans", size: 16).weight(.medium))
                    .foregroundColor(.teal)
                }
            }
        }
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(languageManager.localizedString("terms_of_service", comment: "Terms of Service"))
                        .font(.custom("Nunito Sans", size: 28).weight(.bold))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                    
                    Text(languageManager.localizedString("last_updated", comment: "Last updated: September 2025"))
                        .font(.custom("Nunito Sans", size: 14))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PrivacySection(
                            title: languageManager.localizedString("acceptance_of_terms", comment: "Acceptance of Terms"),
                            content: languageManager.localizedString("acceptance_of_terms_content", comment: "By accessing and using EVSync, you accept and agree to be bound by the terms and provision of this agreement.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("use_license", comment: "Use License"),
                            content: languageManager.localizedString("use_license_content", comment: "Permission is granted to temporarily download one copy of EVSync per device for personal, non-commercial transitory viewing only.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("user_account", comment: "User Account"),
                            content: languageManager.localizedString("user_account_content", comment: "You are responsible for safeguarding the password and for maintaining the confidentiality of your account.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("prohibited_uses", comment: "Prohibited Uses"),
                            content: languageManager.localizedString("prohibited_uses_content", comment: "You may not use our service for any unlawful purpose or to solicit others to perform acts that would be unlawful.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("contact_information", comment: "Contact Information"),
                            content: languageManager.localizedString("contact_information_content", comment: "Questions about the Terms of Service should be sent to us at legal@chargeandgo.com")
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("Nunito Sans", size: 16).weight(.medium))
                    .foregroundColor(.teal)
                }
            }
        }
    }
}

// MARK: - Data Protection View
struct DataProtectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(languageManager.localizedString("data_protection", comment: "Data Protection"))
                        .font(.custom("Nunito Sans", size: 28).weight(.bold))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                    
                    Text(languageManager.localizedString("last_updated", comment: "Last updated: September 2025"))
                        .font(.custom("Nunito Sans", size: 14))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PrivacySection(
                            title: languageManager.localizedString("your_rights", comment: "Your Rights"),
                            content: languageManager.localizedString("your_rights_content", comment: "You have the right to access, update, or delete your personal information. You may also request data portability.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("data_retention", comment: "Data Retention"),
                            content: languageManager.localizedString("data_retention_content", comment: "We retain your personal information only for as long as necessary to provide our services and comply with legal obligations.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("data_sharing", comment: "Data Sharing"),
                            content: languageManager.localizedString("data_sharing_content", comment: "We do not sell, trade, or otherwise transfer your personal information to third parties without your explicit consent.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("security_measures", comment: "Security Measures"),
                            content: languageManager.localizedString("security_measures_content", comment: "We employ industry-standard encryption and security protocols to protect your data during transmission and storage.")
                        )
                        
                        PrivacySection(
                            title: languageManager.localizedString("data_requests", comment: "Data Requests"),
                            content: languageManager.localizedString("data_requests_content", comment: "To exercise your data protection rights, contact us at dataprotection@chargeandgo.com")
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.localizedString("done", comment: "Done")) {
                        dismiss()
                    }
                    .font(.custom("Nunito Sans", size: 16).weight(.medium))
                    .foregroundColor(.teal)
                }
            }
        }
    }
}

struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Nunito Sans", size: 18).weight(.semibold))
                .foregroundColor(.primary)
            
            Text(content)
                .font(.custom("Nunito Sans", size: 15))
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    PrivacyLegalView()
}
