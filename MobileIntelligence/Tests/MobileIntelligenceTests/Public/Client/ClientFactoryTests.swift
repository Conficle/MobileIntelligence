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

/// Verifies that the default factory creates the default inference engine.
@Test func defaultClientFactoryBuildsInferenceEngine() async {
    let factory = DefaultClientFactory()
    let provider = StubInferenceProvider()
    let engine = await factory.inferenceEngine(forProvider: provider, model: TestModel(name: "demo"))

    #expect(engine is DefaultInferenceEngine)
}

/// Verifies that factories using the same cache avoid repeated provider calls.
@Test func defaultClientFactorySharesCacheAcrossEngines() async throws {
    let cache = InMemoryPredictionCache()
    let firstFactory = DefaultClientFactory(cache: cache)
    let secondFactory = DefaultClientFactory(cache: cache)
    let provider = StubInferenceProvider(result: PredictionResponse(content: "factory cached"))
    let request = PredictionRequest(
        prompt: Prompt(instructions: "Cache through factory."),
        context: Context(),
        query: Query(question: "Use the same cache across engines."),
        maxTokens: 64,
        reasoning: .high
    )

    let firstEngine = await firstFactory.inferenceEngine(
        forProvider: provider,
        model: TestModel(name: "factory-cache-demo")
    )
    let secondEngine = await secondFactory.inferenceEngine(
        forProvider: provider,
        model: TestModel(name: "factory-cache-demo")
    )

    let firstResponse = try await firstEngine.predict(forRequest: request)
    let secondResponse = try await secondEngine.predict(forRequest: request)

    #expect(firstResponse.content == "factory cached")
    #expect(secondResponse.content == "factory cached")
    #expect(await provider.predictionRequests.count == 1)
}

/// Verifies that the inference engine bootstraps and predicts through its provider.
@Test func defaultInferenceEngineBootstrapsAndPredictsThroughProvider() async throws {
    let provider = StubInferenceProvider(result: PredictionResponse(content: "engine ok"))
    let engine = DefaultInferenceEngine(provider: provider)

    await engine.bootstrapInferenceProvider(withModel: TestModel(name: "demo"))
    let response = try await engine.predict(forRequest: makeTestRequest())

    #expect(await provider.bootstrappedModel?.name == "demo")
    #expect(response.content == "engine ok")
    #expect(await provider.predictionRequests.count == 1)
}

/// Verifies that repeated identical requests use the cached response.
@Test func defaultInferenceEngineReturnsCachedResponseForSameRequest() async throws {
    let provider = StubInferenceProvider(result: PredictionResponse(content: "fresh"))
    let cache = InMemoryPredictionCache()
    let engine = DefaultInferenceEngine(
        provider: provider,
        model: TestModel(name: "demo"),
        cache: cache
    )

    let firstResponse = try await engine.predict(forRequest: makeTestRequest())
    let secondResponse = try await engine.predict(forRequest: makeTestRequest())

    #expect(firstResponse.content == "fresh")
    #expect(secondResponse.content == "fresh")
    #expect(await provider.predictionRequests.count == 1)
}

/// Verifies that model changes produce different cache keys.
@Test func defaultInferenceEngineUsesDifferentCacheKeysForDifferentModels() async throws {
    let request = makeTestRequest()
    let provider = StubInferenceProvider(result: PredictionResponse(content: "fresh"))
    let cache = InMemoryPredictionCache()
    let firstEngine = DefaultInferenceEngine(
        provider: provider,
        model: TestModel(name: "demo"),
        cache: cache
    )
    let secondEngine = DefaultInferenceEngine(
        provider: provider,
        model: TestModel(name: "demo-mini"),
        cache: cache
    )

    _ = try await firstEngine.predict(forRequest: request)
    _ = try await secondEngine.predict(forRequest: request)

    #expect(await provider.predictionRequests.count == 2)
}

/// Verifies that request changes produce different cache keys.
@Test func defaultInferenceEngineUsesDifferentCacheKeysForDifferentRequests() async throws {
    let provider = StubInferenceProvider(result: PredictionResponse(content: "fresh"))
    let cache = InMemoryPredictionCache()
    let engine = DefaultInferenceEngine(
        provider: provider,
        model: TestModel(name: "demo"),
        cache: cache
    )

    _ = try await engine.predict(forRequest: makeTestRequest())
    _ = try await engine.predict(
        forRequest: PredictionRequest(
            prompt: Prompt(instructions: "Be helpful."),
            context: Context(),
            query: Query(question: "Hello!"),
            maxTokens: 32,
            reasoning: .medium
        )
    )

    #expect(await provider.predictionRequests.count == 2)
}

/// Verifies that provider failures are not cached.
@Test func defaultInferenceEngineDoesNotCacheProviderFailures() async throws {
    let provider = StubInferenceProvider(error: CoreError.predictionFailed)
    let engine = DefaultInferenceEngine(
        provider: provider,
        model: TestModel(name: "demo"),
        cache: InMemoryPredictionCache()
    )

    await #expect(throws: CoreError.self) {
        _ = try await engine.predict(forRequest: makeTestRequest())
    }

    await #expect(throws: CoreError.self) {
        _ = try await engine.predict(forRequest: makeTestRequest())
    }

    #expect(await provider.predictionRequests.count == 2)
}

