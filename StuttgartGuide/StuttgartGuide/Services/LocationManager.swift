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

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var nearbyPOI: POI?

    private let pois = POI.stuttgartPOIs
    private var lastTriggeredPOI: UUID?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10 // Update every 10 meters
        locationManager.allowsBackgroundLocationUpdates = false // Set to true for background tracking
        locationManager.pausesLocationUpdatesAutomatically = true
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

    private func checkForNearbyPOI() {
        guard let currentLocation = location else { return }

        // Find the nearest POI within range
        for poi in pois {
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
