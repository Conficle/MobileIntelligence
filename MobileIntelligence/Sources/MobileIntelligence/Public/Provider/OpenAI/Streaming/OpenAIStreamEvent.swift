//
//  OpenAIStreamEvent.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 14/07/26.
//

enum OpenAIStreamEvent {
    case created
    case inProgress
    case outputTextDelta(String)
    case outputTextDone
    case completed
    case unknown
}
