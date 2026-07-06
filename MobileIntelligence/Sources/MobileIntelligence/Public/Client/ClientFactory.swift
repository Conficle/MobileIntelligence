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

protocol ClientFactory: Actor {
    func inferenceEngine(forProvider provider: InferenceProvider, model: AIModel) -> InferenceEngine
}

final actor DefaultClientFactory: ClientFactory {
    func inferenceEngine(forProvider provider: InferenceProvider, model: AIModel) -> InferenceEngine {
        return DefaultInferenceEngine(provider: provider)
    }
}
