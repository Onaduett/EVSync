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
    
    @Binding var priceRange: ClosedRange<Double>
    @Binding var powerRange: ClosedRange<Double>
    let maxPrice: Double
    let maxPower: Double
    let minPrice: Double
    let minPower: Double
    
    @State private var tempPriceRange: ClosedRange<Double> = 0...100
    @State private var tempPowerRange: ClosedRange<Double> = 0...350
    
    private var actualPriceRange: ClosedRange<Double> {
        minPrice...maxPrice
    }
    
    private var actualPowerRange: ClosedRange<Double> {
        minPower...maxPower
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                FilterHeader(
                    selectedTypes: $selectedTypes,
                    selectedOperators: $selectedOperators,
                    priceRange: $tempPriceRange,
                    powerRange: $tempPowerRange,
                    defaultPriceRange: actualPriceRange,
                    defaultPowerRange: actualPowerRange
                )
                
                // Price Range Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Price Range (₸/kWh)")
                        .font(fontManager.font(.subheadline, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    PriceRangeSlider(
                        range: $tempPriceRange,
                        bounds: actualPriceRange,
                        step: 1.0
                    )
                }
                
                // Power Range Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Power Range (kW)")
                        .font(fontManager.font(.subheadline, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    PowerRangeSlider(
                        range: $tempPowerRange,
                        bounds: actualPowerRange,
                        step: 5.0
                    )
                }
                
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
                FilterActionButtons(
                    isShowing: $isShowing,
                    onApply: {
                        priceRange = tempPriceRange
                        powerRange = tempPowerRange
                        isShowing = false
                    }
                )
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
        .frame(maxHeight: UIScreen.main.bounds.height * 0.8)
        .onAppear {
            initializeTempRanges()
        }
        .onChange(of: minPrice) { _, _ in
            initializeTempRanges()
        }
        .onChange(of: maxPrice) { _, _ in
            initializeTempRanges()
        }
        .onChange(of: minPower) { _, _ in
            initializeTempRanges()
        }
        .onChange(of: maxPower) { _, _ in
            initializeTempRanges()
        }
    }
    
    private func initializeTempRanges() {
        if minPrice < maxPrice && minPower < maxPower {
            if priceRange == 0...100 {
                tempPriceRange = actualPriceRange
            } else {
                tempPriceRange = priceRange
            }
            
            if powerRange == 0...350 {
                tempPowerRange = actualPowerRange
            } else {
                tempPowerRange = powerRange
            }
        }
    }
}

// MARK: - Updated Filter Header
struct FilterHeader: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    @Binding var selectedTypes: Set<ConnectorType>
    @Binding var selectedOperators: Set<String>
    @Binding var priceRange: ClosedRange<Double>
    @Binding var powerRange: ClosedRange<Double>
    let defaultPriceRange: ClosedRange<Double>
    let defaultPowerRange: ClosedRange<Double>
    
    var body: some View {
        HStack {
            Text("Filters")
                .font(fontManager.font(.headline, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Spacer()
            
            if hasActiveFilters {
                Button("Clear All") {
                    selectedTypes.removeAll()
                    selectedOperators.removeAll()
                    priceRange = defaultPriceRange
                    powerRange = defaultPowerRange
                }
                .font(fontManager.font(.footnote, weight: .medium))
                .foregroundColor(.blue)
            }
        }
    }
    
    private var hasActiveFilters: Bool {
        let priceRangeChanged = defaultPriceRange.lowerBound < defaultPriceRange.upperBound &&
                               priceRange != defaultPriceRange
        let powerRangeChanged = defaultPowerRange.lowerBound < defaultPowerRange.upperBound &&
                               powerRange != defaultPowerRange
        
        return !selectedTypes.isEmpty ||
               !selectedOperators.isEmpty ||
               priceRangeChanged ||
               powerRangeChanged
    }
}



struct PriceRangeSlider: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // Value display
            HStack {
                Text("₸\(Int(range.lowerBound))")
                    .font(fontManager.font(.caption, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.1))
                    )
                
                Spacer()
                
                Text("₸\(Int(range.upperBound))")
                    .font(fontManager.font(.caption, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.1))
                    )
            }
            
            // Custom range slider
            RangeSlider(
                range: $range,
                bounds: bounds,
                step: step,
                trackColor: Color.blue.opacity(0.3),
                rangeColor: Color.blue,
                thumbColor: Color.blue
            )
        }
    }
}

