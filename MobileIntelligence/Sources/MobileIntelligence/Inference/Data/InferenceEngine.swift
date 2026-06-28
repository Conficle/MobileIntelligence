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

extension MobileIntelligence.Inference {
    protocol InferenceEngine: Sendable, Actor {
        func predict(forRequest request: MobileIntelligence.Inference.Request) async throws -> MobileIntelligence.Inference.Response
    }
}

extension MobileIntelligence.Inference {
    final actor InferenceEngineActor: InferenceEngine {
        private let providerConfiguration: MobileIntelligence.Core.ProviderConfiguration
        private let providerFactory: MobileIntelligence.Infrastructure.ProviderFactory
        private var provider: (any MobileIntelligence.Inference.InferenceCapable)?

        init(providerConfiguration: MobileIntelligence.Core.ProviderConfiguration,
             providerFactory: MobileIntelligence.Infrastructure.ProviderFactory = MobileIntelligence.Infrastructure.DefaultProviderFactory()) {
            self.providerConfiguration = providerConfiguration
            self.providerFactory = providerFactory
            Task { [weak self] in
                try await self?.makeInferenceProvider(withConfguration: providerConfiguration)
            }
        }

        func predict(forRequest request: MobileIntelligence.Inference.Request) async throws -> MobileIntelligence.Inference.Response {
            let response = try await provider?.predict(forRequest: request)
            return MobileIntelligence.Inference.Response()
        }

        private func makeInferenceProvider(withConfguration configuration: MobileIntelligence.Core.ProviderConfiguration) async throws {
            self.provider = try await providerFactory.makeInferenceProvider(forproviderConfiguration: providerConfiguration)
        }
    }
}
