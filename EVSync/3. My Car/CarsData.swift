//
//  CarsData.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 08.09.25.
//

import Foundation

let sampleCars: [ElectricVehicle] = [
    // Tesla
    ElectricVehicle(id: "1", make: "Tesla", model: "Model S", year: 2024, batteryCapacity: 100, range: 652, efficiency: 15.3, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 250, image: "tesla_model_s"),
    ElectricVehicle(id: "2", make: "Tesla", model: "Model S Plaid", year: 2024, batteryCapacity: 100, range: 637, efficiency: 15.7, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 250, image: "tesla_model_s_plaid"),
    ElectricVehicle(id: "3", make: "Tesla", model: "Model 3", year: 2023, batteryCapacity: 60, range: 491, efficiency: 12.2, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 170, image: "tesla_model_3"),
    ElectricVehicle(id: "4", make: "Tesla", model: "Model 3 Performance", year: 2024, batteryCapacity: 82, range: 567, efficiency: 14.5, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 250, image: "tesla_model_3_performance"),
    ElectricVehicle(id: "5", make: "Tesla", model: "Model Y", year: 2024, batteryCapacity: 75, range: 533, efficiency: 14.1, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 250, image: "tesla_model_y"),
    ElectricVehicle(id: "6", make: "Tesla", model: "Model Y Performance", year: 2024, batteryCapacity: 75, range: 514, efficiency: 14.6, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 250, image: "tesla_model_y_performance"),
    ElectricVehicle(id: "7", make: "Tesla", model: "Model X", year: 2024, batteryCapacity: 100, range: 576, efficiency: 17.4, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 250, image: "tesla_model_x"),
    ElectricVehicle(id: "8", make: "Tesla", model: "Model X Plaid", year: 2024, batteryCapacity: 100, range: 543, efficiency: 18.4, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 250, image: "tesla_model_x_plaid"),
    ElectricVehicle(id: "9", make: "Tesla", model: "Cybertruck", year: 2024, batteryCapacity: 123, range: 547, efficiency: 22.5, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 250, image: "tesla_cybertruck"),
    
    // BMW
    ElectricVehicle(id: "10", make: "BMW", model: "iX", year: 2024, batteryCapacity: 111.5, range: 630, efficiency: 17.7, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 200, image: "bmw_ix"),
    ElectricVehicle(id: "11", make: "BMW", model: "iX3", year: 2023, batteryCapacity: 80, range: 460, efficiency: 17.4, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 150, image: "bmw_ix3"),
    ElectricVehicle(id: "12", make: "BMW", model: "i3", year: 2022, batteryCapacity: 42.2, range: 307, efficiency: 13.7, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 50, image: "bmw_i3"),
    ElectricVehicle(id: "13", make: "BMW", model: "i4 eDrive40", year: 2024, batteryCapacity: 83.9, range: 590, efficiency: 14.2, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 205, image: "bmw_i4"),
    ElectricVehicle(id: "14", make: "BMW", model: "i4 M50", year: 2024, batteryCapacity: 83.9, range: 520, efficiency: 16.1, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 205, image: "bmw_i4_m50"),
    ElectricVehicle(id: "15", make: "BMW", model: "i5 eDrive40", year: 2024, batteryCapacity: 84.3, range: 582, efficiency: 14.5, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 205, image: "bmw_i5"),
    ElectricVehicle(id: "16", make: "BMW", model: "i5 M60", year: 2024, batteryCapacity: 84.3, range: 516, efficiency: 16.3, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 205, image: "bmw_i5_m60"),
    ElectricVehicle(id: "17", make: "BMW", model: "i7 eDrive50", year: 2024, batteryCapacity: 105.7, range: 625, efficiency: 16.9, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 195, image: "bmw_i7"),
    ElectricVehicle(id: "18", make: "BMW", model: "i7 M70", year: 2024, batteryCapacity: 105.7, range: 560, efficiency: 18.9, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 195, image: "bmw_i7_m70"),
    ElectricVehicle(id: "19", make: "BMW", model: "iX1", year: 2024, batteryCapacity: 66.5, range: 439, efficiency: 15.1, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 130, image: "bmw_ix1"),
    ElectricVehicle(id: "20", make: "BMW", model: "iX2", year: 2024, batteryCapacity: 66.5, range: 449, efficiency: 14.8, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 130, image: "bmw_ix2"),
    
    // Mercedes
    ElectricVehicle(id: "21", make: "Mercedes", model: "EQS", year: 2024, batteryCapacity: 107.8, range: 782, efficiency: 13.8, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 200, image: "mercedes_eqs"),
    
    // BYD
    ElectricVehicle(id: "22", make: "BYD", model: "Seal", year: 2024, batteryCapacity: 82.5, range: 570, efficiency: 14.5, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 150, image: "byd_seal"),
    ElectricVehicle(id: "23", make: "BYD", model: "Han EV", year: 2024, batteryCapacity: 85.4, range: 605, efficiency: 14.1, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 120, image: "byd_han"),
    ElectricVehicle(id: "24", make: "BYD", model: "Tang EV", year: 2024, batteryCapacity: 108.8, range: 635, efficiency: 17.1, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 170, image: "byd_tang"),
    ElectricVehicle(id: "25", make: "BYD", model: "Song Plus EV", year: 2024, batteryCapacity: 71.8, range: 505, efficiency: 14.2, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 110, image: "byd_song_plus"),
    ElectricVehicle(id: "26", make: "BYD", model: "Yuan Plus", year: 2024, batteryCapacity: 60.5, range: 430, efficiency: 14.1, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 90, image: "byd_yuan_plus"),
    ElectricVehicle(id: "27", make: "BYD", model: "Dolphin", year: 2024, batteryCapacity: 60.5, range: 427, efficiency: 14.2, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 90, image: "byd_dolphin"),
    ElectricVehicle(id: "28", make: "BYD", model: "Atto 3", year: 2024, batteryCapacity: 60.5, range: 420, efficiency: 14.4, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 88, image: "byd_atto3"),
    
    // Zeekr
    ElectricVehicle(id: "29", make: "Zeekr", model: "001", year: 2024, batteryCapacity: 100, range: 741, efficiency: 13.5, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 360, image: "zeekr_001"),
    ElectricVehicle(id: "30", make: "Zeekr", model: "009", year: 2024, batteryCapacity: 140, range: 822, efficiency: 17.0, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 360, image: "zeekr_009"),
    ElectricVehicle(id: "31", make: "Zeekr", model: "X", year: 2024, batteryCapacity: 69, range: 560, efficiency: 12.3, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 150, image: "zeekr_x"),
    ElectricVehicle(id: "32", make: "Zeekr", model: "007", year: 2024, batteryCapacity: 100, range: 870, efficiency: 11.5, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 360, image: "zeekr_007"),
    
    // Li Auto
    ElectricVehicle(id: "33", make: "Li Auto", model: "Li ONE", year: 2024, batteryCapacity: 44.5, range: 188, efficiency: 23.7, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 60, image: "li_one"),
    ElectricVehicle(id: "34", make: "Li Auto", model: "Li L9", year: 2024, batteryCapacity: 44.5, range: 215, efficiency: 20.7, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 60, image: "li_l9"),
    ElectricVehicle(id: "35", make: "Li Auto", model: "Li L8", year: 2024, batteryCapacity: 44.5, range: 210, efficiency: 21.2, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 60, image: "li_l8"),
    ElectricVehicle(id: "36", make: "Li Auto", model: "Li L7", year: 2024, batteryCapacity: 44.5, range: 210, efficiency: 21.2, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 60, image: "li_l7"),
    
    // Hongqi
    ElectricVehicle(id: "37", make: "Hongqi", model: "E-HS9", year: 2024, batteryCapacity: 120, range: 690, efficiency: 17.4, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 100, image: "hongqi_ehs9"),
    ElectricVehicle(id: "38", make: "Hongqi", model: "E-QM5", year: 2024, batteryCapacity: 65, range: 431, efficiency: 15.1, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 90, image: "hongqi_eqm5"),
    
    // Volkswagen
    ElectricVehicle(id: "39", make: "Volkswagen", model: "ID.3", year: 2024, batteryCapacity: 77, range: 557, efficiency: 13.8, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 170, image: "vw_id3"),
    ElectricVehicle(id: "40", make: "Volkswagen", model: "ID.4", year: 2024, batteryCapacity: 77, range: 520, efficiency: 14.8, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 135, image: "vw_id4"),
    ElectricVehicle(id: "41", make: "Volkswagen", model: "ID.5", year: 2024, batteryCapacity: 77, range: 520, efficiency: 14.8, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 135, image: "vw_id5"),
    ElectricVehicle(id: "42", make: "Volkswagen", model: "ID.6", year: 2024, batteryCapacity: 86.2, range: 588, efficiency: 14.7, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 135, image: "vw_id6"),
    ElectricVehicle(id: "43", make: "Volkswagen", model: "ID.7", year: 2024, batteryCapacity: 86, range: 700, efficiency: 12.3, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 200, image: "vw_id7"),
    ElectricVehicle(id: "44", make: "Volkswagen", model: "ID. Buzz", year: 2024, batteryCapacity: 82, range: 423, efficiency: 19.4, supportedChargers: [.ccs2, .type2], maxChargingSpeed: 170, image: "vw_id_buzz"),
    
    // DEEPAL
    ElectricVehicle(id: "45", make: "DEEPAL", model: "S7", year: 2024, batteryCapacity: 79.97, range: 620, efficiency: 12.9, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 115, image: "deepal_s7"),
    ElectricVehicle(id: "46", make: "DEEPAL", model: "SL03", year: 2024, batteryCapacity: 79.97, range: 705, efficiency: 11.3, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 115, image: "deepal_sl03"),
    ElectricVehicle(id: "47", make: "DEEPAL", model: "G318", year: 2024, batteryCapacity: 31.18, range: 175, efficiency: 17.8, supportedChargers: [.ccs2, .type2, .gbT], maxChargingSpeed: 60, image: "deepal_g318")
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
