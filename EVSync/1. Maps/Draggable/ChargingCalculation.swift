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
    
    /// Форматирует время в читаемый формат (например "1 ч 23 мин")
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
    
    /// Форматирует стоимость (например "1,998.23 ₸")
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
    
    /// Проверяет совместимость станции с автомобилем
    static func isStationCompatible(station: ChargingStation, car: ElectricVehicle) -> Bool {
        // Проверяем, есть ли хотя бы один общий коннектор
        let stationConnectors = Set(station.connectorTypes)
        let carConnectors = Set(car.supportedChargers)
        return !stationConnectors.intersection(carConnectors).isEmpty
    }
    
    /// Рассчитывает время зарядки и стоимость
    static func calculateCharging(
        station: ChargingStation,
        car: ElectricVehicle,
        fromPercent: Double = 0,
        toPercent: Double = 100
    ) -> ChargingCalculation {
        
        // Проверка совместимости
        let compatible = isStationCompatible(station: station, car: car)
        
        guard compatible else {
            return ChargingCalculation(
                isCompatible: false,
                chargingTimeHours: 0,
                totalCost: 0,
                effectivePower: 0
            )
        }
        
        // Параметры
        let batteryCapacity = car.batteryCapacity // kWh
        let stationPower = parseStationPower(station.power) // kW
        let carMaxPower = Double(car.maxChargingSpeed) // kW
        let efficiency = 0.95 // КПД передачи (95%)
        let taperFactor = 0.20 // taper - замедление на последних 20% (+20%)
        
        // Эффективная мощность (минимум из мощности станции и машины)
        let effectivePower = min(stationPower, carMaxPower)
        
        // Энергия для зарядки
        let energyNeeded = batteryCapacity * (toPercent - fromPercent) / 100.0
        
        // Идеальное время без учета потерь
        let idealTime = energyNeeded / effectivePower // часы
        
        // Реальное время с учетом taper (если заряжаем больше 80%)
        var realTime = idealTime
        if toPercent > 80 {
            realTime = idealTime * (1 + taperFactor)
        }
        
        // Энергия из сети с учетом КПД
        let energyFromGrid = energyNeeded / efficiency
        
        // Стоимость (парсим цену из строки)
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
    
    /// Парсит мощность станции из строки (например "150 kW" -> 150.0)
    private static func parseStationPower(_ powerString: String) -> Double {
        let components = powerString.components(separatedBy: " ")
        if let firstComponent = components.first,
           let power = Double(firstComponent) {
            return power
        }
        return 50.0 // значение по умолчанию
    }
    
    /// Парсит цену из строки (например "50 ₸/kWh" -> 50.0)
    private static func parseStationPrice(_ priceString: String) -> Double {
        // Убираем все нецифровые символы кроме точки
        let numericString = priceString.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
        return Double(numericString) ?? 50.0 // значение по умолчанию
    }
}

// MARK: - Compatibility View Component
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
                // Совместимо
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16, weight: .semibold))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(languageManager.localizedString("compatible"))
                            .font(fontManager.font(.subheadline, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            Text(calc.formattedTime(languageManager: languageManager))
                                .font(fontManager.font(.caption, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text(calc.formattedCost())
                                .font(fontManager.font(.caption, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // Не совместимо
                HStack(spacing: 8) {
                    Image(systemName: "xmark.seal.fill")
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
            // Автомобиль не выбран
            Button(action: onCarSelection) {
                HStack(spacing: 8) {
                    Image(systemName: "slash.circle")
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
