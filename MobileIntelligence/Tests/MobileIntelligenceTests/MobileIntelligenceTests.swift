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

@Test func promptInitializesWithDefaultInstructions() {
    let prompt = Prompt()
    #expect(prompt.instructions == "")
}

@Test func promptInitializesWithCustomInstructions() {
    let prompt = Prompt(instructions: "Be concise.")
    #expect(prompt.instructions == "Be concise.")
}

@Test func queryInitializesWithQuestion() {
    let query = Query(question: "What is the best language?")
    #expect(query.question == "What is the best language?")
}

@Test func predictionRequestStoresAllValues() {
    let prompt = Prompt(instructions: "Answer briefly.")
    let context = Context()
    let query = Query(question: "Hello")
    let request = PredictionRequest(
        prompt: prompt,
        context: context,
        query: query,
        temperature: 0.5,
        maxTokens: 42,
        reasoning: .medium
    )

    #expect(request.prompt?.instructions == "Answer briefly.")
    #expect(request.query.question == "Hello")
    #expect(request.temperature == 0.5)
    #expect(request.maxTokens == 42)
    #expect(request.reasoning == .medium)
}

@Test func predictionResponseDefaultContentIsEmpty() {
    let response = PredictionResponse()
    #expect(response.content == "")
}

@Test func predictionResponseStoresProvidedContent() {
    let response = PredictionResponse(content: "Hello world")
    #expect(response.content == "Hello world")
}

@Test func coreErrorCodeAndMessageValuesAreCorrect() {
    let invalidConfiguration = CoreError.invalidProviderConfiguration
    #expect(invalidConfiguration.code == 1001)
    #expect(invalidConfiguration.message == "Invalid provider configuration")

    let predictionFailed = CoreError.predictionFailed
    #expect(predictionFailed.code == 1002)
    #expect(predictionFailed.message == "Prediction failed")
}

@Test func providerTypeCasesAreDistinct() {
    #expect(ProviderType.openAI != ProviderType.anthropic)
    #expect(ProviderType.anthropic != ProviderType.native)
    #expect(ProviderType.openAI != ProviderType.native)
}

@Test func openAIResponsesResponseExtractsOutputText() throws {
    let data = Data(
        """
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
        """.utf8
    )

    let response = try JSONDecoder().decode(OpenAIResponsesResponse.self, from: data)
    #expect(response.outputText == "Hello")
}

@Test func openAIResponsesResponseIgnoresNonMessageOutputAndEmptyText() throws {
    let data = Data(
        """
        {
            "output": [
                {
                    "type": "event",
                    "content": [
                        {
                            "type": "output_text",
                            "text": "Ignored"
                        }
                    ]
                },
                {
                    "type": "message",
                    "content": [
                        {
                            "type": "output_text",
                            "text": "First"
                        },
                        {
                            "type": "output_html",
                            "text": "Ignored HTML"
                        }
                    ]
                },
                {
                    "type": "message",
                    "content": [
                        {
                            "type": "output_text",
                            "text": ""
                        }
                    ]
                }
            ]
        }
        """.utf8
    )

    let response = try JSONDecoder().decode(OpenAIResponsesResponse.self, from: data)
    #expect(response.outputText == "First")
}
