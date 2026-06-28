//
//  AIClient.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

public extension MobileIntelligence.Core {
    protocol AIClient: Actor {
        func predict(forRequest request: MobileIntelligence.Inference.Request) async throws -> MobileIntelligence.Inference.Response
    }
}

public extension MobileIntelligence.Core {
    final actor AIClientActor: AIClient {
        private let providerConfiguration: ProviderConfiguration
        private let resolver: Resolver
        private var inferenceEngine: MobileIntelligence.Inference.InferenceEngine?

        init(providerConfiguration: ProviderConfiguration,
             resolver: Resolver = DefaultResolver()) {
            self.providerConfiguration = providerConfiguration
            self.resolver = resolver
            Task { [weak self] in
                await self?.setupInferenceEngine(withProviderConfiguration: providerConfiguration)
            }
        }

        public func predict(forRequest request: MobileIntelligence.Inference.Request) async throws -> MobileIntelligence.Inference.Response {
            guard let response = try await inferenceEngine?.predict(forRequest: request) else {
                throw MobileIntelligence.Core.CoreError.predictionFailed
            }
            return response
        }

        private func setupInferenceEngine(withProviderConfiguration configuration: ProviderConfiguration) async {
            inferenceEngine = await resolver.makeInferenceEngine(withProviderConfiguration: configuration)
        }
    }
}
