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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: colorScheme == .dark ? .black : .white, location: 0.0),
                .init(color: colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.5), location: 0.3),
                .init(color: .clear, location: 1.0)
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
    private let languageManager = LanguageManager()

    var body: some View {
        VStack {
            ProgressView(languageManager.localizedString("loading_charging_stations"))
                .font(.custom("Nunito Sans", size: 16))
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
    let message: String
    let retryAction: () -> Void
    private let languageManager = LanguageManager()
    
    var body: some View {
        VStack {
            Text(languageManager.localizedString("error"))
                .font(.custom("Nunito Sans", size: 18).weight(.bold))
                .foregroundColor(.red)
            Text(message)
                .font(.custom("Nunito Sans", size: 14))
                .multilineTextAlignment(.center)
            Button(languageManager.localizedString("retry")) {
                retryAction()
            }
            .font(.custom("Nunito Sans", size: 16))
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

// MARK: - Map Header с адаптивными иконками
struct MapHeader: View {
    let selectedConnectorTypes: Set<ConnectorType>
    @Binding var showingFilterOptions: Bool
    @Binding var mapStyle: MKMapType
    let onLocationTap: () -> Void
    let locationManager: LocationManager
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack {
            HStack {
                // Left side - Filter button
                HStack {
                    Button(action: {
                        showingFilterOptions.toggle()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 18))
                                .minimumScaleFactor(0.7)
                            if !selectedConnectorTypes.isEmpty {
                                Text("\(selectedConnectorTypes.count)")
                                    .font(.custom("Nunito Sans", size: 12).weight(.semibold))
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
                
                // Center - App title
                HStack {
                    Spacer()
                    Text("Charge&Go")
                        .font(.custom("Lexend-SemiBold", size: 20))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                // Right side - Location and Map style buttons
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
// MARK: - Filter Options Overlay
struct FilterOptionsOverlay: View {
    let availableTypes: [ConnectorType]
    @Binding var selectedTypes: Set<ConnectorType>
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            FilterOptionsView(
                availableTypes: availableTypes,
                selectedTypes: $selectedTypes,
                isShowing: $isShowing
            )
            .transition(.move(edge: .top).combined(with: .opacity))
            
            Spacer()
        }
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            isShowing = false
        }
    }
}
