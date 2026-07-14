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

/// Verifies OpenAI REST configuration values.
@Test func openAIAPIConfigurationOwnsBaseURLAndAuthorizationHeader() {
    let configuration = OpenAIAPIConfiguration.restClientConfiguration(apiKey: "test-key")

    #expect(configuration.baseURL == "https://api.openai.com/v1")
    #expect(configuration.defaultHeaders["Authorization"] == "Bearer test-key")
    #expect(OpenAIAPIConfiguration.responsesPath == "/responses")
}

/// Verifies that the OpenAI provider sends a Responses API request and returns text.
@Test func openAIProviderSendsResponsesRequestAndReturnsText() async throws {
    let recorder = RESTRequestRecorder()
    let client = MockRESTClient { request in
        await recorder.record(request)

        let data = Data("""
        {
          "output": [
            {
              "type": "message",
              "content": [
                {
                  "type": "output_text",
                  "text": "Aye, semicolons be mostly optional."
                }
              ]
            }
          ]
        }
        """.utf8)

        return try JSONDecoder().decode(OpenAIResponsesResponse.self, from: data)
    }

    let provider = OpenAIProvider(
        configuration: OpenAIProvider.Configuration(apiKey: "test-key"),
        restClient: client
    )
    await provider.bootstrap(withModel: OpenAIModelType.gpt5_6)

    let response = try await provider.predict(
        forRequest: PredictionRequest(
            prompt: Prompt(instructions: "Talk like a pirate."),
            context: Context(),
            query: Query(question: "Are semicolons optional in JavaScript?"),
            temperature: 1.0,
            maxTokens: nil,
            reasoning: .low
        )
    )
    let capturedRequest = try await #require(recorder.firstRequest)
    let body = try #require(capturedRequest.body)
    let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
    let reasoning = try #require(json["reasoning"] as? [String: Any])
    let input = try #require(json["input"] as? [[String: Any]])

    #expect(response.content == "Aye, semicolons be mostly optional.")
    #expect(capturedRequest.path == "/responses")
    #expect(capturedRequest.method == .post)
    #expect(json["model"] as? String == "gpt-5.6")
    #expect(reasoning["effort"] as? String == "low")
    #expect(input.count == 2)
    #expect(input[0]["role"] as? String == "developer")
    #expect(input[0]["content"] as? String == "Talk like a pirate.")
    #expect(input[1]["role"] as? String == "user")
    #expect(input[1]["content"] as? String == "Are semicolons optional in JavaScript?")
}

/// Verifies that empty OpenAI text output fails prediction.
@Test func openAIProviderThrowsWhenResponseHasNoTextOutput() async throws {
    let client = MockRESTClient { (_: RESTRequest<OpenAIResponsesResponse>) in
        let data = Data(#"{"output":[]}"#.utf8)
        return try JSONDecoder().decode(OpenAIResponsesResponse.self, from: data)
    }

    let provider = OpenAIProvider(
        configuration: OpenAIProvider.Configuration(apiKey: "test-key"),
        restClient: client
    )

    await #expect(throws: CoreError.self) {
        _ = try await provider.predict(
            forRequest: PredictionRequest(
                prompt: Prompt(instructions: ""),
                context: Context(),
                query: Query(question: "Hello"),
                temperature: 1.0,
                maxTokens: nil,
                reasoning: .low
            )
        )
    }
}

/// Verifies that optional OpenAI prompt and temperature fields are omitted.
@Test func openAIProviderOmitsOptionalPromptAndTemperature() async throws {
    let recorder = RESTRequestRecorder()
    let client = MockRESTClient { request in
        await recorder.record(request)

        let data = Data("""
        {
          "output": [
            {
              "type": "message",
              "content": [
                {
                  "type": "output_text",
                  "text": "Hello"
                }
              ]
            }
          ]
        }
        """.utf8)

        return try JSONDecoder().decode(OpenAIResponsesResponse.self, from: data)
    }

    let provider = OpenAIProvider(
        configuration: OpenAIProvider.Configuration(apiKey: "test-key"),
        restClient: client
    )

    _ = try await provider.predict(
        forRequest: PredictionRequest(
            context: Context(),
            query: Query(question: "Say hello"),
            maxTokens: nil,
            reasoning: .low
        )
    )

    let capturedRequest = try await #require(recorder.firstRequest)
    let body = try #require(capturedRequest.body)
    let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
    let input = try #require(json["input"] as? [[String: Any]])

    #expect(json["temperature"] == nil)
    #expect(input.count == 1)
    #expect(input[0]["role"] as? String == "user")
    #expect(input[0]["content"] as? String == "Say hello")
}

/// Verifies that deep reasoning maps to the OpenAI xhigh value.
@Test func openAIProviderMapsDeepReasoningEffortToXHigh() async throws {
    let recorder = RESTRequestRecorder()
    let client = MockRESTClient { request in
        await recorder.record(request)

        let data = Data(
            """
            {
              "output": [
                {
                  "type": "message",
                  "content": [
                    {
                      "type": "output_text",
                      "text": "Deep response"
                    }
                  ]
                }
              ]
            }
            """.utf8
        )

        return try JSONDecoder().decode(OpenAIResponsesResponse.self, from: data)
    }

    let provider = OpenAIProvider(
        configuration: OpenAIProvider.Configuration(apiKey: "test-key"),
        restClient: client
    )

    await provider.bootstrap(withModel: OpenAIModelType.gpt5_6)

    _ = try await provider.predict(
        forRequest: PredictionRequest(
            context: Context(),
            query: Query(question: "Deep question"),
            maxTokens: nil,
            reasoning: .deep
        )
    )

    let capturedRequest = try await #require(recorder.firstRequest)
    let body = try #require(capturedRequest.body)
    let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
    let reasoning = try #require(json["reasoning"] as? [String: Any])

    #expect(reasoning["effort"] as? String == "xhigh")
}

/// Records the first OpenAI REST request sent by a provider test.
private actor RESTRequestRecorder {
    private(set) var firstRequest: RESTRequest<OpenAIResponsesResponse>?

    /// Stores a captured OpenAI REST request.
    /// - Parameter request: The OpenAI REST request to record.
    func record(_ request: RESTRequest<OpenAIResponsesResponse>) {
        firstRequest = request
    }
}

/// Mock REST client backed by a typed OpenAI request handler.
private final class MockRESTClient: RESTClient, @unchecked Sendable {
    private let handler: @Sendable (RESTRequest<OpenAIResponsesResponse>) async throws -> OpenAIResponsesResponse

    /// Creates a mock REST client with a request handler.
    /// - Parameter handler: The handler used to produce OpenAI responses.
    init(handler: @escaping @Sendable (RESTRequest<OpenAIResponsesResponse>) async throws -> OpenAIResponsesResponse) {
        self.handler = handler
    }

    /// Sends a request through the supplied OpenAI handler.
    /// - Parameter request: The REST request to send.
    /// - Returns: The decoded response returned by the handler.
    func send<Response: Decodable & Sendable>(_ request: RESTRequest<Response>) async throws -> Response {
        guard let openAIRequest = request as? RESTRequest<OpenAIResponsesResponse> else {
            throw CoreError.predictionFailed
        }

        guard let response = try await handler(openAIRequest) as? Response else {
            throw CoreError.predictionFailed
        }

        return response
    }

    func stream<Response: Decodable & Sendable>(_ request: RESTRequest<Response>) async throws -> URLSession.AsyncBytes {
        throw CoreError.predictionFailed
    }
}
