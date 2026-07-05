//
//  AppleInferenceClient.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

import FoundationModels

@available(iOS 26.0, *)
public protocol AppleInferenceClient: InferenceClient {
    func predict<T: Generable & Sendable>(forRequest request: PredictionRequest, generating: T.Type) async throws -> T
}
