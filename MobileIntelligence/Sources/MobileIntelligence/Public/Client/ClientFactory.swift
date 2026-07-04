//
//  ClientFactory.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

protocol ClientFactory: Actor {
    func inferenceEngine(forProvider provider: InferenceProvider) -> InferenceEngine
}

final actor DefaultClientFactory: ClientFactory {
    func inferenceEngine(forProvider provider: InferenceProvider) -> InferenceEngine {
        return DefaultInferenceEngine(provider: provider)
    }
}
