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

@Test func defaultClientFactoryBuildsInferenceEngine() async {
    let factory = DefaultClientFactory()
    let provider = StubInferenceProvider()
    let engine = await factory.inferenceEngine(forProvider: provider, model: TestModel(name: "demo"))

    #expect(engine is DefaultInferenceEngine)
}

@Test func defaultInferenceEngineBootstrapsAndPredictsThroughProvider() async throws {
    let provider = StubInferenceProvider(result: PredictionResponse(content: "engine ok"))
    let engine = DefaultInferenceEngine(provider: provider)

    await engine.bootstrapInferenceProvider(withModel: TestModel(name: "demo"))
    let response = try await engine.predict(forRequest: makeTestRequest())

    #expect(await provider.bootstrappedModel?.name == "demo")
    #expect(response.content == "engine ok")
    #expect(await provider.predictionRequests.count == 1)
}

@Test func defaultAIClientPredictsThroughConfiguredInferenceEngine() async throws {
    let engine = StubInferenceEngine(response: PredictionResponse(content: "client ok"))
    let factory = StubClientFactory(engine: engine)
    let client = DefaultAIClient(clientFactory: factory)
    let provider = StubInferenceProvider()

    await client.bootstrapInference(provider, model: TestModel(name: "demo"))
    let response = try await client.predict(forRequest: makeTestRequest())

    #expect(response.content == "client ok")
    #expect(await engine.receivedRequest != nil)
}

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

private actor StubInferenceProvider: InferenceProvider {
    private(set) var bootstrappedModel: (any AIModel)?
    private(set) var predictionRequests: [PredictionRequest] = []
    private let result: PredictionResponse?

    init(result: PredictionResponse? = nil) {
        self.result = result
    }

    func bootstrap(withModel model: any AIModel) async {
        bootstrappedModel = model
    }

    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        predictionRequests.append(request)
        return result ?? PredictionResponse(content: "provider ok")
    }
}

private actor StubInferenceEngine: InferenceEngine {
    private let response: PredictionResponse
    private(set) var receivedRequest: PredictionRequest?

    init(response: PredictionResponse) {
        self.response = response
    }

    func bootstrapInferenceProvider(withModel model: AIModel) async {
        _ = model
    }

    func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        receivedRequest = request
        return response
    }
}

private actor StubClientFactory: ClientFactory {
    private let engine: InferenceEngine?

    init(engine: InferenceEngine?) {
        self.engine = engine
    }

    func inferenceEngine(forProvider provider: InferenceProvider, model: AIModel) -> InferenceEngine {
        engine ?? DefaultInferenceEngine(provider: provider)
    }
}

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

@Test func defaultAIClientBootstrapsAndPredictsViaInferenceEngine() async throws {
    let engine = StubInferenceEngine(response: PredictionResponse(content: "client ok"))
    let factory = StubClientFactory(engine: engine)
    let client = DefaultAIClient(clientFactory: factory)
    let provider = StubInferenceProvider()

    await client.bootstrapInference(provider, model: TestModel(name: "demo"))
    let response = try await client.predict(forRequest: makeTestRequest())

    #expect(response.content == "client ok")
    #expect(await engine.receivedRequest != nil)
}
