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

struct OpenAIResponsesRequest: Encodable, Sendable {
    let model: String
    let reasoning: Reasoning
    let input: [Message]
    let temperature: Double
    let maxOutputTokens: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case reasoning
        case input
        case temperature
        case maxOutputTokens = "max_output_tokens"
    }

    struct Reasoning: Encodable, Sendable {
        let effort: String
    }

    struct Message: Encodable, Sendable {
        let role: Role
        let content: String

        enum Role: String, Encodable, Sendable {
            case developer
            case user
        }
    }
}

struct OpenAIResponsesResponse: Decodable, Sendable {
    let output: [OutputItem]

    var outputText: String {
        output
            .filter { $0.type == "message" }
            .flatMap(\.content)
            .filter { $0.type == "output_text" }
            .map(\.text)
            .joined(separator: "\n")
    }

    struct OutputItem: Decodable, Sendable {
        let type: String
        let content: [Content]

        enum CodingKeys: CodingKey {
            case type
            case content
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(String.self, forKey: .type)
            self.content = try container.decodeIfPresent([Content].self, forKey: .content) ?? []
        }
    }

    struct Content: Decodable, Sendable {
        let type: String
        let text: String

        enum CodingKeys: CodingKey {
            case type
            case text
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(String.self, forKey: .type)
            self.text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        }
    }
}
