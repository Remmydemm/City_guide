//
//  TextToSpeechService.swift
//  StuttgartGuide
//
//  Text-to-speech audio playback
//

import Foundation
import AVFoundation
import Combine

class TextToSpeechService: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    @Published var isSpeaking = false
    @Published var isPaused = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(text: String, language: String = "en-US") {
        // Stop any current speech
        stop()

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9 // Slightly slower for clarity
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        isSpeaking = true
        isPaused = false
        synthesizer.speak(utterance)
    }

    func pause() {
        if synthesizer.isSpeaking && !isPaused {
            synthesizer.pauseSpeaking(at: .word)
            isPaused = true
        }
    }

    func resume() {
        if isPaused {
            synthesizer.continueSpeaking()
            isPaused = false
        }
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        isPaused = false
    }
}

extension TextToSpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
    }
}
