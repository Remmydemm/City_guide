//
//  AudioGuide.swift
//  StuttgartGuide
//
//  Audio guide state management
//

import Foundation
import Combine

enum AudioGuideState {
    case idle
    case generating
    case playing
    case paused
    case error(String)
}

class AudioGuide: ObservableObject {
    @Published var currentPOI: POI?
    @Published var selectedPersona: Persona = .historyBuff
    @Published var narrationText: String = ""
    @Published var state: AudioGuideState = .idle
    @Published var visitedPOIs: Set<UUID> = []

    func markPOIAsVisited(_ poi: POI) {
        visitedPOIs.insert(poi.id)
    }

    func hasVisited(_ poi: POI) -> Bool {
        visitedPOIs.contains(poi.id)
    }

    func reset() {
        currentPOI = nil
        narrationText = ""
        state = .idle
    }
}
