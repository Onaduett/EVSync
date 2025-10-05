//
//  MyCarView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct MyCarView: View {
    @AppStorage("selectedCarId") var selectedCarId: String = ""
    @State var selectedCar: ElectricVehicle?
    @State var showingCarSelection = false
    @State var chargingSessions: [ChargingSession] = sampleChargingSessions
    @State var imageOpacity: Double = 0.0
    @State var gradientOpacity: Double = 0.0
    @ObservedObject var languageManager = LanguageManager()
    @StateObject var fontManager = FontManager.shared
    
    var carStats: CarStats {
        calculateStats()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if let car = selectedCar {
                    // Existing car view
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 9) {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 50)
                                
                                ZStack {
                                    Image(car.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: geometry.size.width * 0.7)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(12)
                                        .opacity(imageOpacity)
                                        .animation(.easeInOut(duration: 0.8), value: imageOpacity)
                                    
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color(.systemBackground), location: 0.0),
                                            .init(color: Color(.systemBackground).opacity(0.8), location: 0.05),
                                            .init(color: Color(.systemBackground).opacity(0.5), location: 0.15),
                                            .init(color: Color(.systemBackground).opacity(0.2), location: 0.25),
                                            .init(color: Color.clear, location: 0.35)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(height: geometry.size.width * 0.7)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(12)
                                    .opacity(gradientOpacity)
                                    .animation(.easeInOut(duration: 1.0).delay(0.3), value: gradientOpacity)
                                }
                                
                                carInfoCard(car: car)
                                
                                specificationsSection(car: car)
                                
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                    }
                } else {
                    // Default empty state view with carInfoCard
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 50)
                        
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                showingCarSelection = true
                            }) {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(languageManager.localizedString("choose_your_vehicle"))
                                            .customFont(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.primary.opacity(0.05))
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                }
                
                MyVehicleHeader()
            }
        }
        .onAppear {
            loadSelectedCar()
            if selectedCar != nil {
                withAnimation(.easeInOut(duration: 0.8)) {
                    imageOpacity = 1.0
                }
                withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                    gradientOpacity = 1.0
                }
            }
        }
        .onChange(of: selectedCar?.id) {
            if selectedCar != nil {
                saveSelectedCar()
                imageOpacity = 0.0
                gradientOpacity = 0.0
                withAnimation(.easeInOut(duration: 0.8)) {
                    imageOpacity = 1.0
                }
                withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                    gradientOpacity = 1.0
                }
            }
        }
        .sheet(isPresented: $showingCarSelection) {
            CarSelectionView(
                selectedCar: Binding(
                    get: { selectedCar ?? sampleCars[0] },
                    set: { selectedCar = $0 }
                ),
                hasInitialSelection: selectedCar != nil
            )
            .environmentObject(fontManager)
            .environmentObject(languageManager)
        }
    }
}
