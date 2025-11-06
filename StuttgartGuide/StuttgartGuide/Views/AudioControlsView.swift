//
//  AudioControlsView.swift
//  StuttgartGuide
//
//  Audio playback controls
//

import SwiftUI

struct AudioControlsView: View {
    let state: AudioGuideState
    let isPaused: Bool
    let onPlayPause: () -> Void
    let onStop: () -> Void

    var body: some View {
        HStack(spacing: 30) {
            Button(action: onPlayPause) {
                Image(systemName: playPauseIcon)
                    .font(.system(size: 30))
                    .foregroundColor(isPlaybackAvailable ? .blue : .gray)
                    .frame(width: 50, height: 50)
            }
            .disabled(!isPlaybackAvailable)

            Button(action: onStop) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 30))
                    .foregroundColor(isStopAvailable ? .red : .gray)
                    .frame(width: 50, height: 50)
            }
            .disabled(!isStopAvailable)
        }
    }

    private var playPauseIcon: String {
        switch state {
        case .playing:
            return "pause.circle.fill"
        case .paused:
            return "play.circle.fill"
        case .idle, .generating, .error:
            return "play.circle.fill"
        }
    }

    private var isPlaybackAvailable: Bool {
        switch state {
        case .playing, .paused:
            return true
        case .idle, .generating, .error:
            return false
        }
    }

    private var isStopAvailable: Bool {
        switch state {
        case .playing, .paused:
            return true
        case .idle, .generating, .error:
            return false
        }
    }
}

struct AudioControlsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AudioControlsView(
                state: .playing,
                isPaused: false,
                onPlayPause: {},
                onStop: {}
            )

            AudioControlsView(
                state: .paused,
                isPaused: true,
                onPlayPause: {},
                onStop: {}
            )

            AudioControlsView(
                state: .idle,
                isPaused: false,
                onPlayPause: {},
                onStop: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
