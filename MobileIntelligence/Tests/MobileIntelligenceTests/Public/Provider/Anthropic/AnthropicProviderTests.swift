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

@Test func anthropicProviderReturnsEmptyPredictionByDefault() async throws {
    let provider = AnthropicAIProvider()

    await provider.bootstrap(withModel: TestModel(name: "demo"))
    let response = try await provider.predict(forRequest: makeTestRequest())

    #expect(response.content == "")
}

@Test func anthropicModelTypeRawValuesAndNamesMatchExpected() async throws {
    #expect(AnthropicModelType.claude3_opus.rawValue == "claude-3-opus")
    #expect(AnthropicModelType.claude3_opus.name == "claude-3-opus")

    #expect(AnthropicModelType.claude4_5_sonnet.rawValue == "claude-4.5-sonnet")
    #expect(AnthropicModelType.claude4_5_sonnet.name == "claude-4.5-sonnet")

    #expect(AnthropicModelType.claude3_5_sonnet.rawValue == "claude-3-5-sonnet")
    #expect(AnthropicModelType.claude3_5_sonnet.name == "claude-3-5-sonnet")
}

@Test func anthropicModelTypeRawValueInitializationReturnsNilForInvalidValue() async throws {
    let modelType = AnthropicModelType(rawValue: "claude-unknown")

    #expect(modelType == nil)
}

private func makeTestRequest() -> PredictionRequest {
    PredictionRequest(
        prompt: Prompt(instructions: "Be helpful."),
        context: Context(),
        query: Query(question: "Hello"),
        maxTokens: 32,
        reasoning: .medium
    )
}

private struct TestModel: AIModel {
    let name: String
}
