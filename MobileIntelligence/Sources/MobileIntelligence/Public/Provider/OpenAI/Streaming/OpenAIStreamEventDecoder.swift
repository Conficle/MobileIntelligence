//
//  OpenAIStreamEventDecoder.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 14/07/26.
//

import Foundation

struct OpenAIStreamEventDecoder {
    private let decoder = JSONDecoder()

    func decode(from line: String) throws -> OpenAIStreamEvent {
        guard line.hasPrefix("data:") else {
            return .unknown
        }

        let payload = line.dropFirst(5).trimmingCharacters(in: .whitespaces)

        if payload == "[DONE]" {
            return .completed
        }

        let envelope = try decoder.decode(OpenAIStreamEnvelope.self, from: Data(payload.utf8))

        switch envelope.type {
        case "response.created":
            return .created
        case "response.in_progress":
            return .inProgress
        case "response.output_text.delta":
            return .outputTextDelta(envelope.delta ?? "")
        case "response.output_text.done":
            return .outputTextDone
        case "response.completed":
            return .completed
        default:
            return .unknown
        }
    }
}
