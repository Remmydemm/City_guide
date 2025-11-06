//
//  ContentView.swift
//  StuttgartGuide
//
//  Main view coordinating all components
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var audioGuide = AudioGuide()
    @StateObject private var ttsService = TextToSpeechService()

    @State private var claudeAPIService: ClaudeAPIService?
    @State private var apiKey: String = ""
    @State private var isAPIKeySet: Bool = false
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            if !isAPIKeySet {
                apiKeySetupView
            } else {
                mainGuideView
            }
        }
        .onChange(of: locationManager.nearbyPOI) { newPOI in
            if let poi = newPOI, !audioGuide.hasVisited(poi) {
                handleNearbyPOI(poi)
            }
        }
    }

    // MARK: - API Key Setup View

    private var apiKeySetupView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Stuttgart Audio Guide")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Enter your Claude API Key to begin")
                .foregroundColor(.secondary)

            SecureField("API Key", text: $apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: setupAPIKey) {
                Text("Start Exploring")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(apiKey.isEmpty)

            Text("You'll need location permission to use this app")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .padding()
    }

    // MARK: - Main Guide View

    private var mainGuideView: some View {
        VStack(spacing: 0) {
            // Persona Selector
            PersonaSelectorView(selectedPersona: $audioGuide.selectedPersona)
                .padding()
                .background(Color(.systemBackground))
                .shadow(radius: 2)

            // Map View
            MapView(
                userLocation: locationManager.location,
                pois: locationManager.availablePOIs,
                visitedPOIs: audioGuide.visitedPOIs
            )
            .frame(maxHeight: .infinity)

            // Status & Audio Controls
            VStack(spacing: 12) {
                statusView
                AudioControlsView(
                    state: audioGuide.state,
                    isPaused: ttsService.isPaused,
                    onPlayPause: handlePlayPause,
                    onStop: handleStop
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 5)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Audio Guide")
                        .font(.headline)
                    Text("\(locationManager.availablePOIs.count) POIs")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleDiscoveryMode) {
                    Image(systemName: locationManager.useDynamicDiscovery ? "globe" : "book.fill")
                        .foregroundColor(locationManager.useDynamicDiscovery ? .green : .blue)
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Status View

    private var statusView: some View {
        Group {
            switch audioGuide.state {
            case .idle:
                HStack {
                    Image(systemName: "location.circle")
                        .foregroundColor(.blue)
                    Text("Exploring Stuttgart...")
                        .foregroundColor(.secondary)
                }
            case .generating:
                HStack {
                    ProgressView()
                    Text("Generating narration...")
                        .foregroundColor(.secondary)
                }
            case .playing:
                if let poi = audioGuide.currentPOI {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Now Playing")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(poi.name)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            case .paused:
                if let poi = audioGuide.currentPOI {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Paused")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(poi.name)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            case .error(let message):
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text(message)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .frame(height: 44)
    }

    // MARK: - Actions

    private func setupAPIKey() {
        claudeAPIService = ClaudeAPIService(apiKey: apiKey)
        isAPIKeySet = true
        locationManager.requestPermission()
    }

    private func handleNearbyPOI(_ poi: POI) {
        // Stop current playback
        ttsService.stop()

        audioGuide.currentPOI = poi
        audioGuide.state = .generating

        Task {
            do {
                guard let service = claudeAPIService else { return }
                let narration = try await service.generateNarration(for: poi, persona: audioGuide.selectedPersona)

                await MainActor.run {
                    audioGuide.narrationText = narration
                    audioGuide.state = .playing
                    audioGuide.markPOIAsVisited(poi)
                    ttsService.speak(text: narration)
                    locationManager.resetTrigger()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to generate narration: \(error.localizedDescription)"
                    showingError = true
                    audioGuide.state = .error(error.localizedDescription)
                }
            }
        }
    }

    private func handlePlayPause() {
        if ttsService.isPaused {
            ttsService.resume()
            audioGuide.state = .playing
        } else if ttsService.isSpeaking {
            ttsService.pause()
            audioGuide.state = .paused
        } else if !audioGuide.narrationText.isEmpty {
            // Replay current narration
            ttsService.speak(text: audioGuide.narrationText)
            audioGuide.state = .playing
        }
    }

    private func handleStop() {
        ttsService.stop()
        audioGuide.reset()
        locationManager.resetTrigger()
    }

    private func toggleDiscoveryMode() {
        locationManager.toggleDynamicDiscovery(!locationManager.useDynamicDiscovery)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
