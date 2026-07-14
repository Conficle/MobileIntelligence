//  MobileIntelligence
//
//  Copyright (c) 2026 Nitin Manghwani
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import CryptoKit
import Foundation

protocol PredictionCache: Actor {
    func response(for key: PredictionCacheKey) async -> PredictionResponse?
    func store(_ response: PredictionResponse, for key: PredictionCacheKey) async
}

struct PredictionCacheKey: Hashable, Sendable {
    private static let version = "prediction:v1"

    let value: String

    init(provider: String,
         model: String,
         request: PredictionRequest) throws {
        let payload = PredictionCachePayload(
            provider: provider,
            model: model,
            promptInstructions: request.prompt?.instructions,
            query: request.query.question,
            temperature: request.temperature,
            maxTokens: request.maxTokens,
            reasoning: request.reasoning.cacheValue,
            contextFingerprint: request.context.cacheFingerprint
        )
        value = try Self.hash(payload)
    }

    init(value: String) {
        self.value = value
    }

    private static func hash(_ payload: PredictionCachePayload) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try encoder.encode(payload)
        let digest = SHA256.hash(data: data)
        let hexDigest = digest.map { String(format: "%02x", $0) }.joined()

        return "\(version):\(hexDigest)"
    }
}

final actor InMemoryPredictionCache: PredictionCache {
    private var storage = [PredictionCacheKey: PredictionResponse]()

    func response(for key: PredictionCacheKey) async -> PredictionResponse? {
        storage[key]
    }

    func store(_ response: PredictionResponse, for key: PredictionCacheKey) async {
        storage[key] = response
    }
}

private struct PredictionCachePayload: Encodable {
    let provider: String
    let model: String
    let promptInstructions: String?
    let query: String
    let temperature: Double?
    let maxTokens: Int?
    let reasoning: String
    let contextFingerprint: String
}

private extension ReasoningEffort {
    var cacheValue: String {
        switch self {
        case .low:
            return "low"
        case .medium:
            return "medium"
        case .high:
            return "high"
        case .deep:
            return "deep"
        }
    }
}

private extension Context {
    var cacheFingerprint: String {
        "empty"
    }
}
