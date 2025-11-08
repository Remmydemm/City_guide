//
//  POI.swift
//  StuttgartGuide
//
//  Point of Interest model with Stuttgart locations
//

import Foundation
import CoreLocation

struct POI: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let radius: Double // meters for geofencing
    let shortDescription: String
    let category: String? // POI category (museum, park, etc.)
    let phoneNumber: String? // Optional phone number
    let url: URL? // Optional website URL
    let source: POISource // Where this POI came from

    // Convenience initializer for hardcoded POIs
    init(name: String, coordinate: CLLocationCoordinate2D, radius: Double, shortDescription: String,
         category: String? = nil, phoneNumber: String? = nil, url: URL? = nil, source: POISource = .hardcoded) {
        self.name = name
        self.coordinate = coordinate
        self.radius = radius
        self.shortDescription = shortDescription
        self.category = category
        self.phoneNumber = phoneNumber
        self.url = url
        self.source = source
    }

    static func == (lhs: POI, rhs: POI) -> Bool {
        lhs.id == rhs.id
    }

    static let stuttgartPOIs: [POI] = [
        POI(
            name: "Schlossplatz & Neues Schloss",
            coordinate: CLLocationCoordinate2D(latitude: 48.7784, longitude: 9.1800),
            radius: 30,
            shortDescription: "The heart of Stuttgart - baroque palace and central square"
        ),
        POI(
            name: "Fernsehturm Stuttgart",
            coordinate: CLLocationCoordinate2D(latitude: 48.7557, longitude: 9.1900),
            radius: 30,
            shortDescription: "World's first TV tower built from reinforced concrete"
        ),
        POI(
            name: "Staatstheater Stuttgart",
            coordinate: CLLocationCoordinate2D(latitude: 48.7809, longitude: 9.1854),
            radius: 30,
            shortDescription: "One of Europe's leading opera houses and theaters"
        ),
        POI(
            name: "Markthalle Stuttgart",
            coordinate: CLLocationCoordinate2D(latitude: 48.7770, longitude: 9.1821),
            radius: 25,
            shortDescription: "Historic Art Nouveau market hall since 1914"
        ),
        POI(
            name: "Stiftskirche",
            coordinate: CLLocationCoordinate2D(latitude: 48.7767, longitude: 9.1775),
            radius: 25,
            shortDescription: "Stuttgart's main Protestant church from the 12th century"
        )
    ]
}

// MARK: - POI Source

enum POISource {
    case hardcoded      // Manually curated POIs
    case mapKit         // Discovered via MapKit
    case googlePlaces   // Discovered via Google Places API
}

// MARK: - POI Extensions

extension POI {
    func isNearby(to location: CLLocation) -> Bool {
        let poiLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = location.distance(from: poiLocation)
        return distance <= radius
    }

    func distanceFrom(_ location: CLLocation) -> CLLocationDistance {
        let poiLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location.distance(from: poiLocation)
    }
}
