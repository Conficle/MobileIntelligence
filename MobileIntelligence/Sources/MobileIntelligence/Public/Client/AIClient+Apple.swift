//
//  File.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

import FoundationModels

@available(iOS 26.0, *)
extension DefaultAIClient: AppleInferenceClient {
    public func predict<T: Generable & Sendable>(forRequest request: PredictionRequest, generating: T.Type) async throws -> T {
        guard let response = try await (inferenceEnginge as? AppleInferenceEngine)?.predict(forRequest: request, generating: generating) else {
            throw CoreError.predictionFailed
        }
        return response
    }
}
