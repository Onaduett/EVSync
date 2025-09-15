//
//  ChargingModels.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 27.08.25.
//

import Foundation

struct ChargingSession: Identifiable {
    let id = UUID()
    let date: Date
    let location: String
    let energyAdded: Double // kWh
    let cost: Double // ₸
    let duration: TimeInterval // seconds
    let chargingSpeed: Int // kW
}

struct CarStats {
    let totalSessions: Int
    let totalEnergyCharged: Double // kWh
    let totalCost: Double // ₸
    let averageCost: Double // ₸/kWh
    let co2Saved: Double // kg
    let equivalentGasoline: Double // liters
}