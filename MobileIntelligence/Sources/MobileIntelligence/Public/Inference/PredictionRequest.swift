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

//  PredictionRequest.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 27/06/26.
//

/// Describes the reasoning depth requested from a model.
public enum ReasoningEffort: Sendable {
    case low
    case medium
    case high
    case deep
}

/// Input payload for an inference prediction.
public struct PredictionRequest: Sendable {
    let prompt: Prompt?
    let context: Context
    let query: Query
    let temperature: Double?
    let maxTokens: Int?
    let reasoning: ReasoningEffort

    /// Creates a prediction request.
    /// - Parameters:
    ///   - prompt: Optional system instructions for the request.
    ///   - context: Context attached to the request.
    ///   - query: User query to answer.
    ///   - temperature: Optional sampling temperature.
    ///   - maxTokens: Optional maximum output token count.
    ///   - reasoning: Requested reasoning effort.
    public init(prompt: Prompt? = nil,
                context: Context,
                query: Query,
                temperature: Double? = nil,
                maxTokens: Int?,
                reasoning: ReasoningEffort) {
        self.prompt = prompt
        self.context = context
        self.query = query
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.reasoning = reasoning
    }
}
