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
    @StateObject private var languageManager = LanguageManager()
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 9) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 5)
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
                        
                        if dragOffset < -50 && dragOffset > -55 {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            if value.translation.height < -50 || value.predictedEndTranslation.height < -100 {
                                showingFullDetail = true
                            }
                            dragOffset = 0
                        }
                    }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showingFullDetail = true
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(station.name)
                        .font(.custom("Nunito Sans", size: 17))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(station.address)
                        .font(.custom("Nunito Sans", size: 15))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: {
                    showingDetail = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                PriceChip(text: station.price, languageManager: languageManager)
                
                Spacer()
                
                DetailChip(icon: "bolt.fill", text: station.power, color: .green)
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
                                .font(.custom("Nunito Sans", size: 12))
                                .fontWeight(.medium)
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
            
            // Navigate button
            Button(action: {
                navigateToStation()
            }) {
                HStack {
                    Image(systemName: "location.fill")
                    Text(languageManager.localizedString("navigate"))
                }
                .font(.custom("Nunito Sans", size: 15))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(12)
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
