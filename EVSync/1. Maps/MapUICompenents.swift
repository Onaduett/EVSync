//
//  MapUIComponents.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI
import MapKit

// MARK: - Map Gradient Overlay
struct MapGradientOverlay: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .black, location: 0.0),
                .init(color: .black.opacity(0.5), location: 0.3),
                .init(color: .clear, location: 0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 120)
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    @Environment(\.fontManager) var fontManager
    private let languageManager = LanguageManager()

    var body: some View {
        VStack {
            ProgressView(languageManager.localizedString("loading_charging_stations"))
                .font(fontManager.font(.callout))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
    }
}

// MARK: - Error Overlay
struct ErrorOverlay: View {
    @Environment(\.fontManager) var fontManager
    let message: String
    let retryAction: () -> Void
    private let languageManager = LanguageManager()
    
    var body: some View {
        VStack {
            Text(languageManager.localizedString("error"))
                .font(fontManager.font(.headline, weight: .bold))
                .foregroundColor(.red)
            Text(message)
                .font(fontManager.font(.footnote))
                .multilineTextAlignment(.center)
            Button(languageManager.localizedString("retry")) {
                retryAction()
            }
            .font(fontManager.font(.callout))
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .padding()
    }
}

// MARK: - Map Header с адаптивными иконками (Updated)
struct MapHeader: View {
    @Environment(\.fontManager) var fontManager
    let selectedConnectorTypes: Set<ConnectorType>
    let selectedOperators: Set<String>
    let priceRange: ClosedRange<Double>
    let powerRange: ClosedRange<Double>
    let defaultPriceRange: ClosedRange<Double>
    let defaultPowerRange: ClosedRange<Double>
    @Binding var showingFilterOptions: Bool
    @Binding var mapStyle: MKMapType
    let onLocationTap: () -> Void
    let locationManager: LocationManager
    let colorScheme: ColorScheme
    
    var totalActiveFilters: Int {
        var count = selectedConnectorTypes.count + selectedOperators.count
        
        if priceRange != defaultPriceRange {
            count += 1
        }
        
        if powerRange != defaultPowerRange {
            count += 1
        }
        
        return count
    }
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Button(action: {
                        showingFilterOptions.toggle()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 18))
                                .minimumScaleFactor(0.7)
                            if totalActiveFilters > 0 {
                                Text("\(totalActiveFilters)")
                                    .font(fontManager.font(.caption2, weight: .semibold))
                                    .minimumScaleFactor(0.8)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                HStack {
                    Spacer()
                    Text("Charge&Go")
                        .font(.custom("Lexend-SemiBold", size: 20))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .foregroundColor(
                            colorScheme == .dark
                            ? .white
                            : (mapStyle == .standard ? .black : .white))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                HStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button(action: onLocationTap) {
                            Image(systemName: locationManager.locationButtonIcon)
                                .font(.system(size: 18))
                                .minimumScaleFactor(0.7)
                                .foregroundColor(locationManager.locationButtonColor(colorScheme: colorScheme))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(locationManager.locationBorderColor, lineWidth: locationManager.locationBorderWidth)
                                        )
                                )
                        }
                        
                        // Map theme toggle
                        Button(action: {
                            toggleMapStyle()
                        }) {
                            Image(systemName: mapStyle == .standard ? "map" : "map.fill")
                                .font(.system(size: 18))
                                .minimumScaleFactor(0.7)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                    }
                    .padding(.trailing, 16)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 0)
        }
    }
    
    private func toggleMapStyle() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch mapStyle {
            case .standard:
                mapStyle = .satellite
            case .satellite:
                mapStyle = .hybrid
            case .hybrid:
                mapStyle = .standard
            default:
                mapStyle = .standard
            }
        }
    }
}

// MARK: - Filter Options Overlay (Updated)
struct FilterOptionsOverlay: View {
    let availableTypes: [ConnectorType]
    let availableOperators: [String]
    @Binding var selectedTypes: Set<ConnectorType>
    @Binding var selectedOperators: Set<String>
    @Binding var priceRange: ClosedRange<Double>
    @Binding var powerRange: ClosedRange<Double>
    let maxPrice: Double
    let maxPower: Double
    let minPrice: Double
    let minPower: Double
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            FilterOptionsView(
                availableTypes: availableTypes,
                availableOperators: availableOperators,
                selectedTypes: $selectedTypes,
                selectedOperators: $selectedOperators,
                isShowing: $isShowing,
                priceRange: $priceRange,
                powerRange: $powerRange,
                maxPrice: maxPrice,
                maxPower: maxPower,
                minPrice: minPrice,
                minPower: minPower
            )
            
            Spacer()
        }
        .background(
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
        )
    }
}
