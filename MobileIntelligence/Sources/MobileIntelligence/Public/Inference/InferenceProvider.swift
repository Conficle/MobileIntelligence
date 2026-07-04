//
//  InferenceProvider.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

public protocol InferenceProvider: Actor {
    func predict(forRequest request: InferenceRequest) async throws -> InferenceResponse
}
