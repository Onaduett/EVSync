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
    let isFavorite: Bool
    @State private var logoOpacity: Double = 0
    @State private var shouldDisappear: Bool = false
    
    var body: some View {
        ZStack {
            if isFavorite {
                Circle()
                    .stroke(Color.red, lineWidth: 2.5)
                    .frame(width: circleSize + 2.5, height: circleSize + 2.5) // Reduced gap
                    .opacity(shouldDisappear ? 0 : logoOpacity)
                    .scaleEffect(shouldDisappear ? 0.1 : (isSelected ? 1.2 : 1.0))
                    .animation(.spring(response: 0.3), value: isSelected)
                    .animation(.easeOut(duration: 0.2), value: shouldDisappear)
                    .animation(.easeInOut(duration: 0.2), value: isFavorite)
            }
            
            Circle()
                .fill(station.availability.color)
                .frame(width: circleSize, height: circleSize)
                .shadow(radius: isSelected ? 6 : 3)
                .opacity(shouldDisappear ? 0 : logoOpacity)
            
            Image(systemName: "bolt.fill")
                .foregroundColor(.white)
                .font(.system(size: isSelected ? 14 : 12, weight: .bold))
                .opacity(shouldDisappear ? 0 : logoOpacity)
        }
        .scaleEffect(shouldDisappear ? 0.1 : (isSelected ? 1.2 : 1.0))
        .animation(.spring(response: 0.3), value: isSelected)
        .animation(.easeOut(duration: 0.2), value: shouldDisappear)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                logoOpacity = 1.0
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HideStationAnnotations"))) { _ in
            withAnimation(.easeOut(duration: 0.2)) {
                shouldDisappear = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowStationAnnotations"))) { _ in
            withAnimation(.easeIn(duration: 0.3)) {
                shouldDisappear = false
                logoOpacity = 1.0
            }
        }
    }
    
    private var circleSize: CGFloat {
        return isSelected ? 24 : 20
    }
}
