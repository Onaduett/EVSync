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
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Draggable Handle at top
            VStack(spacing: 9) {
                // Handle strip
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
                        
                        // Haptic feedback when reaching threshold
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
            
            // Header
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
            
            // Quick info in two columns
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "tengesign.circle")
                            .foregroundColor(.white)
                        Text(station.price)
                            .font(.custom("Nunito Sans", size: 15))
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: "bolt")
                            .foregroundColor(.green)
                        Text(station.power)
                            .font(.custom("Nunito Sans", size: 15))
                            .fontWeight(.medium)
                    }
                }
            }
            
            // Connector types (compact view)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(station.connectorTypes, id: \.self) { connector in
                        HStack(spacing: 4) {
                            Image(systemName: connector.icon)
                                .foregroundColor(.blue)
                                .font(.caption)
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
                    Text("Navigate")
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
    
    // MARK: - Navigation Methods
    private func navigateToStation() {
        let latitude = station.coordinate.latitude
        let longitude = station.coordinate.longitude
        let url = URL(string: "maps://?daddr=\(latitude),\(longitude)")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback to Google Maps or web maps
            let googleMapsUrl = URL(string: "https://maps.google.com/?daddr=\(latitude),\(longitude)")!
            UIApplication.shared.open(googleMapsUrl)
        }
    }
}