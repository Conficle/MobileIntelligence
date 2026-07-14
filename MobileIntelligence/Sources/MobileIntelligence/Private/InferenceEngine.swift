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

protocol InferenceEngine: Actor {
    func bootstrapInferenceProvider(withModel model: AIModel) async
    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse
}

final actor DefaultInferenceEngine: InferenceEngine {
    let provider: InferenceProvider
    let cache: PredictionCache
    private var modelName: String

    init(provider: InferenceProvider,
         model: AIModel? = nil,
         cache: PredictionCache = InMemoryPredictionCache()) {
        self.provider = provider
        self.cache = cache
        self.modelName = model?.name ?? "unconfigured"
    }

    func bootstrapInferenceProvider(withModel model: AIModel) async {
        modelName = model.name
        await provider.bootstrap(withModel: model)
    }

    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        let key = try PredictionCacheKey(
            provider: String(describing: type(of: provider)),
            model: modelName,
            request: request
        )

        if let cachedResponse = await cache.response(for: key) {
            return cachedResponse
        }

        let response = try await provider.predict(forRequest: request)
        await cache.store(response, for: key)
        return response
    }
}
