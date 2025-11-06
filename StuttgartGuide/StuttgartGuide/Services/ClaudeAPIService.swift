//
//  ClaudeAPIService.swift
//  StuttgartGuide
//
//  Claude API integration for generating tour narrations
//

import Foundation

class ClaudeAPIService {
    private let apiKey: String
    private let model = "claude-sonnet-4-5-20250929"
    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func generateNarration(for poi: POI, persona: Persona) async throws -> String {
        let userMessage = """
        Location: \(poi.name)
        Description: \(poi.shortDescription)
        Coordinates: \(poi.coordinate.latitude), \(poi.coordinate.longitude)

        Please provide an engaging audio tour narration for this location in Stuttgart, Germany.
        """

        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "system": persona.systemPrompt,
            "messages": [
                [
                    "role": "user",
                    "content": userMessage
                ]
            ]
        ]

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        let jsonResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)

        guard let textContent = jsonResponse.content.first(where: { $0.type == "text" })?.text else {
            throw APIError.noContent
        }

        return textContent
    }
}

// MARK: - Response Models

struct ClaudeResponse: Codable {
    let content: [ContentBlock]
}

struct ContentBlock: Codable {
    let type: String
    let text: String?
}

// MARK: - Errors

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case noContent

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return "HTTP \(statusCode): \(message)"
        case .noContent:
            return "No content in response"
        }
    }
}
