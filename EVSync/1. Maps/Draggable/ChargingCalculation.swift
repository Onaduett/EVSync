//
//  ChargingCalculations.swift
//  EVSync
//
//  Created for charging time and cost calculations
//

import Foundation
import SwiftUI

// MARK: - Charging Calculation Result
struct ChargingCalculation {
    let isCompatible: Bool
    let chargingTimeHours: Double // время в часах до 100%
    let totalCost: Double // стоимость в тенге
    let effectivePower: Double // эффективная мощность зарядки в kW
    
    func formattedTime(languageManager: LanguageManager) -> String {
        let totalMinutes = Int(chargingTimeHours * 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours) \(languageManager.localizedString("hour_short")) \(minutes) \(languageManager.localizedString("min_short"))"
        } else {
            return "\(minutes) \(languageManager.localizedString("min_short"))"
        }
    }
    
    func formattedCost() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        
        if let formattedNumber = formatter.string(from: NSNumber(value: totalCost)) {
            return "\(formattedNumber) ₸"
        }
        return String(format: "%.2f ₸", totalCost)
    }
}

// MARK: - Charging Calculator
class ChargingCalculator {
    static func isStationCompatible(station: ChargingStation, car: ElectricVehicle) -> Bool {
        let stationConnectors = Set(station.connectorTypes)
        let carConnectors = Set(car.supportedChargers)
        return !stationConnectors.intersection(carConnectors).isEmpty
    }
    
    static func calculateCharging(
        station: ChargingStation,
        car: ElectricVehicle,
        fromPercent: Double = 0,
        toPercent: Double = 100
    ) -> ChargingCalculation {
        
        let compatible = isStationCompatible(station: station, car: car)
        
        guard compatible else {
            return ChargingCalculation(
                isCompatible: false,
                chargingTimeHours: 0,
                totalCost: 0,
                effectivePower: 0
            )
        }
        
        let batteryCapacity = car.batteryCapacity // kWh
        let stationPower = parseStationPower(station.power) // kW
        let carMaxPower = Double(car.maxChargingSpeed) // kW
        let efficiency = 0.95 // КПД передачи (95%)
        let taperFactor = 0.20 // taper - замедление на последних 20% (+20%)
        
        let effectivePower = min(stationPower, carMaxPower)
        
        let energyNeeded = batteryCapacity * (toPercent - fromPercent) / 100.0
        
        let idealTime = energyNeeded / effectivePower // часы
        
        var realTime = idealTime
        if toPercent > 80 {
            realTime = idealTime * (1 + taperFactor)
        }
        
        let energyFromGrid = energyNeeded / efficiency
        
        let pricePerKWh = parseStationPrice(station.price)
        let totalCost = energyFromGrid * pricePerKWh
        
        return ChargingCalculation(
            isCompatible: true,
            chargingTimeHours: realTime,
            totalCost: totalCost,
            effectivePower: effectivePower
        )
    }
    
    // MARK: - Helper Methods
    
    private static func parseStationPower(_ powerString: String) -> Double {
        let components = powerString.components(separatedBy: " ")
        if let firstComponent = components.first,
           let power = Double(firstComponent) {
            return power
        }
        return 50.0
    }
    
    private static func parseStationPrice(_ priceString: String) -> Double {
        let numericString = priceString.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
        return Double(numericString) ?? 50.0 
    }
}


struct ChargingCompatibilityView: View {
    let station: ChargingStation
    let selectedCarId: String
    @ObservedObject var languageManager: LanguageManager
    let fontManager: FontManager
    let onCarSelection: () -> Void
    
    var selectedCar: ElectricVehicle? {
        guard !selectedCarId.isEmpty else { return nil }
        return sampleCars.first { $0.id.uuidString == selectedCarId }
    }
    
    var calculation: ChargingCalculation? {
        guard let car = selectedCar else { return nil }
        return ChargingCalculator.calculateCharging(station: station, car: car)
    }
    
    var body: some View {
        if let car = selectedCar, let calc = calculation {
            // Автомобиль выбран
            if calc.isCompatible {

                                HStack(spacing: 0) {
                                    // овместимо
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .symbolEffect(.pulse)
                                            .foregroundColor(.green)
                                            .font(.system(size: 16, weight: .semibold))
                                        
                                        Text(languageManager.localizedString("compatible"))
                                            .font(fontManager.font(.subheadline, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .fixedSize()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // Время
                                    Text(calc.formattedTime(languageManager: languageManager))
                                        .font(fontManager.font(.caption, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    // СЦена
                                    Text(calc.formattedCost())
                                        .font(fontManager.font(.caption, weight: .semibold))
                                        .foregroundColor(.green)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                .padding(12)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // если Не совместимо
                HStack(spacing: 8) {
                    Image(systemName: "xmark.seal.fill")
                        .symbolEffect(.pulse)
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(languageManager.localizedString("not_compatible"))
                        .font(fontManager.font(.subheadline, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(12)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        } else {
            // если Автомобиль не выбраn
            Button(action: onCarSelection) {
                HStack(spacing: 8) {
                    Image(systemName: "slash.circle")
                        .symbolEffect(.pulse)
                        .foregroundColor(.orange)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(languageManager.localizedString("select_car_for_calculation"))
                        .font(fontManager.font(.subheadline, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12, weight: .semibold))
                }
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
