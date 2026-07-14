//
//  OpenAIStreamEventMapper.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 14/07/26.
//

import Foundation

struct OpenAIStreamEventMapper {
    static func map(_ event: OpenAIStreamEvent) -> InferenceStreamEvent? {
        switch event {
        case .outputTextDelta(let text):
            return .textDelta(text)
        default:
            return nil
        }
    }
}
