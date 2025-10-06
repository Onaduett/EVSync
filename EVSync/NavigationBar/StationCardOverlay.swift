//
//  Untitled.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 06.10.25.
//

import SwiftUI

struct StationCardOverlay: View {
    let station: ChargingStation
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            VStack {
                Spacer()
                
                StationDetailCard(
                    station: station,
                    showingDetail: .constant(true),
                    onClose: onClose
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .transition(
            .asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            )
        )
    }
}
