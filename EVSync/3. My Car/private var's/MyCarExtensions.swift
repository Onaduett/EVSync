//
//  MyCarView+Extensions.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import SwiftUI

// MARK: - MyCarView Extensions
extension MyCarView {
    
    // MARK: - Persistence Methods
    func loadSelectedCar() {
        if !selectedCarId.isEmpty,
           let savedCar = sampleCars.first(where: { $0.id.uuidString == selectedCarId }) {
            selectedCar = savedCar
        }
    }
    
    func saveSelectedCar() {
        selectedCarId = selectedCar.id.uuidString
    }
    
    // MARK: - Statistics Calculation
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