//
//  MyCarView.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

struct MyCarView: View {
    @AppStorage("selectedCarId") var selectedCarId: String = ""
    @State var selectedCar: ElectricVehicle = sampleCars[0]
    @State var showingCarSelection = false
    @State var chargingSessions: [ChargingSession] = sampleChargingSessions
    @State var imageOpacity: Double = 0.0
    @ObservedObject var languageManager = LanguageManager()
    
    var carStats: CarStats {
        calculateStats()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 9) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 50)
                            
                            ZStack {
                                Image(selectedCar.image)
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
                                        .init(color: Color(.systemBackground).opacity(0.8), location: 0.1),
                                        .init(color: Color(.systemBackground).opacity(0.5), location: 0.25),
                                        .init(color: Color(.systemBackground).opacity(0.2), location: 0.4),
                                        .init(color: Color.clear, location: 0.6)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(height: geometry.size.width * 0.7)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                                .animation(.easeInOut(duration: 0.5), value: imageOpacity)
                            }
                            
                            carInfoCard
                            
                            specificationsSection
                            
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
                
                MyVehicleHeader()
            }
        }
        .onAppear {
            loadSelectedCar()
            withAnimation(.easeInOut(duration: 0.8)) {
                imageOpacity = 1.0
            }
        }
        .onChange(of: selectedCar.id) {
            saveSelectedCar()
            imageOpacity = 0.0
            withAnimation(.easeInOut(duration: 0.8)) {
                imageOpacity = 1.0
            }
        }
        .sheet(isPresented: $showingCarSelection) {
            CarSelectionView(selectedCar: $selectedCar)
        }
    }
}
