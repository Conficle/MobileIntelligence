//  MobileIntelligence
//
//  Copyright (c) 2026 Nitin Manghwani
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/// Encodable request body for the OpenAI Responses API.
struct OpenAIResponsesRequest: Encodable, Sendable {
    let model: String
    let reasoning: Reasoning
    let input: [Message]
    let temperature: Double?
    let maxOutputTokens: Int?
    let stream: Bool

    /// Maps Swift property names to OpenAI JSON field names.
    enum CodingKeys: String, CodingKey {
        case model
        case reasoning
        case input
        case temperature
        case maxOutputTokens = "max_output_tokens"
        case stream
    }

    /// Reasoning options sent to the OpenAI Responses API.
    struct Reasoning: Encodable, Sendable {
        let effort: String
    }

    /// Input message sent to the OpenAI Responses API.
    struct Message: Encodable, Sendable {
        let role: Role
        let content: String

        /// Supported input message roles.
        enum Role: String, Encodable, Sendable {
            case developer
            case user
        }
    }
}

/// Decodable response body from the OpenAI Responses API.
struct OpenAIResponsesResponse: Decodable, Sendable {
    let output: [OutputItem]

    /// Extracted text output joined from all output text content blocks.
    /// - Returns: Joined text from message output text blocks.
    var outputText: String {
        output
            .filter { $0.type == "message" }
            .flatMap(\.content)
            .filter { $0.type == "output_text" }
            .map(\.text)
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    /// Top-level output item returned by the OpenAI Responses API.
    struct OutputItem: Decodable, Sendable {
        let type: String
        let content: [Content]

        /// JSON keys used to decode output items.
        enum CodingKeys: CodingKey {
            case type
            case content
        }

        /// Decodes an output item while treating missing content as empty.
        /// - Parameter decoder: The decoder containing an output item payload.
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(String.self, forKey: .type)
            self.content = try container.decodeIfPresent([Content].self, forKey: .content) ?? []
        }
    }

    /// Content block returned within an OpenAI output item.
    struct Content: Decodable, Sendable {
        let type: String
        let text: String

        /// JSON keys used to decode content blocks.
        enum CodingKeys: CodingKey {
            case type
            case text
        }

        /// Decodes a content block while treating missing text as empty.
        /// - Parameter decoder: The decoder containing a content block payload.
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(String.self, forKey: .type)
            self.text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        }
    }
}
