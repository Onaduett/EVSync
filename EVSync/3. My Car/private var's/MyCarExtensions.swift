//
//  MyCarView+Extensions.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

extension MyCarView {
    
    func loadSelectedCar() {
        guard !selectedCarId.isEmpty else {
            selectedCar = nil
            return
        }
        
        if let car = sampleCars.first(where: { $0.id.uuidString == selectedCarId }) {
            selectedCar = car
        } else {
            selectedCar = nil
            selectedCarId = ""
        }
    }
    
    func saveSelectedCar() {
        if let car = selectedCar {
            selectedCarId = car.id.uuidString
        } else {
            selectedCarId = ""
        }
    }
    
    func calculateStats() -> CarStats {
        let totalSessions = chargingSessions.count
        let totalEnergy = chargingSessions.reduce(0) { $0 + $1.energyAdded }
        let totalCost = chargingSessions.reduce(0) { $0 + $1.cost }
        let averageCost = totalEnergy > 0 ? totalCost / totalEnergy : 0
        
        let co2Saved = totalEnergy * 0.5
        let equivalentGas = totalEnergy / 2.3
        
        return CarStats(
            totalSessions: totalSessions,
            totalEnergyCharged: totalEnergy,
            totalCost: totalCost,
            averageCost: averageCost,
            co2Saved: co2Saved,
            equivalentGasoline: equivalentGas
        )
    }
}
