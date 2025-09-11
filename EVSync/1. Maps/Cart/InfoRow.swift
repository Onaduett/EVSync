//
//  InfoRaw.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

struct InfoRow: View {
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
                    .font(.custom("Nunito Sans", size: 13))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.custom("Nunito Sans", size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}
