//
//  OpenAIModels.swift
//  reed-test
//
//  Models for OpenAI API requests and responses
//

import Foundation
import UIKit

// MARK: - GPT-4 Vision Models

struct VisionRequest: Codable {
    let model: String
    let messages: [VisionMessage]
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
    }
}

struct VisionMessage: Codable {
    let role: String
    let content: [VisionContent]
}

struct VisionContent: Codable {
    let type: String
    let text: String?
    let imageUrl: VisionImageUrl?

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageUrl = "image_url"
    }
}

struct VisionImageUrl: Codable {
    let url: String
}

struct VisionResponse: Codable {
    let id: String
    let choices: [VisionChoice]
}

struct VisionChoice: Codable {
    let message: VisionResponseMessage
}

struct VisionResponseMessage: Codable {
    let content: String
}

// MARK: - DALL-E 3 Models

struct DallERequest: Codable {
    let model: String
    let prompt: String
    let n: Int
    let size: String
}

struct DallEResponse: Codable {
    let created: Int
    let data: [DallEImage]
}

struct DallEImage: Codable {
    let url: String
}

// MARK: - Error Models

struct OpenAIError: Codable {
    let error: ErrorDetail
}

struct ErrorDetail: Codable {
    let message: String
    let type: String
    let code: String?
}
