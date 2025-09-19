//
//  FavoriteManager.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 19.09.25.
//

import Foundation
import Combine

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteStationIds: Set<UUID> = []
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteStations"
    
    private init() {
        loadFavorites()
    }
    
    func addToFavorites(_ station: ChargingStation) {
        favoriteStationIds.insert(station.id)
        saveFavorites()
    }
    
    func removeFromFavorites(_ station: ChargingStation) {
        favoriteStationIds.remove(station.id)
        saveFavorites()
    }
    
    func toggleFavorite(_ station: ChargingStation) {
        if favoriteStationIds.contains(station.id) {
            removeFromFavorites(station)
        } else {
            addToFavorites(station)
        }
    }
    
    func isFavorite(_ station: ChargingStation) -> Bool {
        return favoriteStationIds.contains(station.id)
    }
    
    private func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let uuidStrings = try? JSONDecoder().decode([String].self, from: data) {
            favoriteStationIds = Set(uuidStrings.compactMap { UUID(uuidString: $0) })
        }
    }
    
    private func saveFavorites() {
        let uuidStrings = favoriteStationIds.map { $0.uuidString }
        if let data = try? JSONEncoder().encode(uuidStrings) {
            userDefaults.set(data, forKey: favoritesKey)
        }
    }
}
