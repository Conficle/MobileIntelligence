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

/// Stores and retrieves prediction responses by deterministic cache key.
protocol PredictionCache: Actor {
    /// Returns a cached response for the key when one exists.
    /// - Parameter key: The cache key to look up.
    /// - Returns: The cached prediction response when available.
    func response(for key: PredictionCacheKey) async -> PredictionResponse?

    /// Stores a prediction response for the key.
    /// - Parameters:
    ///   - response: The prediction response to cache.
    ///   - key: The cache key associated with the response.
    func store(_ response: PredictionResponse, for key: PredictionCacheKey) async
}

/// Stable, versioned cache key for prediction requests.
struct PredictionCacheKey: Hashable, Sendable {
    private static let version = "prediction:v1"

    let value: String

    /// Creates a cache key from the provider, model, and request fields that affect output.
    /// - Parameters:
    ///   - provider: The provider identity included in the key.
    ///   - model: The selected model name included in the key.
    ///   - request: The prediction request included in the key.
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

    /// Creates a cache key from a precomputed value.
    /// - Parameter value: The versioned cache key value.
    init(value: String) {
        self.value = value
    }

    /// Encodes and hashes the canonical cache payload.
    /// - Parameter payload: The canonical payload to hash.
    /// - Returns: The versioned SHA-256 cache key.
    private static func hash(_ payload: PredictionCachePayload) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try encoder.encode(payload)
        let digest = SHA256.hash(data: data)
        let hexDigest = digest.map { String(format: "%02x", $0) }.joined()

        return "\(version):\(hexDigest)"
    }
}

/// Actor-backed in-memory prediction cache.
final actor InMemoryPredictionCache: PredictionCache {
    private var storage = [PredictionCacheKey: PredictionResponse]()

    /// Returns the cached response for a key.
    /// - Parameter key: The cache key to look up.
    /// - Returns: The cached prediction response when available.
    func response(for key: PredictionCacheKey) async -> PredictionResponse? {
        storage[key]
    }

    /// Stores the response for later cache lookups.
    /// - Parameters:
    ///   - response: The prediction response to cache.
    ///   - key: The cache key associated with the response.
    func store(_ response: PredictionResponse, for key: PredictionCacheKey) async {
        storage[key] = response
    }
}

/// Canonical payload used to build prediction cache hashes.
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
    /// Stable string representation used in prediction cache keys.
    /// - Returns: The stable string value for the reasoning effort.
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
    /// Stable context fingerprint used in prediction cache keys.
    /// - Returns: The context fingerprint included in cache keys.
    var cacheFingerprint: String {
        "empty"
    }
}
