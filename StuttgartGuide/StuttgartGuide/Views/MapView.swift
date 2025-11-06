//
//  MapView.swift
//  StuttgartGuide
//
//  Map display with POIs
//

import SwiftUI
import MapKit

struct MapView: View {
    let userLocation: CLLocation?
    let pois: [POI]
    let visitedPOIs: Set<UUID>

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.7758, longitude: 9.1829), // Stuttgart center
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: pois) { poi in
            MapAnnotation(coordinate: poi.coordinate) {
                POIMarker(
                    poi: poi,
                    isVisited: visitedPOIs.contains(poi.id)
                )
            }
        }
        .onChange(of: userLocation) { newLocation in
            if let location = newLocation {
                region.center = location.coordinate
            }
        }
    }
}

struct POIMarker: View {
    let poi: POI
    let isVisited: Bool

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: isVisited ? "checkmark.circle.fill" : "mappin.circle.fill")
                .font(.title)
                .foregroundColor(isVisited ? .green : .red)

            Text(poi.name)
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(4)
                .background(Color.white.opacity(0.9))
                .cornerRadius(4)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(
            userLocation: nil,
            pois: POI.stuttgartPOIs,
            visitedPOIs: []
        )
    }
}
