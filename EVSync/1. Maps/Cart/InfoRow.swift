//
//  InfoRow.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

struct InfoRow: View {
    @Environment(\.fontManager) var fontManager
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primary)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(fontManager.font(.caption, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(fontManager.font(.subheadline, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}
