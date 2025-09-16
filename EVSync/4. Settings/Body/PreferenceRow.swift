//
//  PreferenceRow.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

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