//
//  CarSelectionView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct CarSelectionView: View {
    @Binding var selectedCar: ElectricVehicle
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var languageManager = LanguageManager()
    
    var body: some View {
        NavigationView {
            List(sampleCars) { car in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "car.side.fill")
                                .foregroundColor(.blue)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(car.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(String(format: languageManager.localizedString("vehicle_info_format"),
                                   "\(car.range) \(languageManager.localizedString("km_unit"))",
                                   "\(Int(car.batteryCapacity))"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if selectedCar.id == car.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCar = car
                    dismiss()
                }
            }
            .navigationTitle(languageManager.localizedString("select_vehicle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.localizedString("done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}