//
//  GlassEffect.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 06.10.25.
//

import SwiftUI

extension View {
    func glassEffect() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 35)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.primary.opacity(0.15),
                                Color.primary.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 35)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.primary.opacity(0.6),
                                Color.primary.opacity(0.1),
                                Color.primary.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
    }
}
