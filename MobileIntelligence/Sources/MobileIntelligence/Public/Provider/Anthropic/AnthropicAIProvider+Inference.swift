//
//  AnthropicAIProvider+Inference.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

extension AnthropicAIProvider: InferenceProvider {
    public func predict(forRequest request: InferenceRequest) async throws -> InferenceResponse {
        return InferenceResponse()
    }
}
