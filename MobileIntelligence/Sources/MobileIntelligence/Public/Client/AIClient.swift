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
//  AIClient.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

/// Public client interface for MobileIntelligence features.
public protocol AIClient: Actor, InferenceClient {
}

/// Default actor-backed implementation of the public AI client.
public final actor DefaultAIClient: AIClient {
    var inferenceEnginge: InferenceEngine?
    let clientFactory: ClientFactory

    /// Creates a client using the default client factory.
    public init() {
        self.clientFactory = DefaultClientFactory()
    }

    /// Creates a client with a custom factory for tests or alternate wiring.
    /// - Parameter clientFactory: The factory used to create internal collaborators.
    init(clientFactory: ClientFactory) {
        self.clientFactory = clientFactory
    }
}
