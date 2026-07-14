//
//  OpenAIStreamEnvelope.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 14/07/26.
//

struct OpenAIStreamEnvelope: Decodable {
    let type: String
    let delta: String?
}
