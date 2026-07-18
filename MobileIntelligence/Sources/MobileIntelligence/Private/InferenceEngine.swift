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
//

//
//  InferenceEngine.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 27/06/26.
//

/// Coordinates model bootstrapping and prediction execution for an inference provider.
protocol InferenceEngine: Actor {
    /// Prepares the underlying provider with the selected model.
    /// - Parameter model: The model to use for future predictions.
    func bootstrapInferenceProvider(withModel model: AIModel) async

    /// Produces a prediction response for the request.
    /// - Parameter request: The prediction request to execute.
    /// - Returns: The prediction response produced by the provider or cache.
    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse

    func stream(for request: PredictionRequest) async throws -> AsyncThrowingStream<InferenceStreamEvent, Error>
}

/// Default inference engine that adds caching before delegating to a provider.
final actor DefaultInferenceEngine: InferenceEngine {
    let provider: InferenceProvider
    let cache: PredictionCache
    private var modelName: String

    /// Creates an inference engine with a provider, optional model, and prediction cache.
    /// - Parameters:
    ///   - provider: The provider used when a request is not cached.
    ///   - model: The selected model used to key cached responses.
    ///   - cache: The prediction cache used before provider calls.
    init(provider: InferenceProvider,
         model: AIModel? = nil,
         cache: PredictionCache = InMemoryPredictionCache()) {
        self.provider = provider
        self.cache = cache
        self.modelName = model?.name ?? "unconfigured"
    }

    /// Stores the selected model and bootstraps the provider.
    /// - Parameter model: The model to use for future predictions.
    func bootstrapInferenceProvider(withModel model: AIModel) async {
        modelName = model.name
        await provider.bootstrap(withModel: model)
    }

    /// Returns a cached prediction when available and allowed, otherwise calls the provider.
    /// - Parameter request: The prediction request to execute.
    /// - Returns: The cached or newly generated prediction response.
    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        let key = try PredictionCacheKey(
            provider: String(describing: type(of: provider)),
            model: modelName,
            request: request
        )

        if request.cachePolicy != .reload, let cachedResponse = await cache.response(for: key) {
            return cachedResponse
        }

        if request.cachePolicy == .cacheOnly {
            throw CoreError.cacheMiss
        }

        let response = try await provider.predict(forRequest: request)
        await cache.store(response, for: key)
        return response
    }

    public func stream(for request: PredictionRequest) async throws -> AsyncThrowingStream<InferenceStreamEvent, Error> {
        let key = try PredictionCacheKey(provider: String(describing: type(of: provider)),
                                         model: self.modelName,
                                         request: request)

        if request.cachePolicy != .reload, let cachedResponse = await cache.response(for: key) {
            return AsyncThrowingStream { continuation in
                continuation.yield(.completed(cachedResponse))
                continuation.finish()
            }
        }

        if request.cachePolicy == .cacheOnly {
            throw CoreError.cacheMiss
        }

        let stream = try await self.provider.stream(for: request)

        return AsyncThrowingStream { continuation in
            Task { @MainActor [weak self] in
                guard let self else {
                    continuation.finish(throwing: CoreError.invalidSession)
                    return
                }

                var builder = PredictionResponseBuilder()
                
                do {
                    for try await event in stream {
                        builder.consume(event)
                        continuation.yield(event)
                    }
                    let response = builder.build()
                    await self.cache.store(response, for: key)
                    continuation.yield(.completed(response))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

final class PredictionResponseBuilder {
    private var content = ""
    
    func consume(_ event: InferenceStreamEvent) {
        switch event {
        case .textDelta(let delta):
            content += delta
        default:
            break
        }
    }

    func build() -> PredictionResponse {
        PredictionResponse(content: content)
    }
}
