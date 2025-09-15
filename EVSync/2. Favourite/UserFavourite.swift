//
//  UserFavourite.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 15.09.25.
//


import Foundation

struct UserFavorite: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let stationId: UUID
    let createdAt: String
    let station: DatabaseChargingStation?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case stationId = "station_id"
        case createdAt = "created_at"
        case station = "charging_stations"
    }
}
