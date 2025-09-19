//
//  ActiveFiltersView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

// MARK: - Active Filters Display
struct ActiveFiltersView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    
    let selectedConnectorTypes: Set<ConnectorType>
    let selectedOperators: Set<String>
    let onClearAll: () -> Void
    let onRemoveConnector: (ConnectorType) -> Void
    let onRemoveOperator: (String) -> Void
    
    private var hasActiveFilters: Bool {
        !selectedConnectorTypes.isEmpty || !selectedOperators.isEmpty
    }
    
    var body: some View {
        if hasActiveFilters {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Active Filters")
                        .font(fontManager.font(.subheadline, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    Spacer()
                    
                    Button("Clear All") {
                        onClearAll()
                    }
                    .font(fontManager.font(.caption, weight: .medium))
                    .foregroundColor(.red)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Connector Type Tags
                        ForEach(Array(selectedConnectorTypes), id: \.self) { type in
                            FilterTag(
                                text: type.displayName,
                                color: .blue,
                                onRemove: {
                                    onRemoveConnector(type)
                                }
                            )
                        }
                        
                        // Operator Tags
                        ForEach(Array(selectedOperators), id: \.self) { operatorName in
                            FilterTag(
                                text: operatorName.displayOperatorName,
                                color: operatorName.operatorColor,
                                onRemove: {
                                    onRemoveOperator(operatorName)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Filter Tag Component
struct FilterTag: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    
    let text: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(fontManager.font(.caption2, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(color.opacity(0.7))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .foregroundColor(colorScheme == .dark ? .white : color)
    }
}

// MARK: - Filter Statistics Badge
struct FilterStatisticsBadge: View {
    @Environment(\.fontManager) var fontManager
    
    let totalStations: Int
    let filteredStations: Int
    
    private var percentage: Int {
        guard totalStations > 0 else { return 0 }
        return Int((Double(filteredStations) / Double(totalStations)) * 100)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(filteredStations)")
                .font(fontManager.font(.caption, weight: .bold))
            Text("of")
                .font(fontManager.font(.caption2))
            Text("\(totalStations)")
                .font(fontManager.font(.caption, weight: .medium))
            Text("(\(percentage)%)")
                .font(fontManager.font(.caption2))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Quick Filter Presets
struct QuickFilterPresets: View {
    @Environment(\.fontManager) var fontManager
    
    let onPresetSelected: (FilterPreset) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Filters")
                .font(fontManager.font(.subheadline, weight: .semibold))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FilterPreset.allCases, id: \.self) { preset in
                        QuickFilterButton(preset: preset) {
                            onPresetSelected(preset)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

// MARK: - Quick Filter Button
struct QuickFilterButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    
    let preset: FilterPreset
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: preset.icon)
                    .font(.system(size: 16))
                
                Text(preset.displayName)
                    .font(fontManager.font(.caption, weight: .medium))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
            )
            .foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
