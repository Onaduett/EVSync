//
//  ConnectorType.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//

import Foundation
import SwiftUI

enum ConnectorType: String, CaseIterable {
    case ccs1 = "CCS1"              // CCS Combo 1 (США)
    case ccs2 = "CCS2"              // CCS Combo 2 (Европа) - самый популярный в Казахстане
    case type1 = "Type 1"           // J1772 (США, Япония)
    case type2 = "Type 2"           // Mennekes (Европа) - популярный AC разъем
    case chademo = "CHAdeMO"        // Японский стандарт DC
    case gbT = "GB/T"               // Китайский стандарт
    case tesla = "Tesla"            // Tesla Supercharger (оригинальный)
    case universal = "Universal"     // Универсальные станции
    
    var displayName: String {
        switch self {
        case .ccs1: return "CCS Combo 1"
        case .ccs2: return "CCS Combo 2"
        case .type1: return "Type 1 (J1772)"
        case .type2: return "Type 2 (Mennekes)"
        case .chademo: return "CHAdeMO"
        case .gbT: return "GB/T (China)"
        case .tesla: return "Tesla"
        case .universal: return "Универсальная"
        }
    }
    
    var icon: String {
        switch self {
        case .ccs1: return "ccs1"
        case .ccs2: return "ccs2"
        case .chademo: return "chademo"
        case .gbT: return "gbtdc"
        case .tesla: return "tesla"
        case .type1: return "type1"
        case .type2: return "type2"
        case .universal: return "type2"
        }
    }
}
