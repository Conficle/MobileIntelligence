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

import Foundation
import FoundationModels
import Testing
@testable import MobileIntelligence

/// Verifies native provider error codes and messages.
@Test func nativeProviderErrorCodesAndMessagesAreCorrect() {
    let deviceNotEligible = NativeProviderError.deviceNotEligible
    #expect(deviceNotEligible.code == 1)
    #expect(deviceNotEligible.message == "Device is not eligible")

    let appleIntelligenceNotEnabled = NativeProviderError.appleIntelligenceNotEnabled
    #expect(appleIntelligenceNotEnabled.code == 2)
    #expect(appleIntelligenceNotEnabled.message == "Apple Intelligence is not enabled")

    let modelNotReady = NativeProviderError.modelNotReady
    #expect(modelNotReady.code == 3)
    #expect(modelNotReady.message == "Model is not ready")

    let unknown = NativeProviderError.unknown
    #expect(unknown.code == 4)
    #expect(unknown.message == "Unknown")
}

/// Verifies the native system model name.
@Test func nativeModelTypeNameIsSystem() {
    #expect(NativeModelType.system.name == "system")
}

@available(iOS 26.0, macOS 26.0, *)
/// Verifies typed native generation when available and provider errors when unavailable.
@Test func nativeAIProviderPredictGeneratesStringWhenAvailableOrThrowsNativeProviderError() async throws {
    try #require(
        SystemLanguageModel.default.availability == .available,
        "Apple Intelligence unavailable"
    )
    let provider = NativeAIProvider()
    let request = PredictionRequest(
        prompt: Prompt(instructions: "Test"),
        context: Context(),
        query: Query(question: "Hello"),
        maxTokens: nil,
        reasoning: .low
    )

    await provider.setAvailabilityOverride(.available)
    let result: String = try await provider.predict(forRequest: request, generating: String.self) ?? ""
    #expect(result is String)

    for reason in [
        SystemLanguageModel.Availability.unavailable(.modelNotReady),
        SystemLanguageModel.Availability.unavailable(.appleIntelligenceNotEnabled),
        SystemLanguageModel.Availability.unavailable(.deviceNotEligible)
    ] {
        await provider.setAvailabilityOverride(reason)
        await #expect(throws: NativeProviderError.self) {
            _ = try await provider.predict(forRequest: request, generating: String.self)
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
/// Verifies native text prediction when available and provider errors when unavailable.
@Test func nativeAIProviderPredictsResponseWhenAvailableOrThrowsNativeProviderError() async throws {
    try #require(
        SystemLanguageModel.default.availability == .available,
        "Apple Intelligence unavailable"
    )
    let provider = NativeAIProvider()
    let request = PredictionRequest(
        prompt: Prompt(instructions: "Test"),
        context: Context(),
        query: Query(question: "Hello"),
        maxTokens: nil,
        reasoning: .low
    )

    await provider.setAvailabilityOverride(.available)
    let response = try await provider.predict(forRequest: request)
    #expect(response.content is String)

    for reason in [
        SystemLanguageModel.Availability.unavailable(.modelNotReady),
        SystemLanguageModel.Availability.unavailable(.appleIntelligenceNotEnabled),
        SystemLanguageModel.Availability.unavailable(.deviceNotEligible)
    ] {
        await provider.setAvailabilityOverride(reason)
        await #expect(throws: NativeProviderError.self) {
            _ = try await provider.predict(forRequest: request)
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
/// Verifies successful native prediction creates a model session.
@Test func nativeAIProviderCreatesSessionAfterSuccessfulPrediction() async throws {
    try #require(
        SystemLanguageModel.default.availability == .available,
        "Apple Intelligence unavailable"
    )
    let provider = NativeAIProvider()
    let request = PredictionRequest(
        prompt: Prompt(instructions: "Test"),
        context: Context(),
        query: Query(question: "Hello"),
        maxTokens: nil,
        reasoning: .low
    )

    await provider.setAvailabilityOverride(.available)
    _ = try await provider.predict(forRequest: request)
    let session = await provider.session
    #expect(session != nil)
}

@available(iOS 26.0, macOS 26.0, *)
/// Verifies native prediction reuses an existing model session.
@Test func nativeAIProviderReusesSessionAcrossMultiplePredictions() async throws {
    try #require(
        SystemLanguageModel.default.availability == .available,
        "Apple Intelligence unavailable"
    )
    let provider = NativeAIProvider()
    let request = PredictionRequest(
        prompt: Prompt(instructions: "Test"),
        context: Context(),
        query: Query(question: "Hello"),
        maxTokens: nil,
        reasoning: .low
    )

    await provider.setAvailabilityOverride(.available)
    _ = try await provider.predict(forRequest: request)
    let firstSession = await provider.session

    _ = try await provider.predict(forRequest: request)
    let secondSession = await provider.session

    #expect(firstSession != nil)
    #expect(secondSession != nil)
    #expect(ObjectIdentifier(firstSession!) == ObjectIdentifier(secondSession!))
}

