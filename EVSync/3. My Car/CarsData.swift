//
//  CarsData.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 08.09.25.
//

import Foundation

let sampleCars: [ElectricVehicle] = [
    ElectricVehicle(
        make: "Tesla",
        model: "Model 3",
        year: 2023,
        batteryCapacity: 75.0,
        range: 448,
        efficiency: 14.3,
        supportedChargers: [.ccs2, .tesla, .type2], // Tesla поддерживает свои + стандартные через адаптер
        maxChargingSpeed: 250,
        image: "secret"
    ),

    ElectricVehicle(
        make: "Mercedes",
        model: "EQS",
        year: 2024,
        batteryCapacity: 107.8,
        range: 770,
        efficiency: 14.0,
        supportedChargers: [.ccs2, .type2], // Европейские стандарты + бытовая розетка
        maxChargingSpeed: 200,
        image: "secret"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "iX",
        year: 2024,
        batteryCapacity: 111.5,
        range: 630,
        efficiency: 17.7,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 195,
        image: "bmwix"
    ),
    
    // КИТАЙСКИЕ БРЕНДЫ (популярные в KZ)
    ElectricVehicle(
        make: "BYD",
        model: "Seal",
        year: 2024,
        batteryCapacity: 82.5,
        range: 570,
        efficiency: 14.5,
        supportedChargers: [.ccs2, .type2, .gbT], // Китайские авто часто поддерживают GB/T
        maxChargingSpeed: 150,
        image: "secret"
    ),

    ElectricVehicle(
        make: "Zeekr",
        model: "001",
        year: 2024,
        batteryCapacity: 100.0,
        range: 620,
        efficiency: 16.1,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 200,
        image: "secret"
    ),
    
    // НЕМЕЦКИЕ ПРЕМИУМ
    ElectricVehicle(
        make: "BMW",
        model: "iX3",
        year: 2023,
        batteryCapacity: 80.0,
        range: 460,
        efficiency: 17.4,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 150,
        image: "bmwix3"
    )
]

let sampleChargingSessions: [ChargingSession] = [
    ChargingSession(
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
        location: "Mega Mall Almaty",
        energyAdded: 45.2,
        cost: 2260,
        duration: 2400, // 40 minutes
        chargingSpeed: 50
    ),
    ChargingSession(
        date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
        location: "Dostyk Plaza",
        energyAdded: 32.1,
        cost: 1605,
        duration: 1800, // 30 minutes
        chargingSpeed: 75
    ),
    ChargingSession(
        date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
        location: "APORT Mall",
        energyAdded: 38.7,
        cost: 1935,
        duration: 2100, // 35 minutes
        chargingSpeed: 60
    ),
    ChargingSession(
        date: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
        location: "Almaty Mall",
        energyAdded: 41.5,
        cost: 2075,
        duration: 2700, // 45 minutes
        chargingSpeed: 50
    ),
    ChargingSession(
        date: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date(),
        location: "Esentai Mall",
        energyAdded: 52.3,
        cost: 2615,
        duration: 3000, // 50 minutes
        chargingSpeed: 65
    )
]
