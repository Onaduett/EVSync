//
//  CarSelectionView.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct CarSelectionView: View {
    @Binding var selectedCarId: String
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var languageManager = LanguageManager()
    @EnvironmentObject var fontManager: FontManager
    
    @State private var searchText = ""
    @State private var hasInitialSelection: Bool
    @State private var showingDeleteAlert = false
    
    init(selectedCarId: Binding<String>, hasInitialSelection: Bool = true) {
        self._selectedCarId = selectedCarId
        self._hasInitialSelection = State(initialValue: hasInitialSelection)
    }
    
    var filteredCars: [ElectricVehicle] {
        if searchText.isEmpty {
            return sampleCars
        } else {
            return sampleCars.filter { car in
                car.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(filteredCars) { car in
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.teal.opacity(0.1))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(car.logo)
                                        .resizable()
                                        .scaledToFit()
                                        .padding(8)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(car.displayName)
                                    .customFont(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(String(format: languageManager.localizedString("vehicle_info_format"),
                                            "\(car.range) \(languageManager.localizedString("km_unit"))",
                                            "\(Int(car.batteryCapacity))"))
                                .customFont(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if hasInitialSelection && selectedCarId == car.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hasInitialSelection = true
                            selectedCarId = car.id
                            print("DEBUG: Selected car ID: \(selectedCarId)")
                            dismiss()
                        }
                    }
                }
                .navigationTitle(languageManager.localizedString("select_vehicle"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if hasInitialSelection && !selectedCarId.isEmpty {
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .font(.system(size: 13))
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(languageManager.localizedString("done")) {
                            dismiss()
                        }
                    }
                }
                
                // Search bar overlay at bottom
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 12)
                        
                        TextField(languageManager.localizedString("search_vehicles"), text: $searchText)
                            .font(fontManager.font(.body))
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.vertical, 12)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 12)
                        } else {
                            Spacer()
                                .frame(width: 12)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.thickMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
            }
            .alert(languageManager.localizedString("delete_vehicle_alert_title"), isPresented: $showingDeleteAlert) {
                Button(languageManager.localizedString("cancel"), role: .cancel) { }
                Button(languageManager.localizedString("delete_vehicle_alert_title"), role: .destructive) {
                    withAnimation {
                        selectedCarId = ""
                        hasInitialSelection = false
                    }
                    dismiss()
                }
            } message: {
                Text(languageManager.localizedString("delete_vehicle_alert_message"))
            }
        }
    }
}