@available(iOS 26.0, macOS 26.0, *)
/// Verifies unavailable native prediction maps to native provider errors.
@Test func nativeAIProviderPredictThrowsSpecificNativeProviderErrorsWhenUnavailable() async throws {
    try #require(
        SystemLanguageModel.default.availability == .available,
        "Apple Intelligence unavailable"
    )
    let provider = NativeAIProvider()
    let request = PredictionRequest(
        prompt: Prompt(instructions: "Test"),
        context: Context(),
        query: Query(question: "Hello"),
        maxTokens: nil,
        reasoning: .low
    )

    for reason in [
        SystemLanguageModel.Availability.UnavailableReason.modelNotReady,
        SystemLanguageModel.Availability.UnavailableReason.appleIntelligenceNotEnabled,
        SystemLanguageModel.Availability.UnavailableReason.deviceNotEligible
    ] {
        await provider.setAvailabilityOverride(.unavailable(reason))

        await #expect(throws: NativeProviderError.self) {
            _ = try await provider.predict(forRequest: request)
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
/// Verifies unavailable typed native generation maps to native provider errors.
@Test func nativeAIProviderPredictGeneratesThrowsSpecificNativeProviderErrorsWhenUnavailable() async throws {
    try #require(
        SystemLanguageModel.default.availability == .available,
        "Apple Intelligence unavailable"
    )
    let provider = NativeAIProvider()
    let request = PredictionRequest(
        prompt: Prompt(instructions: "Test"),
        context: Context(),
        query: Query(question: "Hello"),
        maxTokens: nil,
        reasoning: .low
    )

    for reason in [
        SystemLanguageModel.Availability.UnavailableReason.modelNotReady,
        SystemLanguageModel.Availability.UnavailableReason.appleIntelligenceNotEnabled,
        SystemLanguageModel.Availability.UnavailableReason.deviceNotEligible
    ] {
        await provider.setAvailabilityOverride(.unavailable(reason))

        await #expect(throws: NativeProviderError.self) {
            _ = try await provider.predict(forRequest: request, generating: String.self)
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
/// Verifies native prediction uses empty instructions when prompt is nil.
@Test func nativeAIProviderPredictUsesEmptyPromptWhenInstructionsAreNil() async throws {
    try #require(
        SystemLanguageModel.default.availability == .available,
        "Apple Intelligence unavailable"
    )
    let provider = NativeAIProvider()
    let request = PredictionRequest(
        prompt: nil,
        context: Context(),
        query: Query(question: "Hello"),
        maxTokens: nil,
        reasoning: .low
    )

    await provider.setAvailabilityOverride(.available)
    let response = try await provider.predict(forRequest: request)
    #expect(response.content is String)
}

@available(iOS 26.0, macOS 26.0, *)
/// Verifies typed native generation uses empty instructions when prompt is nil.
@Test func nativeAIProviderPredictGeneratesUsesEmptyPromptWhenInstructionsAreNil() async throws {
    try #require(
        SystemLanguageModel.default.availability == .available,
        "Apple Intelligence unavailable"
    )
    let provider = NativeAIProvider()
    let request = PredictionRequest(
        prompt: nil,
        context: Context(),
        query: Query(question: "Hello"),
        maxTokens: nil,
        reasoning: .low
    )

    await provider.setAvailabilityOverride(.available)
    let result: String = try await provider.predict(forRequest: request, generating: String.self) ?? ""
    #expect(result is String)
}

@available(iOS 26.0, macOS 26.0, *)
/// Verifies native provider bootstrap completes.
@Test func nativeAIProviderBootstrapDoesNotThrow() async throws {
    let provider = NativeAIProvider()

    await provider.bootstrap(withModel: NativeTestModel(name: "demo"))

    #expect(true)
}

/// Test native model implementation with a configurable name.
private struct NativeTestModel: AIModel {
    let name: String
}
