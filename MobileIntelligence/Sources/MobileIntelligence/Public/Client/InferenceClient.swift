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
//  InferenceClient.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 04/07/26.
//

/// Client capabilities for configuring and running inference.
public protocol InferenceClient: Actor {
    /// Configures inference with a provider and model.
    /// - Parameters:
    ///   - inferenceProvider: The provider used for future predictions.
    ///   - model: The selected model used by the provider.
    func bootstrapInference(_ inferenceProvider: InferenceProvider, model: AIModel) async

    /// Produces a prediction for the request.
    /// - Parameter request: The prediction request to execute.
    /// - Returns: The prediction response.
    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse

    func stream(for request: PredictionRequest) async throws -> AsyncThrowingStream<InferenceStreamEvent, Error>
}