/// Verifies that the client predicts through its configured engine.
@Test func defaultAIClientPredictsThroughConfiguredInferenceEngine() async throws {
    let engine = StubInferenceEngine(response: PredictionResponse(content: "client ok"))
    let factory = StubClientFactory(engine: engine)
    let client = DefaultAIClient(clientFactory: factory)
    let provider = StubInferenceProvider()

    await client.bootstrapInference(provider, model: TestModel(name: "demo"))
    let response = try await client.predict(forRequest: makeTestRequest())

    #expect(response.content == "client ok")
    #expect(await engine.bootstrappedModel?.name == "demo")
    #expect(await engine.receivedRequest != nil)
}

/// Verifies that predictions fail when no inference engine is configured.
@Test func defaultAIClientThrowsWhenInferenceEngineIsNotConfigured() async throws {
    let client = DefaultAIClient(clientFactory: StubClientFactory(engine: nil))

    do {
        _ = try await client.predict(forRequest: makeTestRequest())
        Issue.record("Expected prediction to fail when no engine is configured")
    } catch CoreError.predictionFailed {
        // Expected
    } catch {
        Issue.record("Expected CoreError.predictionFailed, received \(error)")
    }
}

/// Creates a reusable prediction request for client tests.
/// - Returns: A prediction request shared by client tests.
private func makeTestRequest() -> PredictionRequest {
    PredictionRequest(
        prompt: Prompt(instructions: "Be helpful."),
        context: Context(),
        query: Query(question: "Hello"),
        maxTokens: 32,
        reasoning: .medium
    )
}

/// Test model implementation with a configurable name.
private struct TestModel: AIModel {
    let name: String
}

/// Stub inference provider that records requests and returns configurable results.
private actor StubInferenceProvider: InferenceProvider {
    private(set) var bootstrappedModel: (any AIModel)?
    private(set) var predictionRequests: [PredictionRequest] = []
    private let result: PredictionResponse?
    private let error: Error?

    /// Creates a provider stub with an optional result or error.
    /// - Parameters:
    ///   - result: Optional response returned by predictions.
    ///   - error: Optional error thrown by predictions.
    init(result: PredictionResponse? = nil, error: Error? = nil) {
        self.result = result
        self.error = error
    }

    /// Records the bootstrapped model.
    /// - Parameter model: The model passed to bootstrap.
    func bootstrap(withModel model: any AIModel) async {
        bootstrappedModel = model
    }

    /// Records the request and returns the configured result.
    /// - Parameter request: The prediction request to record.
    /// - Returns: The configured response or a default provider response.
    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        predictionRequests.append(request)
        if let error {
            throw error
        }
        return result ?? PredictionResponse(content: "provider ok")
    }
}

/// Stub inference engine that records bootstrap and prediction calls.
private actor StubInferenceEngine: InferenceEngine {
    private let response: PredictionResponse
    private(set) var bootstrappedModel: (any AIModel)?
    private(set) var receivedRequest: PredictionRequest?

    /// Creates an engine stub with a fixed response.
    /// - Parameter response: The response returned by prediction calls.
    init(response: PredictionResponse) {
        self.response = response
    }

    /// Records the bootstrapped model.
    /// - Parameter model: The model passed to bootstrap.
    func bootstrapInferenceProvider(withModel model: AIModel) async {
        bootstrappedModel = model
    }

    /// Records the request and returns the fixed response.
    /// - Parameter request: The prediction request to record.
    /// - Returns: The fixed prediction response.
    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        receivedRequest = request
        return response
    }
}

/// Stub client factory that returns a supplied engine when available.
private actor StubClientFactory: ClientFactory {
    private let engine: InferenceEngine?

    /// Creates a factory stub with an optional engine.
    /// - Parameter engine: Optional engine returned by the factory.
    init(engine: InferenceEngine?) {
        self.engine = engine
    }

    /// Returns the configured engine or a default engine.
    /// - Parameters:
    ///   - provider: The provider passed to the factory.
    ///   - model: The model passed to the factory.
    /// - Returns: The configured engine or a default engine.
    func inferenceEngine(forProvider provider: InferenceProvider, model: AIModel) -> InferenceEngine {
        engine ?? DefaultInferenceEngine(provider: provider)
    }
}

/// Verifies that a new client starts without a configured inference engine.
@Test func defaultAIClientInitializesWithoutInferenceEngine() async {
    let client = DefaultAIClient()

    do {
        _ = try await client.predict(forRequest: makeTestRequest())
        Issue.record("Expected prediction to fail when no inference engine is configured")
    } catch CoreError.predictionFailed {
        // Expected
    } catch {
        Issue.record("Expected CoreError.predictionFailed, received \(error)")
    }
}

/// Verifies that client bootstrapping configures and uses the inference engine.
@Test func defaultAIClientBootstrapsAndPredictsViaInferenceEngine() async throws {
    let engine = StubInferenceEngine(response: PredictionResponse(content: "client ok"))
    let factory = StubClientFactory(engine: engine)
    let client = DefaultAIClient(clientFactory: factory)
    let provider = StubInferenceProvider()

    await client.bootstrapInference(provider, model: TestModel(name: "demo"))
    let response = try await client.predict(forRequest: makeTestRequest())

    #expect(response.content == "client ok")
    #expect(await engine.bootstrappedModel?.name == "demo")
    #expect(await engine.receivedRequest != nil)
}
