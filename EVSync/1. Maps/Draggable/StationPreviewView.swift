//
//  StationPreviewView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

struct StationPreviewView: View {
    let station: ChargingStation
    @Binding var showingDetail: Bool
    @Binding var showingFullDetail: Bool
    @Binding var dragOffset: CGFloat
    let ns: Namespace.ID // Added namespace parameter
    @StateObject private var languageManager = LanguageManager()
    private let fontManager = FontManager.shared
    
    var body: some View {
        let threshold: CGFloat = 60
        let upProgress = min(max(-dragOffset / threshold, 0), 1) // 0...1
        
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 9) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .matchedGeometryEffect(id: "grabber", in: ns) // Added matched geometry
                    .scaleEffect(dragOffset != 0 ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: dragOffset)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 1)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                        
                        if dragOffset < -25 && dragOffset > -30 {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                            if value.translation.height < -50 || value.predictedEndTranslation.height < -100 {
                                showingFullDetail = true
                            }
                            dragOffset = 0
                        }
                    }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                    showingFullDetail = true
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(station.name)
                            .matchedGeometryEffect(id: "name", in: ns) // Added matched geometry
                            .font(fontManager.font(.headline, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(station.address)
                            .matchedGeometryEffect(id: "address", in: ns) // Added matched geometry
                            .font(fontManager.font(.subheadline, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingDetail = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Swapped power and price positions
                HStack(spacing: 16) {
                    DetailChip(icon: "bolt.fill", text: station.power, color: .green)
                        .matchedGeometryEffect(id: "powerChip", in: ns) // Added matched geometry
                    
                    Spacer()
                    
                    PriceChip(text: station.price, languageManager: languageManager)
                        .matchedGeometryEffect(id: "priceChip", in: ns) // Added matched geometry
                }
                
                // Connector types (compact view)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(station.connectorTypes, id: \.self) { connector in
                            HStack(spacing: 4) {
                                Image(connector.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                                    .foregroundColor(.blue)
                                Text(connector.rawValue)
                                    .font(fontManager.font(.caption, weight: .bold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                    .padding(.horizontal, 1)
                }
                .matchedGeometryEffect(id: "connectors", in: ns) // Added matched geometry
                
                // Navigate button
                Button(action: {
                    navigateToStation()
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text(languageManager.localizedString("navigate"))
                    }
                    .font(fontManager.font(.subheadline, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .matchedGeometryEffect(id: "navigate", in: ns) // Added matched geometry
            }
        }
        .padding(16)
    }
    
    private func navigateToStation() {
        let latitude = station.coordinate.latitude
        let longitude = station.coordinate.longitude
        
        if let dgisRouteUrl = URL(string: "dgis://2gis.ru/routeSearch/rsType/car/to/\(longitude),\(latitude)"),
           UIApplication.shared.canOpenURL(dgisRouteUrl) {
            UIApplication.shared.open(dgisRouteUrl)
        } else if let dgisGeoUrl = URL(string: "dgis://2gis.ru/geo/\(longitude),\(latitude)"),
                  UIApplication.shared.canOpenURL(dgisGeoUrl) {
            UIApplication.shared.open(dgisGeoUrl)
        } else if let dgisWebUrl = URL(string: "https://2gis.com/geo/\(longitude),\(latitude)") {
            UIApplication.shared.open(dgisWebUrl)
        }
    }
}
