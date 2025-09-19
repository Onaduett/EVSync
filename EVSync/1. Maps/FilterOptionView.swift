//
//  FilterOptionsView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct FilterOptionsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    let availableTypes: [ConnectorType]
    let availableOperators: [String]
    @Binding var selectedTypes: Set<ConnectorType>
    @Binding var selectedOperators: Set<String>
    @Binding var isShowing: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                FilterHeader(
                    selectedTypes: $selectedTypes,
                    selectedOperators: $selectedOperators
                )
                
                // Connector Types Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Connector Types")
                        .font(fontManager.font(.subheadline, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    ConnectorTypesGrid(
                        availableTypes: availableTypes,
                        selectedTypes: $selectedTypes
                    )
                }
                
                // Operators Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Operators")
                        .font(fontManager.font(.subheadline, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    OperatorsGrid(
                        availableOperators: availableOperators,
                        selectedOperators: $selectedOperators
                    )
                }
                
                // Action Buttons
                FilterActionButtons(isShowing: $isShowing)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 16)
        .padding(.top, 100)
        .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
    }
}

// MARK: - Filter Header
struct FilterHeader: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    @Binding var selectedTypes: Set<ConnectorType>
    @Binding var selectedOperators: Set<String>
    
    var body: some View {
        HStack {
            Text("Filters")
                .font(fontManager.font(.headline, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Spacer()
            
            if !selectedTypes.isEmpty || !selectedOperators.isEmpty {
                Button("Clear All") {
                    selectedTypes.removeAll()
                    selectedOperators.removeAll()
                }
                .font(fontManager.font(.footnote, weight: .medium))
                .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Connector Types Grid
struct ConnectorTypesGrid: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    let availableTypes: [ConnectorType]
    @Binding var selectedTypes: Set<ConnectorType>
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(availableTypes, id: \.self) { type in
                ConnectorTypeButton(
                    type: type,
                    isSelected: selectedTypes.contains(type)
                ) {
                    toggleSelection(for: type)
                }
            }
        }
    }
    
    private func toggleSelection(for type: ConnectorType) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
    }
}

// MARK: - Operators Grid
struct OperatorsGrid: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    let availableOperators: [String]
    @Binding var selectedOperators: Set<String>
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(availableOperators, id: \.self) { operatorName in
                OperatorButton(
                    operatorName: operatorName,
                    isSelected: selectedOperators.contains(operatorName)
                ) {
                    toggleSelection(for: operatorName)
                }
            }
        }
    }
    
    private func toggleSelection(for operatorName: String) {
        if selectedOperators.contains(operatorName) {
            selectedOperators.remove(operatorName)
        } else {
            selectedOperators.insert(operatorName)
        }
    }
}

// MARK: - Connector Type Button
struct ConnectorTypeButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    let type: ConnectorType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(type.displayName)
                    .font(fontManager.font(.footnote))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ?
                          Color.blue.opacity(0.1) :
                          (colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Operator Button
struct OperatorButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    let operatorName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
                
                Text(operatorName)
                    .font(fontManager.font(.footnote))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ?
                          Color.green.opacity(0.1) :
                          (colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Filter Action Buttons
struct FilterActionButtons: View {
    @Environment(\.fontManager) var fontManager
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack {
            Button("Cancel") {
                isShowing = false
            }
            .font(fontManager.font(.callout))
            .foregroundColor(.gray)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
            )
            
            Spacer()
            
            Button("Apply") {
                isShowing = false
            }
            .font(fontManager.font(.callout, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
            )
        }
    }
}
