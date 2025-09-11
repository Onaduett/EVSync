//
//  ChargingStationAnnotation.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import SwiftUI

struct ChargingStationAnnotation: View {
    let station: ChargingStation
    let isSelected: Bool
    @State private var logoOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(station.availability.color)
                .frame(width: isSelected ? 24 : 20, height: isSelected ? 24 : 20)
                .shadow(radius: isSelected ? 6 : 3)
                .opacity(logoOpacity)
            
            Image(systemName: "bolt.fill")
                .foregroundColor(.white)
                .font(.system(size: isSelected ? 14 : 12, weight: .bold))
                .opacity(logoOpacity)
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                logoOpacity = 1.0
            }
        }
    }
}
