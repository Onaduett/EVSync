//
//  ConnectorType.swift
//  EVSync
//
//  Created by Daulet Yerkinov on 28.08.25.
//



import Foundation

enum ConnectorType: String, CaseIterable {
    case ccs = "CCS"
    case chademo = "CHAdeMO"
    case type2 = "Type2"
    case tesla = "Tesla"
    
    var icon: String {
        switch self {
        case .ccs: return "bolt.car"
        case .chademo: return "bolt.car.fill"
        case .type2: return "car.2"
        case .tesla: return "bolt.slash"
        }
    }
}
