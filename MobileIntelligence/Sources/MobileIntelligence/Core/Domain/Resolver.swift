//
//  Resolver.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

extension MobileIntelligence.Core {
    protocol Resolver: Actor {
        func makeInferenceEngine(withProviderConfiguration configuration: ProviderConfiguration) async -> MobileIntelligence.Inference.InferenceEngine
    }
}

extension MobileIntelligence.Core {
    final actor DefaultResolver: Resolver {
        func makeInferenceEngine(withProviderConfiguration configuration: ProviderConfiguration) async -> MobileIntelligence.Inference.InferenceEngine {
            return MobileIntelligence.Inference.InferenceEngineActor(providerConfiguration: configuration)
        }
    }
}
