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
//  ClientFactory.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

/// Builds internal client collaborators.
protocol ClientFactory: Actor {
    /// Creates an inference engine for the provider and selected model.
    /// - Parameters:
    ///   - provider: The provider the engine should use.
    ///   - model: The selected model the engine should use.
    /// - Returns: An inference engine configured for the provider.
    func inferenceEngine(forProvider provider: InferenceProvider, model: AIModel) -> InferenceEngine
}

/// Default factory for client collaborators.
final actor DefaultClientFactory: ClientFactory {
    private static let sharedPredictionCache = InMemoryPredictionCache()
    private let cache: PredictionCache

    /// Creates a factory with a prediction cache shared by created engines.
    /// - Parameter cache: The prediction cache shared by created engines.
    init(cache: PredictionCache = DefaultClientFactory.sharedPredictionCache) {
        self.cache = cache
    }

    /// Creates the default inference engine for the provider and model.
    /// - Parameters:
    ///   - provider: The provider the engine should use.
    ///   - model: The selected model the engine should use.
    /// - Returns: A default inference engine configured for the provider.
    func inferenceEngine(forProvider provider: InferenceProvider, model: AIModel) -> InferenceEngine {
        return DefaultInferenceEngine(provider: provider, model: model, cache: cache)
    }
}
