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
//  AIClient+Inference.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

extension DefaultAIClient {
    /// Configures the client with an inference provider and model.
    /// - Parameters:
    ///   - inferenceProvider: The provider used for future predictions.
    ///   - model: The selected model used by the provider.
    public func bootstrapInference(_ inferenceProvider: any InferenceProvider, model: AIModel) async {
        inferenceEnginge = await clientFactory.inferenceEngine(forProvider: inferenceProvider, model: model)
        await inferenceEnginge?.bootstrapInferenceProvider(withModel: model)
    }
    
    /// Produces a prediction through the configured inference engine.
    /// - Parameter request: The prediction request to execute.
    /// - Returns: The prediction response.
    public func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        guard let response = try await inferenceEnginge?.predict(forRequest: request) else {
            throw CoreError.predictionFailed
        }
        return response
    }
}
