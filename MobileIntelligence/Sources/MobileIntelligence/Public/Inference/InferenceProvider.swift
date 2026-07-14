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
//  InferenceProvider.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

/// Provider abstraction for model-backed inference.
public protocol InferenceProvider: Actor {
    /// Prepares the provider with the selected model.
    /// - Parameter model: The model to use for future predictions.
    func bootstrap(withModel model: AIModel) async

    /// Produces a prediction for the request.
    /// - Parameter request: The prediction request to execute.
    /// - Returns: The prediction response.
    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse

    func stream(for request: PredictionRequest) async throws -> AsyncThrowingStream<InferenceStreamEvent, Error>
}
