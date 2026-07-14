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
/// Test inference engine for Apple client prediction tests.
private actor TestInferenceEngine: InferenceEngine {
    let response = PredictionResponse(content: "apple client ok")

    /// Accepts a bootstrap call for test setup.
    /// - Parameter model: The model passed to bootstrap.
    func bootstrapInferenceProvider(withModel model: AIModel) async {}

    /// Returns a fixed prediction response.
    /// - Parameter request: The prediction request passed to the engine.
    /// - Returns: A fixed prediction response.
    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        return response
    }
}

@available(iOS 26.0, *)
/// Stub Apple inference engine that supports typed generation.
private actor StubAppleInferenceEngine: AppleInferenceEngine {
    /// Accepts a bootstrap call for test setup.
    /// - Parameter model: The model passed to bootstrap.
    func bootstrapInferenceProvider(withModel model: AIModel) async {}

    /// Returns a fixed prediction response.
    /// - Parameter request: The prediction request passed to the engine.
    /// - Returns: A fixed prediction response.
    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        return PredictionResponse(content: "apple client ok")
    }

    /// Returns a generated string when requested.
    /// - Parameters:
    ///   - request: The prediction request passed to the engine.
    ///   - generating: The expected generated response type.
    /// - Returns: A generated response of the requested type.
    func predict<T: Generable & Sendable>(forRequest request: PredictionRequest, generating: T.Type) async throws -> T {
        if T.self == String.self {
            return "apple generable" as! T
        }
        throw CoreError.predictionFailed
    }
}

@available(iOS 26.0, *)
/// Verifies that the default client can predict through an actor-backed engine.
@Test func defaultAIClientPredictsThroughConfiguredInferenceEngineWithActorStub() async throws {
    let engine = TestInferenceEngine()
    let client = DefaultAIClient(clientFactory: StubClientFactory(engine: engine))
    await client.bootstrapInference(MockProvider(), model: TestModel(name: "demo"))

    let response = try await client.predict(forRequest: PredictionRequest(context: Context(), query: Query(question: "Hey"), maxTokens: nil, reasoning: .low))

    #expect(response.content == "apple client ok")
}

@available(iOS 26.0, *)
/// Verifies that the default client can use Apple typed generation.
@Test func defaultAIClientPredictsUsingAppleInferenceClient() async throws {
    let client = DefaultAIClient(clientFactory: StubClientFactory(engine: StubAppleInferenceEngine()))
    await client.bootstrapInference(MockProvider(), model: NativeModelType.system)
    let response: String = try await client.predict(forRequest: PredictionRequest(context: Context(),
                                                                                  query: Query(question: "Hello"),
                                                                                  maxTokens: nil, reasoning: .low),
                                                    generating: String.self)

    #expect(response == "apple generable")
}

/// Test model implementation with a configurable name.
private struct TestModel: AIModel {
    let name: String
}

@available(iOS 26.0, *)
/// Mock provider used to bootstrap Apple client tests.
private actor MockProvider: InferenceProvider {
    var mockResponse: PredictionResponse?

    /// Accepts a bootstrap call for test setup.
    /// - Parameter model: The model passed to bootstrap.
    func bootstrap(withModel model: any AIModel) async {}
    
    /// Returns the configured mock response or an empty response.
    /// - Parameter request: The prediction request passed to the provider.
    /// - Returns: The configured mock response or an empty response.
    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        return mockResponse ?? PredictionResponse()
    }
}

@available(iOS 26.0, *)
/// Stub factory that returns a fixed inference engine.
private actor StubClientFactory: ClientFactory {
    private let engine: any InferenceEngine

    /// Creates a factory with a fixed engine.
    /// - Parameter engine: The engine returned by the factory.
    init(engine: any InferenceEngine) {
        self.engine = engine
    }

    /// Returns the fixed engine.
    /// - Parameters:
    ///   - provider: The provider passed to the factory.
    ///   - model: The model passed to the factory.
    /// - Returns: The fixed inference engine.
    func inferenceEngine(forProvider provider: any InferenceProvider, model: AIModel) -> any InferenceEngine {
        return engine
    }
}
