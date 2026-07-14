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

import Foundation
import Testing
@testable import MobileIntelligence

/// Verifies that missing OpenAI content fields decode to safe defaults.
@Test func openAIResponsesResponseUsesDefaultValuesForMissingContentFields() throws {
    let data = Data(
        """
        {
          "output": [
            {
              "type": "message"
            },
            {
              "type": "message",
              "content": [
                {
                  "type": "output_text"
                }
              ]
            }
          ]
        }
        """.utf8
    )

    let response = try JSONDecoder().decode(OpenAIResponsesResponse.self, from: data)
    #expect(response.outputText == "")
}

/// Verifies that OpenAI request bodies encode developer and user messages.
@Test func openAIResponsesRequestEncodesDeveloperAndUserMessages() throws {
    let request = OpenAIResponsesRequest(
        model: "gpt-5.6",
        reasoning: .init(effort: "high"),
        input: [
            .init(role: .developer, content: "Be concise"),
            .init(role: .user, content: "Hello")
        ],
        temperature: 0.7,
        maxOutputTokens: 128,
        stream: false
    )

    let data = try JSONEncoder().encode(request)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    let input = try #require(json?["input"] as? [[String: Any]])
    let reasoning = try #require(json?["reasoning"] as? [String: Any])

    #expect(json?["model"] as? String == "gpt-5.6")
    #expect(json?["temperature"] as? Double == 0.7)
    #expect(json?["max_output_tokens"] as? Int == 128)
    #expect(reasoning["effort"] as? String == "high")
    #expect(input.count == 2)
    #expect(input[0]["role"] as? String == "developer")
    #expect(input[0]["content"] as? String == "Be concise")
    #expect(input[1]["role"] as? String == "user")
    #expect(input[1]["content"] as? String == "Hello")
}