// MARK: - Power Range Slider
struct PowerRangeSlider: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.fontManager) var fontManager
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // Value display
            HStack {
                Text("\(Int(range.lowerBound)) kW")
                    .font(fontManager.font(.caption, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green.opacity(0.1))
                    )
                
                Spacer()
                
                Text("\(Int(range.upperBound)) kW")
                    .font(fontManager.font(.caption, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green.opacity(0.1))
                    )
            }
            
            // Custom range slider
            RangeSlider(
                range: $range,
                bounds: bounds,
                step: step,
                trackColor: Color.green.opacity(0.3),
                rangeColor: Color.green,
                thumbColor: Color.green
            )
        }
    }
}

// MARK: Stable Version
struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let step: Double
    let trackColor: Color
    let rangeColor: Color
    let thumbColor: Color
    
    @State private var isDraggingLower = false
    @State private var isDraggingUpper = false
    
    private var lowerPosition: CGFloat {
        guard bounds.upperBound > bounds.lowerBound else { return 0 }
        return CGFloat((range.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound))
    }
    
    private var upperPosition: CGFloat {
        guard bounds.upperBound > bounds.lowerBound else { return 1 }
        return CGFloat((range.upperBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width - 40
            let thumbSize: CGFloat = 24
            let trackHeight: CGFloat = 8
            
            ZStack {
                // Background track
                RoundedRectangle(cornerRadius: trackHeight / 2)
                    .fill(trackColor)
                    .frame(width: trackWidth, height: trackHeight)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Active range track
                RoundedRectangle(cornerRadius: trackHeight / 2)
                    .fill(rangeColor)
                    .frame(
                        width: max(0, trackWidth * (upperPosition - lowerPosition)),
                        height: trackHeight
                    )
                    .position(
                        x: 20 + trackWidth * lowerPosition + (trackWidth * (upperPosition - lowerPosition)) / 2,
                        y: geometry.size.height / 2
                    )
                
                // Lower thumb
                Circle()
                    .fill(thumbColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .scaleEffect(isDraggingLower ? 1.2 : 1.0)
                    .shadow(color: .black.opacity(0.2), radius: 2)
                    .position(
                        x: 20 + trackWidth * lowerPosition,
                        y: geometry.size.height / 2
                    )
                    .gesture(
                        DragGesture(minimumDistance: 2)
                            .onChanged { value in
                                if !isDraggingLower {
                                    isDraggingLower = true
                                }
                                
                                // Простой расчет позиции
                                let thumbX = value.location.x
                                let normalizedPosition = max(0, min(1, (thumbX - 20) / trackWidth))
                                
                                let newValue = bounds.lowerBound + Double(normalizedPosition) * (bounds.upperBound - bounds.lowerBound)
                                let steppedValue = round(newValue / step) * step
                                let maxLowerValue = range.upperBound - step
                                let clampedValue = max(bounds.lowerBound, min(maxLowerValue, steppedValue))
                                
                                range = clampedValue...range.upperBound
                            }
                            .onEnded { _ in
                                isDraggingLower = false
                            }
                    )
                    .zIndex(isDraggingLower ? 2 : 1)
                
                // Upper thumb
                Circle()
                    .fill(thumbColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .scaleEffect(isDraggingUpper ? 1.2 : 1.0)
                    .shadow(color: .black.opacity(0.2), radius: 2)
                    .position(
                        x: 20 + trackWidth * upperPosition,
                        y: geometry.size.height / 2
                    )
                    .gesture(
                        DragGesture(minimumDistance: 2)
                            .onChanged { value in
                                if !isDraggingUpper {
                                    isDraggingUpper = true
                                }
                                
                                // Простой расчет позиции
                                let thumbX = value.location.x
                                let normalizedPosition = max(0, min(1, (thumbX - 20) / trackWidth))
                                
                                let newValue = bounds.lowerBound + Double(normalizedPosition) * (bounds.upperBound - bounds.lowerBound)
                                let steppedValue = round(newValue / step) * step
                                let minUpperValue = range.lowerBound + step
                                let clampedValue = max(minUpperValue, min(bounds.upperBound, steppedValue))
                                
                                range = range.lowerBound...clampedValue
                            }
                            .onEnded { _ in
                                isDraggingUpper = false
                            }
                    )
                    .zIndex(isDraggingUpper ? 2 : 1)
            }
            .animation(.easeOut(duration: 0.15), value: isDraggingLower)
            .animation(.easeOut(duration: 0.15), value: isDraggingUpper)
        }
        .frame(height: 32)
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
    let onApply: () -> Void
    
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
                onApply()
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
