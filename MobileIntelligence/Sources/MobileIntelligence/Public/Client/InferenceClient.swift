//
//  InferenceClient.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 04/07/26.
//

public protocol InferenceClient: Actor {
    func enable(withProvider inferenceProvider: InferenceProvider) async
    func predict(forRequest request: InferenceRequest) async throws -> InferenceResponse
}
