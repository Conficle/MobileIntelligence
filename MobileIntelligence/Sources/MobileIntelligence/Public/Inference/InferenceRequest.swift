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

public enum Reasoning: Sendable {
    case low
    case medium
    case high
    case deep
}

public struct InferenceRequest: Sendable {
    let prompt: Prompt
    let context: Context
    let query: Query
    let temperature: Double
    let maxTokens: Int?
    let reasoning: Reasoning?

    public init(prompt: Prompt,
                context: Context,
                query: Query,
                temperature: Double,
                maxTokens: Int?,
                reasoning: Reasoning?) {
        self.prompt = prompt
        self.context = context
        self.query = query
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.reasoning = reasoning
    }
}
