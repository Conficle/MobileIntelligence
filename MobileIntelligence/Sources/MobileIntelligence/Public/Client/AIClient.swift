//
//  AIClient.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

public protocol AIClient: Actor, InferenceClient {
}

public final actor DefaultAIClient: AIClient {
    var inferenceEnginge: InferenceEngine?
    let clientFactory: ClientFactory

    init(clientFactory: ClientFactory = DefaultClientFactory()) {
        self.clientFactory = clientFactory
    }
}
