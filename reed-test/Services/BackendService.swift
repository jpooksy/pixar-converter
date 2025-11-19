//
//  BackendService.swift
//  reed-test
//
//  Service layer for backend API calls
//

import Foundation
import UIKit

enum BackendServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case serverError(String)
    case imageConversionFailed
    case rateLimitExceeded

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL configuration."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .imageConversionFailed:
            return "Failed to convert image to required format."
        case .rateLimitExceeded:
            return "You've reached the usage limit. Please try again later."
        }
    }
}

class BackendService {
    // TODO: Replace with your Vercel deployment URL after deploying
    // For local testing: "http://localhost:3000"
    // For production: "https://your-app.vercel.app"
    private let baseURL = "https://pixar-backend-seven.vercel.app"

    private let deviceId: String

    init() {
        // Generate or retrieve a unique device ID
        if let savedDeviceId = UserDefaults.standard.string(forKey: "device_id") {
            self.deviceId = savedDeviceId
        } else {
            let newDeviceId = UUID().uuidString
            UserDefaults.standard.set(newDeviceId, forKey: "device_id")
            self.deviceId = newDeviceId
        }
    }

    // MARK: - Analyze Image

    func analyzeImage(_ image: UIImage) async throws -> String {
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw BackendServiceError.imageConversionFailed
        }
        let base64Image = imageData.base64EncodedString()
        let imageDataURL = "data:image/jpeg;base64,\(base64Image)"

        // Create request
        guard let url = URL(string: "\(baseURL)/api/analyze-image") else {
            throw BackendServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(deviceId, forHTTPHeaderField: "X-Device-Id")

        let requestBody: [String: Any] = ["image": imageDataURL]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Make API call
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendServiceError.invalidResponse
        }

        // Handle rate limiting
        if httpResponse.statusCode == 429 {
            throw BackendServiceError.rateLimitExceeded
        }

        guard httpResponse.statusCode == 200 else {
            // Try to decode error message
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = json["error"] as? String {
                throw BackendServiceError.serverError(errorMessage)
            }
            throw BackendServiceError.serverError("Server error (HTTP \(httpResponse.statusCode))")
        }

        // Parse response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let description = json["description"] as? String else {
            throw BackendServiceError.invalidResponse
        }

        return description
    }

    // MARK: - Generate Pixar Image

    func generatePixarImage(from description: String) async throws -> URL {
        // Create request
        guard let url = URL(string: "\(baseURL)/api/generate-pixar") else {
            throw BackendServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(deviceId, forHTTPHeaderField: "X-Device-Id")

        let requestBody: [String: Any] = ["description": description]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Make API call
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendServiceError.invalidResponse
        }

        // Handle rate limiting
        if httpResponse.statusCode == 429 {
            throw BackendServiceError.rateLimitExceeded
        }

        guard httpResponse.statusCode == 200 else {
            // Try to decode error message
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = json["error"] as? String {
                throw BackendServiceError.serverError(errorMessage)
            }
            throw BackendServiceError.serverError("Server error (HTTP \(httpResponse.statusCode))")
        }

        // Parse response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let imageUrlString = json["imageUrl"] as? String,
              let imageUrl = URL(string: imageUrlString) else {
            throw BackendServiceError.invalidResponse
        }

        return imageUrl
    }

    // MARK: - Download Image

    func downloadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw BackendServiceError.invalidResponse
        }
        return image
    }
}
