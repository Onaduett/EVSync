//
//  EmptyCarStatePlaceholder.swift
//  EVSync
//
//  Created for empty state design in MyCarView
//

import SwiftUI

struct EmptyCarStatePlaceholder: View {
    @ObservedObject var languageManager: LanguageManager
    let fontManager: FontManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Два коннектора (заглушки)
            HStack(spacing: 8) {
                // Первый коннектор
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray5).opacity(0.3))
                    .frame(height: 92)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.gray.opacity(0.3),
                                        Color.gray.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Второй коннектор
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray5).opacity(0.3))
                    .frame(height: 92)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.gray.opacity(0.3),
                                        Color.gray.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            }
            
            // Compatible блок
            HStack(spacing: 0) {
                // Совместимо
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .symbolEffect(.pulse)
                        .foregroundColor(.green)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(languageManager.localizedString("compatible"))
                        .font(fontManager.font(.subheadline, weight: .semibold))
                        .foregroundColor(.primary)
                        .fixedSize()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Время
                Text("1 \(languageManager.localizedString("hour_short")) 17 \(languageManager.localizedString("min_short"))")
                    .font(fontManager.font(.caption, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Цена (пример)
                Text("4,505.26 ₸")
                    .font(fontManager.font(.caption, weight: .semibold))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(12)
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.3),
                                Color.green.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            
            // Три кнопки (заглушки)
            HStack(spacing: 10) {
                // Favorite button placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5).opacity(0.3))
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.gray.opacity(0.3),
                                        Color.gray.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Call button placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5).opacity(0.3))
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.gray.opacity(0.3),
                                        Color.gray.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Navigate button placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5).opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.gray.opacity(0.3),
                                        Color.gray.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            }
        }
    }
}

#Preview {
    EmptyCarStatePlaceholder(
        languageManager: LanguageManager(),
        fontManager: FontManager.shared
    )
    .padding()
    .background(Color(.systemBackground))
}
