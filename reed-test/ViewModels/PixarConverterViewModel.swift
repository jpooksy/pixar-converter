//
//  PixarConverterViewModel.swift
//  reed-test
//
//  ViewModel to handle app state and API calls
//

import Foundation
import UIKit
import SwiftUI
import Combine

@MainActor
class PixarConverterViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var pixarImage: UIImage?
    @Published var isProcessing = false
    @Published var currentStep: ProcessingStep = .idle
    @Published var errorMessage: String?

    private let backendService: BackendService
    private var imageDescription: String?

    enum ProcessingStep {
        case idle
        case analyzingImage
        case generatingPixarImage
        case downloadingResult
        case completed

        var description: String {
            switch self {
            case .idle:
                return "Ready to convert"
            case .analyzingImage:
                return "Analyzing your image..."
            case .generatingPixarImage:
                return "Creating Pixar-style image..."
            case .downloadingResult:
                return "Downloading result..."
            case .completed:
                return "Conversion complete!"
            }
        }
    }

    init() {
        self.backendService = BackendService()
    }

    // MARK: - Main Conversion Flow

    func convertToPixarStyle() async {
        guard let image = selectedImage else {
            errorMessage = "Please select an image first"
            return
        }

        isProcessing = true
        errorMessage = nil
        pixarImage = nil
        currentStep = .idle

        do {
            // Step 1: Analyze image with GPT-4 Vision (via backend)
            currentStep = .analyzingImage
            let description = try await backendService.analyzeImage(image)
            imageDescription = description

            // Step 2: Generate Pixar-style image with DALL-E 3 (via backend)
            currentStep = .generatingPixarImage
            let imageUrl = try await backendService.generatePixarImage(from: description)

            // Step 3: Download the generated image
            currentStep = .downloadingResult
            let generatedImage = try await backendService.downloadImage(from: imageUrl)
            pixarImage = generatedImage

            currentStep = .completed
        } catch {
            handleError(error)
        }

        isProcessing = false
    }

    // MARK: - Image Selection

    func selectImage(_ image: UIImage) {
        selectedImage = image
        pixarImage = nil
        errorMessage = nil
        currentStep = .idle
    }

    // MARK: - Reset

    func reset() {
        selectedImage = nil
        pixarImage = nil
        isProcessing = false
        currentStep = .idle
        errorMessage = nil
        imageDescription = nil
    }

    // MARK: - Error Handling

    private func handleError(_ error: Error) {
        currentStep = .idle
        if let backendError = error as? BackendServiceError {
            errorMessage = backendError.errorDescription
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
    }

    // MARK: - Save Image

    func savePixarImage() {
        guard let image = pixarImage else {
            errorMessage = "No image to save"
            return
        }

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
