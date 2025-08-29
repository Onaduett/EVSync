//
//  ConnectorType.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import Foundation

enum ConnectorType: String, CaseIterable {
    // Европейские/международные стандарты
    case ccs1 = "CCS1"              // CCS Combo 1 (США)
    case ccs2 = "CCS2"              // CCS Combo 2 (Европа) - самый популярный в Казахстане
    case type1 = "Type 1"           // J1772 (США, Япония)
    case type2 = "Type 2"           // Mennekes (Европа) - популярный AC разъем
    case type3 = "Type 3"           // Scame (Италия, Франция) - редкий
    
    // Азиатские стандарты
    case chademo = "CHAdeMO"        // Японский стандарт DC
    case gbT = "GB/T"               // Китайский стандарт
    
    // Tesla разъемы
    case tesla = "Tesla"            // Tesla Supercharger (оригинальный)
    case teslaDestination = "Tesla Destination" // Tesla Destination Charger
    case nacs = "NACS"              // Tesla North American Charging Standard
    
    // Бытовые розетки
    case schuko = "Schuko"          // Европейская бытовая розетка CEE 7/4
    case cee = "CEE"                // Промышленные разъемы CEE (синие)
    case cee32 = "CEE 32A"          // CEE 32 Ампер
    case cee63 = "CEE 63A"          // CEE 63 Ампер
    case nema515 = "NEMA 5-15"      // США бытовая розетка
    case nema1450 = "NEMA 14-50"    // США мощная розетка (RV/электроплита)
    
    // Специальные/устаревшие
    case avcon = "AVCON"            // Австралийский стандарт (устарел)
    case commando = "Commando"      // Британские промышленные разъемы
    case xlr = "XLR"                // Старые разъемы для легких ТС
    case sae = "SAE J1772"          // Полное название Type 1
    
    // Универсальные/неопределенные
    case universal = "Universal"     // Универсальные станции
    case other = "Other"            // Другие типы
    case unknown = "Unknown"        // Неизвестный тип
    
    var displayName: String {
        switch self {
        case .ccs1: return "CCS Combo 1"
        case .ccs2: return "CCS Combo 2"
        case .type1: return "Type 1 (J1772)"
        case .type2: return "Type 2 (Mennekes)"
        case .type3: return "Type 3 (Scame)"
        case .chademo: return "CHAdeMO"
        case .gbT: return "GB/T (China)"
        case .tesla: return "Tesla Supercharger"
        case .teslaDestination: return "Tesla Destination"
        case .nacs: return "NACS (Tesla)"
        case .schuko: return "Schuko (бытовая)"
        case .cee: return "CEE"
        case .cee32: return "CEE 32A"
        case .cee63: return "CEE 63A"
        case .nema515: return "NEMA 5-15"
        case .nema1450: return "NEMA 14-50"
        case .avcon: return "AVCON"
        case .commando: return "Commando"
        case .xlr: return "XLR"
        case .sae: return "SAE J1772"
        case .universal: return "Универсальная"
        case .other: return "Другой"
        case .unknown: return "Неизвестный"
        }
    }
    
    var icon: String {
        switch self {
        case .ccs1, .ccs2:
            return "bolt.car"
        case .chademo:
            return "bolt.car.fill"
        case .type1, .type2, .type3:
            return "car.2"
        case .tesla, .teslaDestination, .nacs:
            return "bolt.slash"
        case .gbT:
            return "bolt.square"
        case .schuko, .nema515:
            return "powerplug"
        case .cee, .cee32, .cee63, .commando:
            return "powerplug.fill"
        case .nema1450:
            return "poweroutlet.type.a"
        case .universal:
            return "bolt.horizontal.circle"
        case .avcon, .xlr, .sae:
            return "bolt.circle"
        case .other, .unknown:
            return "questionmark.circle"
        }
    }
}
