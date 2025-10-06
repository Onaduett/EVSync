//
//  MapViewWrapper.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 06.10.25.
//

import SwiftUI

struct MapViewWrapper: View {
    @Binding var selectedStationFromFavorites: ChargingStation?
    @Binding var presentedStation: ChargingStation?
    @Binding var isStationCardShown: Bool
    @Binding var shouldResetMap: Bool
    @Binding var shouldZoomOut: Bool
    @ObservedObject var mapViewModel: MapViewModel
    
    var body: some View {
        MapView(
            selectedStationFromFavorites: $selectedStationFromFavorites,
            presentedStation: $presentedStation,
            isStationCardShown: $isStationCardShown,
            shouldResetMap: $shouldResetMap
        )
        .environmentObject(mapViewModel)
        .onChange(of: shouldZoomOut) { _, newValue in
            if newValue {
                NotificationCenter.default.post(
                    name: NSNotification.Name("ZoomOutFromStation"),
                    object: nil
                )
            }
        }
    }
}
