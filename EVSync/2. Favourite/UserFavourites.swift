//
//  UserFavourites.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 23.09.25.
//

import SwiftUI

struct UserFavorite: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let stationId: UUID
    let createdAt: String
    let station: ChargingStation?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case stationId = "station_id"
        case createdAt = "created_at"
        case station
    }
    
    // Custom encoding/decoding for ChargingStation since it's not Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        stationId = try container.decode(UUID.self, forKey: .stationId)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        
        // Decode station from APIChargingStation if present
        if let apiStation = try container.decodeIfPresent(APIChargingStation.self, forKey: .station) {
            station = apiStation.toChargingStation()
        } else {
            station = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(stationId, forKey: .stationId)
        try container.encode(createdAt, forKey: .createdAt)
        // Note: ChargingStation is not encoded back as it's read-only from API
    }
    
    // Convenience initializer for manual creation
    init(id: UUID, userId: UUID, stationId: UUID, createdAt: String, station: ChargingStation?) {
        self.id = id
        self.userId = userId
        self.stationId = stationId
        self.createdAt = createdAt
        self.station = station
    }
}

// Note: Removed the duplicate toChargingStation() method extension
// The method is already defined in APIChargingStation in APIManager.swift
