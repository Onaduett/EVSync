//
//  APIManager.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 23.09.25.
//

import Foundation
import Combine

// MARK: - API Models
struct APIUserFavorite: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let stationId: UUID
    let createdAt: String
    let station: APIChargingStation?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case stationId = "station_id"
        case createdAt = "created_at"
        case station = "charging_station"
    }
}

struct APIChargingStation: Codable, Identifiable {
    let id: UUID
    let name: String
    let address: String
    let provider: String
    let power: String
    let price: String
    let availability: String
    let connectorTypes: [String]
    let latitude: Double
    let longitude: Double
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, provider, power, price, availability, latitude, longitude
        case connectorTypes = "connector_types"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    func toChargingStation() -> ChargingStation {
        return ChargingStation(
            id: id,
            name: name,
            address: address,
            provider: provider,
            power: power,
            price: price,
            availability: StationAvailability(rawValue: availability) ?? .unknown,
            connectorTypes: connectorTypes.compactMap { ConnectorType(rawValue: $0) },
            latitude: latitude,
            longitude: longitude
        )
    }
}

struct FavoriteResponse: Codable {
    let data: [APIUserFavorite]
    let count: Int
}

struct FavoriteIDsResponse: Codable {
    let favoriteIds: [UUID]
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case favoriteIds = "favorite_ids"
        case count
    }
}

struct CheckFavoriteResponse: Codable {
    let isFavorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case isFavorite = "is_favorite"
    }
}

struct AddFavoriteRequest: Codable {
    let stationId: UUID
    
    enum CodingKeys: String, CodingKey {
        case stationId = "station_id"
    }
}

struct APIErrorResponse: Codable {
    let error: String
    let message: String?
}

// MARK: - API Manager
class APIManager: ObservableObject {
    static let shared = APIManager()
    
    private let baseURL = "http://localhost:8080/api"
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var favoriteIds: Set<UUID> = []
    
    // Add a default user ID for now - you should replace this with proper user management
    private let defaultUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID()
    
    private init() {}
    
    // MARK: - Public Methods (Missing methods that StationDetailCard needs)
    
    /// Sync favorites for the current user
    func syncFavorites() async {
        do {
            try await syncFavoriteIds(for: defaultUserId)
        } catch {
            print("Failed to sync favorites: \(error)")
        }
    }
    
    /// Add a station to favorites
    func addFavorite(stationId: UUID) async throws {
        try await addToFavorites(userId: defaultUserId, stationId: stationId)
    }
    
    /// Remove a station from favorites
    func removeFavorite(stationId: UUID) async throws {
        try await removeFromFavorites(userId: defaultUserId, stationId: stationId)
    }
    
    // MARK: - Private Methods
    private func createRequest(url: URL, method: HTTPMethod, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if needed
        // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    private func handleResponse<T: Codable>(_ data: Data, _ response: URLResponse, type: T.Type) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode >= 400 {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.message ?? errorResponse.error)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            return try decoder.decode(type, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
    
    // MARK: - API Methods
    @MainActor
    func syncFavoriteIds(for userId: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/favorites/\(userId.uuidString)/ids") else {
            throw APIError.invalidURL
        }
        
        let request = createRequest(url: url, method: .GET)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let result: FavoriteIDsResponse = try handleResponse(data, response, type: FavoriteIDsResponse.self)
        
        favoriteIds = Set(result.favoriteIds)
    }
    
    func getFavoriteStations(for userId: UUID) async throws -> [UserFavorite] {
        guard let url = URL(string: "\(baseURL)/favorites/\(userId.uuidString)") else {
            throw APIError.invalidURL
        }
        
        let request = createRequest(url: url, method: .GET)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let result: FavoriteResponse = try handleResponse(data, response, type: FavoriteResponse.self)
        
        return result.data.map { apiFavorite in
            UserFavorite(
                id: apiFavorite.id,
                userId: apiFavorite.userId,
                stationId: apiFavorite.stationId,
                createdAt: apiFavorite.createdAt,
                station: apiFavorite.station?.toChargingStation()
            )
        }
    }
    
    func addToFavorites(userId: UUID, stationId: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/favorites/\(userId.uuidString)") else {
            throw APIError.invalidURL
        }
        
        let requestBody = AddFavoriteRequest(stationId: stationId)
        let bodyData = try JSONEncoder().encode(requestBody)
        
        let request = createRequest(url: url, method: .POST, body: bodyData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let _: [String: String] = try handleResponse(data, response, type: [String: String].self)
        
        await MainActor.run {
            favoriteIds.insert(stationId)
        }
    }
    
    func removeFromFavorites(favoriteId: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/favorites/\(favoriteId.uuidString)") else {
            throw APIError.invalidURL
        }
        
        let request = createRequest(url: url, method: .DELETE)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let _: [String: String] = try handleResponse(data, response, type: [String: String].self)
    }
    
    func removeFromFavorites(userId: UUID, stationId: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/favorites/\(userId.uuidString)/stations/\(stationId.uuidString)") else {
            throw APIError.invalidURL
        }
        
        let request = createRequest(url: url, method: .DELETE)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let _: [String: String] = try handleResponse(data, response, type: [String: String].self)
        
        await MainActor.run {
            favoriteIds.remove(stationId)
        }
    }
    
    func isStationFavorited(userId: UUID, stationId: UUID) async throws -> Bool {
        // Check local cache first
        if favoriteIds.contains(stationId) {
            return true
        }
        
        guard let url = URL(string: "\(baseURL)/favorites/\(userId.uuidString)/check/\(stationId.uuidString)") else {
            throw APIError.invalidURL
        }
        
        let request = createRequest(url: url, method: .GET)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let result: CheckFavoriteResponse = try handleResponse(data, response, type: CheckFavoriteResponse.self)
        
        if result.isFavorite {
            await MainActor.run {
                favoriteIds.insert(stationId)
            }
        }
        
        return result.isFavorite
    }
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - API Error Enum
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
