//
//  POIDiscoveryService.swift
//  StuttgartGuide
//
//  Dynamic POI discovery using MapKit and optional Google Places
//

import Foundation
import MapKit
import CoreLocation

class POIDiscoveryService: ObservableObject {
    @Published var discoveredPOIs: [POI] = []
    @Published var isDiscovering = false

    private var lastDiscoveryLocation: CLLocation?
    private let minimumDistanceForNewDiscovery: CLLocationDistance = 1000 // 1km

    // POI categories to search for
    private let touristCategories: [MKPointOfInterestCategory] = [
        .museum,
        .park,
        .theater,
        .castle,
        .landmark,
        .nationalPark,
        .zoo,
        .aquarium,
        .library,
        .stadium,
        .publicTransport
    ]

    /// Discover POIs near the given location using MapKit
    func discoverPOIs(near location: CLLocation) async throws -> [POI] {
        // Avoid rediscovering if we're still near the last discovery location
        if let lastLocation = lastDiscoveryLocation,
           location.distance(from: lastLocation) < minimumDistanceForNewDiscovery {
            return discoveredPOIs
        }

        await MainActor.run {
            isDiscovering = true
        }

        defer {
            Task { @MainActor in
                isDiscovering = false
            }
        }

        // Search in 5km radius
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )

        let request = MKLocalPointsOfInterestRequest(
            center: location.coordinate,
            radius: 5000
        )
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: touristCategories)

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        // Convert MKMapItems to POI objects
        let pois = response.mapItems.compactMap { mapItem -> POI? in
            guard let name = mapItem.name,
                  let category = mapItem.pointOfInterestCategory else {
                return nil
            }

            return POI(
                name: name,
                coordinate: mapItem.placemark.coordinate,
                radius: 30, // Default radius
                shortDescription: generateDescription(for: category),
                category: category.rawValue,
                phoneNumber: mapItem.phoneNumber,
                url: mapItem.url
            )
        }

        // Sort by distance from user
        let sortedPOIs = pois.sorted { poi1, poi2 in
            let loc1 = CLLocation(latitude: poi1.coordinate.latitude, longitude: poi1.coordinate.longitude)
            let loc2 = CLLocation(latitude: poi2.coordinate.latitude, longitude: poi2.coordinate.longitude)
            return location.distance(from: loc1) < location.distance(from: loc2)
        }

        // Limit to top 20 POIs
        let limitedPOIs = Array(sortedPOIs.prefix(20))

        await MainActor.run {
            self.discoveredPOIs = limitedPOIs
            self.lastDiscoveryLocation = location
        }

        return limitedPOIs
    }

    /// Generate a short description based on POI category
    private func generateDescription(for category: MKPointOfInterestCategory) -> String {
        switch category {
        case .museum:
            return "Cultural museum and exhibition space"
        case .park:
            return "Public park and green space"
        case .theater:
            return "Theater and performing arts venue"
        case .castle:
            return "Historic castle and fortification"
        case .landmark:
            return "Notable landmark and point of interest"
        case .nationalPark:
            return "National park and nature reserve"
        case .zoo:
            return "Zoological park and wildlife center"
        case .aquarium:
            return "Aquarium and marine life center"
        case .library:
            return "Public library and knowledge center"
        case .stadium:
            return "Sports stadium and event venue"
        case .publicTransport:
            return "Public transportation hub"
        default:
            return "Point of interest"
        }
    }

    /// Clear cached POIs
    func clearCache() {
        discoveredPOIs = []
        lastDiscoveryLocation = nil
    }
}

// MARK: - POI Category Extension

extension POI {
    var categoryIcon: String {
        switch category {
        case "museum": return "building.columns"
        case "park": return "leaf.fill"
        case "theater": return "theatermasks"
        case "castle": return "building.2"
        case "landmark": return "mappin.circle.fill"
        case "nationalPark": return "tree.fill"
        case "zoo": return "pawprint.fill"
        case "aquarium": return "drop.fill"
        case "library": return "book.fill"
        case "stadium": return "sportscourt.fill"
        case "publicTransport": return "tram.fill"
        default: return "mappin.circle.fill"
        }
    }
}
