//
//  NativeAIProvider+Inference.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

extension NativeAIProvider: InferenceProvider {
    public func predict(forRequest request: InferenceRequest) async throws -> InferenceResponse {
        return InferenceResponse()
    }
}
