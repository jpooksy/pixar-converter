//
//  OpenAIService.swift
//  reed-test
//
//  Service layer for OpenAI API calls
//

import Foundation
import UIKit

enum OpenAIServiceError: LocalizedError {
    case invalidAPIKey
    case invalidResponse
    case networkError(Error)
    case apiError(String)
    case imageConversionFailed

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your OpenAI API key."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let message):
            return "API error: \(message)"
        case .imageConversionFailed:
            return "Failed to convert image to base64."
        }
    }
}

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - GPT-4 Vision API

    func analyzeImage(_ image: UIImage) async throws -> String {
        guard !apiKey.isEmpty else {
            throw OpenAIServiceError.invalidAPIKey
        }

        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw OpenAIServiceError.imageConversionFailed
        }
        let base64Image = imageData.base64EncodedString()
        let imageUrl = "data:image/jpeg;base64,\(base64Image)"

        // Create request
        let request = VisionRequest(
            model: "gpt-4o",
            messages: [
                VisionMessage(
                    role: "user",
                    content: [
                        VisionContent(type: "text", text: "Describe this image in detail. Focus on the main subjects, their appearance, setting, and mood.", imageUrl: nil),
                        VisionContent(type: "image_url", text: nil, imageUrl: VisionImageUrl(url: imageUrl))
                    ]
                )
            ],
            maxTokens: 500
        )

        // Make API call
        let url = URL(string: "\(baseURL)/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            // Try to decode error message
            if let errorResponse = try? JSONDecoder().decode(OpenAIError.self, from: data) {
                print("OpenAI API Error: \(errorResponse.error.message)")
                throw OpenAIServiceError.apiError(errorResponse.error.message)
            }
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("API Response (Status \(httpResponse.statusCode)): \(responseString)")
            }
            throw OpenAIServiceError.apiError("HTTP \(httpResponse.statusCode): Unable to process request")
        }

        let visionResponse = try JSONDecoder().decode(VisionResponse.self, from: data)
        guard let description = visionResponse.choices.first?.message.content else {
            throw OpenAIServiceError.invalidResponse
        }

        return description
    }

    // MARK: - DALL-E 3 API

    func generatePixarImage(from description: String) async throws -> URL {
        guard !apiKey.isEmpty else {
            throw OpenAIServiceError.invalidAPIKey
        }

        // Create Pixar-style prompt
        let pixarPrompt = """
        Create an image in Pixar animation style with the following description:
        \(description)

        Use vibrant colors, expressive characters, and the distinctive Pixar 3D animated aesthetic.
        """

        // Create request
        let request = DallERequest(
            model: "dall-e-3",
            prompt: pixarPrompt,
            n: 1,
            size: "1024x1024"
        )

        // Make API call
        let url = URL(string: "\(baseURL)/images/generations")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            // Try to decode error message
            if let errorResponse = try? JSONDecoder().decode(OpenAIError.self, from: data) {
                print("OpenAI API Error: \(errorResponse.error.message)")
                throw OpenAIServiceError.apiError(errorResponse.error.message)
            }
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("API Response (Status \(httpResponse.statusCode)): \(responseString)")
            }
            throw OpenAIServiceError.apiError("HTTP \(httpResponse.statusCode): Unable to process request")
        }

        let dallEResponse = try JSONDecoder().decode(DallEResponse.self, from: data)
        guard let imageUrlString = dallEResponse.data.first?.url,
              let imageUrl = URL(string: imageUrlString) else {
            throw OpenAIServiceError.invalidResponse
        }

        return imageUrl
    }

    // MARK: - Helper Methods

    func downloadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw OpenAIServiceError.invalidResponse
        }
        return image
    }
}
