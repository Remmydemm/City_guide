//
//  LocationManager.swift
//  StuttgartGuide
//
//  GPS location tracking and geofencing
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let poiDiscoveryService = POIDiscoveryService()

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var nearbyPOI: POI?
    @Published var availablePOIs: [POI] = []
    @Published var useDynamicDiscovery: Bool = true // Toggle between hardcoded and dynamic

    private var lastTriggeredPOI: UUID?
    private var hasDiscoveredPOIs = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10 // Update every 10 meters
        locationManager.allowsBackgroundLocationUpdates = false // Set to true for background tracking
        locationManager.pausesLocationUpdatesAutomatically = true

        // Start with hardcoded POIs
        availablePOIs = POI.stuttgartPOIs
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    /// Discover POIs dynamically based on current location
    func discoverPOIsNearby() {
        guard let currentLocation = location, useDynamicDiscovery else { return }

        Task {
            do {
                let discoveredPOIs = try await poiDiscoveryService.discoverPOIs(near: currentLocation)

                // Merge with hardcoded POIs (remove duplicates by name proximity)
                let mergedPOIs = mergePOIs(hardcoded: POI.stuttgartPOIs, discovered: discoveredPOIs)

                await MainActor.run {
                    self.availablePOIs = mergedPOIs
                    self.hasDiscoveredPOIs = true
                }
            } catch {
                print("Failed to discover POIs: \(error)")
                // Fall back to hardcoded POIs
                await MainActor.run {
                    if self.availablePOIs.isEmpty {
                        self.availablePOIs = POI.stuttgartPOIs
                    }
                }
            }
        }
    }

    /// Merge hardcoded and discovered POIs, removing near-duplicates
    private func mergePOIs(hardcoded: [POI], discovered: [POI]) -> [POI] {
        var merged = hardcoded
        let duplicateThreshold: CLLocationDistance = 100 // 100 meters

        for discoveredPOI in discovered {
            let isDuplicate = hardcoded.contains { hardcodedPOI in
                let hardcodedLocation = CLLocation(
                    latitude: hardcodedPOI.coordinate.latitude,
                    longitude: hardcodedPOI.coordinate.longitude
                )
                let discoveredLocation = CLLocation(
                    latitude: discoveredPOI.coordinate.latitude,
                    longitude: discoveredPOI.coordinate.longitude
                )
                return hardcodedLocation.distance(from: discoveredLocation) < duplicateThreshold
            }

            if !isDuplicate {
                merged.append(discoveredPOI)
            }
        }

        return merged
    }

    private func checkForNearbyPOI() {
        guard let currentLocation = location else { return }

        // Discover POIs if we haven't yet and dynamic discovery is enabled
        if !hasDiscoveredPOIs && useDynamicDiscovery {
            discoverPOIsNearby()
        }

        // Find the nearest POI within range
        for poi in availablePOIs {
            if poi.isNearby(to: currentLocation) {
                // Only trigger if we haven't triggered this POI recently
                if lastTriggeredPOI != poi.id {
                    nearbyPOI = poi
                    lastTriggeredPOI = poi.id
                    return
                }
            }
        }
    }

    func resetTrigger() {
        lastTriggeredPOI = nil
        nearbyPOI = nil
    }

    func toggleDynamicDiscovery(_ enabled: Bool) {
        useDynamicDiscovery = enabled
        if enabled {
            hasDiscoveredPOIs = false
            discoverPOIsNearby()
        } else {
            availablePOIs = POI.stuttgartPOIs
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        checkForNearbyPOI()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startTracking()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
