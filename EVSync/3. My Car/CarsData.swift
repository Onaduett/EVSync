//
//  CarsData.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 08.09.25.
//

import Foundation

let sampleCars: [ElectricVehicle] = [
    // TESLA - Expanded Collection
    ElectricVehicle(
        make: "Tesla",
        model: "Model S",
        year: 2024,
        batteryCapacity: 100.0,
        range: 652,
        efficiency: 15.3,
        supportedChargers: [.ccs2, .tesla, .type2],
        maxChargingSpeed: 250,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Tesla",
        model: "Model S Plaid",
        year: 2024,
        batteryCapacity: 100.0,
        range: 628,
        efficiency: 15.9,
        supportedChargers: [.ccs2, .tesla, .type2],
        maxChargingSpeed: 250,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Tesla",
        model: "Model 3",
        year: 2023,
        batteryCapacity: 75.0,
        range: 448,
        efficiency: 14.3,
        supportedChargers: [.ccs2, .tesla, .type2],
        maxChargingSpeed: 250,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Tesla",
        model: "Model 3 Performance",
        year: 2024,
        batteryCapacity: 75.0,
        range: 547,
        efficiency: 13.7,
        supportedChargers: [.ccs2, .tesla, .type2],
        maxChargingSpeed: 250,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Tesla",
        model: "Model Y",
        year: 2024,
        batteryCapacity: 75.0,
        range: 533,
        efficiency: 14.1,
        supportedChargers: [.ccs2, .tesla, .type2],
        maxChargingSpeed: 250,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Tesla",
        model: "Model Y Performance",
        year: 2024,
        batteryCapacity: 75.0,
        range: 514,
        efficiency: 14.6,
        supportedChargers: [.ccs2, .tesla, .type2],
        maxChargingSpeed: 250,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Tesla",
        model: "Model X",
        year: 2024,
        batteryCapacity: 100.0,
        range: 560,
        efficiency: 17.9,
        supportedChargers: [.ccs2, .tesla, .type2],
        maxChargingSpeed: 250,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Tesla",
        model: "Model X Plaid",
        year: 2024,
        batteryCapacity: 100.0,
        range: 528,
        efficiency: 18.9,
        supportedChargers: [.ccs2, .tesla, .type2],
        maxChargingSpeed: 250,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Tesla",
        model: "Cybertruck",
        year: 2024,
        batteryCapacity: 123.0,
        range: 547,
        efficiency: 22.5,
        supportedChargers: [.ccs2, .tesla, .type2],
        maxChargingSpeed: 250,
        image: "secret"
    ),

    // BMW - Expanded Collection
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
    ),
    ElectricVehicle(
        make: "BMW",
        model: "i3",
        year: 2022,
        batteryCapacity: 42.2,
        range: 307,
        efficiency: 13.7,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 50,
        image: "bmwi3"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "i4 eDrive40",
        year: 2024,
        batteryCapacity: 83.9,
        range: 590,
        efficiency: 14.2,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 200,
        image: "secret"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "i4 M50",
        year: 2024,
        batteryCapacity: 83.9,
        range: 521,
        efficiency: 16.1,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 200,
        image: "secret"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "i5 eDrive40",
        year: 2024,
        batteryCapacity: 84.4,
        range: 582,
        efficiency: 14.5,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 205,
        image: "bmwi5"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "i5 M60",
        year: 2024,
        batteryCapacity: 84.4,
        range: 516,
        efficiency: 16.4,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 205,
        image: "bmwi5"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "i7 eDrive50",
        year: 2024,
        batteryCapacity: 101.7,
        range: 625,
        efficiency: 16.3,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 195,
        image: "bmwi7"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "i7 M70",
        year: 2024,
        batteryCapacity: 101.7,
        range: 560,
        efficiency: 18.2,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 195,
        image: "bmwi7"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "iX1",
        year: 2024,
        batteryCapacity: 64.7,
        range: 438,
        efficiency: 14.8,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 130,
        image: "secret"
    ),
    ElectricVehicle(
        make: "BMW",
        model: "iX2",
        year: 2024,
        batteryCapacity: 64.8,
        range: 449,
        efficiency: 14.4,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 130,
        image: "secret"
    ),

    // MERCEDES
    ElectricVehicle(
        make: "Mercedes",
        model: "EQS",
        year: 2024,
        batteryCapacity: 107.8,
        range: 770,
        efficiency: 14.0,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 200,
        image: "secret"
    ),
    
    // BYD (все модели)
    ElectricVehicle(
        make: "BYD",
        model: "Seal",
        year: 2024,
        batteryCapacity: 82.5,
        range: 570,
        efficiency: 14.5,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 150,
        image: "bydseal"
    ),
    ElectricVehicle(
        make: "BYD",
        model: "Han EV",
        year: 2024,
        batteryCapacity: 85.4,
        range: 605,
        efficiency: 14.1,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 120,
        image: "secret"
    ),
    ElectricVehicle(
        make: "BYD",
        model: "Tang EV",
        year: 2024,
        batteryCapacity: 108.8,
        range: 505,
        efficiency: 21.5,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 110,
        image: "secret"
    ),
    ElectricVehicle(
        make: "BYD",
        model: "Song Plus EV",
        year: 2024,
        batteryCapacity: 71.7,
        range: 505,
        efficiency: 14.2,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 80,
        image: "secret"
    ),
    ElectricVehicle(
        make: "BYD",
        model: "Yuan Plus",
        year: 2024,
        batteryCapacity: 60.5,
        range: 430,
        efficiency: 14.1,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 80,
        image: "secret"
    ),
    ElectricVehicle(
        make: "BYD",
        model: "Dolphin",
        year: 2024,
        batteryCapacity: 60.5,
        range: 420,
        efficiency: 14.4,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 70,
        image: "secret"
    ),
    ElectricVehicle(
        make: "BYD",
        model: "Atto 3",
        year: 2024,
        batteryCapacity: 60.5,
        range: 420,
        efficiency: 14.4,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 80,
        image: "secret"
    ),

    // ZEEKR (все модели)
    ElectricVehicle(
        make: "Zeekr",
        model: "001",
        year: 2024,
        batteryCapacity: 100.0,
        range: 620,
        efficiency: 16.1,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 200,
        image: "zeekr001"
    ),
    ElectricVehicle(
        make: "Zeekr",
        model: "009",
        year: 2024,
        batteryCapacity: 140.0,
        range: 822,
        efficiency: 17.0,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 200,
        image: "zeekr009"
    ),
    ElectricVehicle(
        make: "Zeekr",
        model: "X",
        year: 2024,
        batteryCapacity: 95.0,
        range: 560,
        efficiency: 17.0,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 180,
        image: "zeekrx"
    ),
    ElectricVehicle(
        make: "Zeekr",
        model: "007",
        year: 2024,
        batteryCapacity: 75.0,
        range: 688,
        efficiency: 10.9,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 200,
        image: "secret"
    ),

    // LIXIANG (все модели)
    ElectricVehicle(
        make: "Li Auto",
        model: "Li ONE",
        year: 2024,
        batteryCapacity: 44.5,
        range: 188, // только на электричестве (гибрид)
        efficiency: 23.7,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 40,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Li Auto",
        model: "Li L9",
        year: 2024,
        batteryCapacity: 44.5,
        range: 215,
        efficiency: 20.7,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 40,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Li Auto",
        model: "Li L8",
        year: 2024,
        batteryCapacity: 44.5,
        range: 210,
        efficiency: 21.2,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 40,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Li Auto",
        model: "Li L7",
        year: 2024,
        batteryCapacity: 42.8,
        range: 210,
        efficiency: 20.4,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 40,
        image: "secret"
    ),

    // HONGQI
    ElectricVehicle(
        make: "Hongqi",
        model: "E-HS9",
        year: 2024,
        batteryCapacity: 99.0,
        range: 510,
        efficiency: 19.4,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 120,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Hongqi",
        model: "E-QM5",
        year: 2024,
        batteryCapacity: 62.4,
        range: 431,
        efficiency: 14.5,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 100,
        image: "secret"
    ),

    // VOLKSWAGEN ID серия
    ElectricVehicle(
        make: "Volkswagen",
        model: "ID.3",
        year: 2024,
        batteryCapacity: 77.0,
        range: 550,
        efficiency: 14.0,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 135,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Volkswagen",
        model: "ID.4",
        year: 2024,
        batteryCapacity: 82.0,
        range: 520,
        efficiency: 15.8,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 135,
        image: "vw4"
    ),
    ElectricVehicle(
        make: "Volkswagen",
        model: "ID.5",
        year: 2024,
        batteryCapacity: 82.0,
        range: 520,
        efficiency: 15.8,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 135,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Volkswagen",
        model: "ID.6",
        year: 2024,
        batteryCapacity: 83.4,
        range: 588,
        efficiency: 14.2,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 135,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Volkswagen",
        model: "ID.7",
        year: 2024,
        batteryCapacity: 86.0,
        range: 690,
        efficiency: 12.5,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 200,
        image: "secret"
    ),
    ElectricVehicle(
        make: "Volkswagen",
        model: "ID. Buzz",
        year: 2024,
        batteryCapacity: 82.0,
        range: 423,
        efficiency: 19.4,
        supportedChargers: [.ccs2, .type2],
        maxChargingSpeed: 170,
        image: "secret"
    ),

    // DEEPAL
    ElectricVehicle(
        make: "DEEPAL",
        model: "S7",
        year: 2024,
        batteryCapacity: 79.97,
        range: 620,
        efficiency: 12.9,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 150,
        image: "secret"
    ),
    ElectricVehicle(
        make: "DEEPAL",
        model: "SL03",
        year: 2024,
        batteryCapacity: 69.9,
        range: 515,
        efficiency: 13.6,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 150,
        image: "secret"
    ),
    ElectricVehicle(
        make: "DEEPAL",
        model: "G318",
        year: 2024,
        batteryCapacity: 85.0,
        range: 550,
        efficiency: 15.5,
        supportedChargers: [.ccs2, .type2, .gbT],
        maxChargingSpeed: 120,
        image: "secret"
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
