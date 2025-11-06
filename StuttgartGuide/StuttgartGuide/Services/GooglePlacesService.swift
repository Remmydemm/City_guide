//
//  GooglePlacesService.swift
//  StuttgartGuide
//
//  Optional Google Places API integration for enhanced POI discovery
//

import Foundation
import CoreLocation

class GooglePlacesService {
    private let apiKey: String
    private let baseURL = "https://maps.googleapis.com/maps/api/place"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    /// Discover tourist attractions using Google Places Nearby Search
    func discoverPOIs(near location: CLLocation, radius: Int = 5000) async throws -> [POI] {
        let urlString = "\(baseURL)/nearbysearch/json"
        var components = URLComponents(string: urlString)!

        components.queryItems = [
            URLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)"),
            URLQueryItem(name: "radius", value: "\(radius)"),
            URLQueryItem(name: "type", value: "tourist_attraction"),
            URLQueryItem(name: "key", value: apiKey)
        ]

        guard let url = components.url else {
            throw GooglePlacesError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw GooglePlacesError.httpError(statusCode: httpResponse.statusCode)
        }

        let placesResponse = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)

        guard placesResponse.status == "OK" || placesResponse.status == "ZERO_RESULTS" else {
            throw GooglePlacesError.apiError(message: placesResponse.status)
        }

        // Convert Google Places to POI objects
        let pois = placesResponse.results.map { place -> POI in
            POI(
                name: place.name,
                coordinate: CLLocationCoordinate2D(
                    latitude: place.geometry.location.lat,
                    longitude: place.geometry.location.lng
                ),
                radius: 30,
                shortDescription: generateDescription(types: place.types, vicinity: place.vicinity),
                category: place.types.first,
                phoneNumber: nil,
                url: nil,
                source: .googlePlaces
            )
        }

        // Sort by prominence (Google's rating and user ratings total)
        return pois.sorted { poi1, poi2 in
            // For now, maintain Google's order (they already sort by prominence)
            return true
        }
    }

    /// Fetch detailed information about a specific place
    func getPlaceDetails(placeId: String) async throws -> PlaceDetails {
        let urlString = "\(baseURL)/details/json"
        var components = URLComponents(string: urlString)!

        components.queryItems = [
            URLQueryItem(name: "place_id", value: placeId),
            URLQueryItem(name: "fields", value: "name,formatted_address,formatted_phone_number,website,opening_hours,rating,user_ratings_total"),
            URLQueryItem(name: "key", value: apiKey)
        ]

        guard let url = components.url else {
            throw GooglePlacesError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw GooglePlacesError.httpError(statusCode: httpResponse.statusCode)
        }

        let detailsResponse = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)

        guard detailsResponse.status == "OK" else {
            throw GooglePlacesError.apiError(message: detailsResponse.status)
        }

        return detailsResponse.result
    }

    private func generateDescription(types: [String], vicinity: String?) -> String {
        let primaryType = types.first ?? "point of interest"

        let typeDescription: String
        switch primaryType {
        case "museum":
            typeDescription = "Museum and cultural exhibition"
        case "park":
            typeDescription = "Public park and recreational area"
        case "church":
            typeDescription = "Historic church and place of worship"
        case "art_gallery":
            typeDescription = "Art gallery and exhibition space"
        case "tourist_attraction":
            typeDescription = "Notable tourist attraction"
        case "landmark":
            typeDescription = "Historic landmark"
        case "zoo":
            typeDescription = "Zoo and wildlife center"
        case "stadium":
            typeDescription = "Sports stadium and venue"
        case "shopping_mall":
            typeDescription = "Shopping center"
        case "library":
            typeDescription = "Public library"
        default:
            typeDescription = "Point of interest"
        }

        if let vicinity = vicinity {
            return "\(typeDescription) - \(vicinity)"
        } else {
            return typeDescription
        }
    }
}

// MARK: - Response Models

struct GooglePlacesResponse: Codable {
    let results: [GooglePlace]
    let status: String
}

struct GooglePlace: Codable {
    let name: String
    let geometry: PlaceGeometry
    let types: [String]
    let vicinity: String?
    let placeId: String?

    enum CodingKeys: String, CodingKey {
        case name, geometry, types, vicinity
        case placeId = "place_id"
    }
}

struct PlaceGeometry: Codable {
    let location: PlaceLocation
}

struct PlaceLocation: Codable {
    let lat: Double
    let lng: Double
}

struct PlaceDetailsResponse: Codable {
    let result: PlaceDetails
    let status: String
}

struct PlaceDetails: Codable {
    let name: String
    let formattedAddress: String?
    let formattedPhoneNumber: String?
    let website: String?
    let rating: Double?
    let userRatingsTotal: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case formattedAddress = "formatted_address"
        case formattedPhoneNumber = "formatted_phone_number"
        case website, rating
        case userRatingsTotal = "user_ratings_total"
    }
}

// MARK: - Errors

enum GooglePlacesError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case apiError(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .apiError(let message):
            return "Google Places API error: \(message)"
        }
    }
}
