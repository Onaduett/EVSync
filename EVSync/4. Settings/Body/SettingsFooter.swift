//
//  SettingsFooter.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct SettingsFooter: View {
    var body: some View {
        VStack(spacing: 4) {

            Text("Developed by Daulét Yerkinov")
                .font(.caption)
                .foregroundColor(.secondary)

            
            Text("© 2025 Charge&Go | Based in Almaty")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
}
