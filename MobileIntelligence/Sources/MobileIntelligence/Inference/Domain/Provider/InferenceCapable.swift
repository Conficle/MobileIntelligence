//
//  InferenceCapable.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

extension MobileIntelligence.Inference {
    protocol InferenceCapable: MobileIntelligence.Core.AIProvider {
        func predict(forRequest request: MobileIntelligence.Inference.Request) async throws -> MobileIntelligence.Inference.Response
    }
}
