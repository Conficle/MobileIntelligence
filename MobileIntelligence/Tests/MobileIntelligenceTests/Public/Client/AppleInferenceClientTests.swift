//  MobileIntelligence
//
//  Copyright (c) 2026 Nitin Bhagwan Manghwani
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

import FoundationModels
import Testing
@testable import MobileIntelligence

@available(iOS 26.0, *)
private actor TestInferenceEngine: InferenceEngine {
    let response = PredictionResponse(content: "apple client ok")

    func bootstrapInferenceProvider(withModel model: AIModel) async {}

    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        return response
    }
}

@available(iOS 26.0, *)
private actor StubAppleInferenceEngine: AppleInferenceEngine {
    func bootstrapInferenceProvider(withModel model: AIModel) async {}

    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        return PredictionResponse(content: "apple client ok")
    }

    func predict<T: Generable & Sendable>(forRequest request: PredictionRequest, generating: T.Type) async throws -> T {
        if T.self == String.self {
            return "apple generable" as! T
        }
        throw CoreError.predictionFailed
    }
}

@available(iOS 26.0, *)
@Test func defaultAIClientPredictsThroughConfiguredInferenceEngineWithActorStub() async throws {
    let engine = TestInferenceEngine()
    let client = DefaultAIClient(clientFactory: StubClientFactory(engine: engine))
    await client.bootstrapInference(MockProvider(), model: TestModel(name: "demo"))

    let response = try await client.predict(forRequest: PredictionRequest(context: Context(), query: Query(question: "Hey"), maxTokens: nil, reasoning: .low))

    #expect(response.content == "apple client ok")
}

@available(iOS 26.0, *)
@Test func defaultAIClientPredictsUsingAppleInferenceClient() async throws {
    let client = DefaultAIClient(clientFactory: StubClientFactory(engine: StubAppleInferenceEngine()))
    await client.bootstrapInference(MockProvider(), model: NativeModelType.system)
    let response: String = try await client.predict(forRequest: PredictionRequest(context: Context(),
                                                                                  query: Query(question: "Hello"),
                                                                                  maxTokens: nil, reasoning: .low),
                                                    generating: String.self)

    #expect(response == "apple generable")
}

private struct TestModel: AIModel {
    let name: String
}

@available(iOS 26.0, *)
private actor MockProvider: InferenceProvider {
    var mockResponse: PredictionResponse?
    func bootstrap(withModel model: any AIModel) async {}
    
    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        return mockResponse ?? PredictionResponse()
    }
}

@available(iOS 26.0, *)
private actor StubClientFactory: ClientFactory {
    private let engine: any InferenceEngine

    init(engine: any InferenceEngine) {
        self.engine = engine
    }

    func inferenceEngine(forProvider provider: any InferenceProvider, model: AIModel) -> any InferenceEngine {
        return engine
    }
}
