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

//
//  NativeAIProvider+Inference.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//


import FoundationModels

@available(iOS 26.0, *)
extension NativeAIProvider: AppleInferenceProvider {
    public func bootstrap(withModel model: any AIModel) async {}
    public func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        try checkAvailability()
        makeLanguageModelSession(forInstruction: request.prompt?.instructions ?? "")
        do {
            let response = try await session?.respond(to: request.query.question)
            return PredictionResponse(content: response?.content ?? "")
        } catch {
            throw error
        }
    }

    public func predict<T: Generable>(forRequest request: PredictionRequest, generating: T.Type) async throws -> T {
        try checkAvailability()
        let session = LanguageModelSession(model: .default, instructions: request.prompt?.instructions ?? "")
        let response = try await session.respond(to: request.query.question, generating: generating)
        return response.content
    }
}

@available(iOS 26.0, *)
private extension NativeAIProvider {
    func checkAvailability() throws {
        let availability = self.availability
        switch availability {
        case .unavailable(let reason):
            switch reason {
            case .modelNotReady:
                throw NativeProviderError.modelNotReady
            case .appleIntelligenceNotEnabled:
                throw NativeProviderError.appleIntelligenceNotEnabled
            case .deviceNotEligible:
                throw NativeProviderError.deviceNotEligible
            @unknown default:
                throw NativeProviderError.unknown
            }
        case .available:
            return
        }
    }
    @discardableResult
    func makeLanguageModelSession(forInstruction instruction: String) -> LanguageModelSession {
        if let session {
            return session
        }
        let session = LanguageModelSession(model: .default, instructions: instruction)
        self.session = session
        return session
    }
}
