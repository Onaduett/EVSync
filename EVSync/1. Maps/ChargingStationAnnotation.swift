//
//  ChargingStationAnnotation.swift
//  Charge&Go
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
    @State private var favoriteRingOpacity: Double = 0
    @State private var favoriteRingScale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            if isFavorite {
                Circle()
                    .stroke(Color.red, lineWidth: 5)
                    .frame(width: circleSize, height: circleSize)
                    .opacity(shouldDisappear ? 0 : favoriteRingOpacity)
                    .scaleEffect(shouldDisappear ? 0.1 : (isSelected ? 1.0 : favoriteRingScale))
                    .animation(.spring(response: 0.3), value: isSelected)
                    .animation(.easeOut(duration: 0.2), value: shouldDisappear)
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
        .frame(width: containerSize, height: containerSize)
        .scaleEffect(shouldDisappear ? 0.1 : (isSelected ? 1.2 : 1.0))
        .animation(.spring(response: 0.3), value: isSelected)
        .animation(.easeOut(duration: 0.2), value: shouldDisappear)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                logoOpacity = 1.0
            }
            
            if isFavorite {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                    favoriteRingOpacity = 1.0
                    favoriteRingScale = 1.0
                }
            }
        }
        .onChange(of: isFavorite) { _, newValue in
            if newValue {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    favoriteRingOpacity = 1.0
                    favoriteRingScale = 1.0
                }
            } else {
                withAnimation(.easeOut(duration: 0.25)) {
                    favoriteRingOpacity = 0.0
                    favoriteRingScale = 0.5
                }
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
                
                if isFavorite {
                    favoriteRingOpacity = 1.0
                    favoriteRingScale = 1.0
                }
            }
        }
    }
    
    private var circleSize: CGFloat {
        return isSelected ? 24 : 20
    }
    
    private var containerSize: CGFloat {
        // Учитываем scaleEffect 1.2 при isSelected и обводку favorite (5pt)
        let maxCircleSize: CGFloat = 24
        let favoriteRingWidth: CGFloat = 5
        let scaleEffect: CGFloat = 1.2
        let shadowPadding: CGFloat = 8
        
        return (maxCircleSize + favoriteRingWidth * 2) * scaleEffect + shadowPadding
    }
}
