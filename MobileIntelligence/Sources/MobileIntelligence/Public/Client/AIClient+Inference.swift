//
//  AIClient+Inference.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

extension DefaultAIClient {
    public func enable(withProvider inferenceProvider: any InferenceProvider) async {
        inferenceEnginge = await clientFactory.inferenceEngine(forProvider: inferenceProvider)
    }
    
    public func predict(forRequest request: InferenceRequest) async throws -> InferenceResponse {
        guard let response = try await inferenceEnginge?.predict(forRequest: request) else {
            throw CoreError.predictionFailed
        }
        return response
    }
}
