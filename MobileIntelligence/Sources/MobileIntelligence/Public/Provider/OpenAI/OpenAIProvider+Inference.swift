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

//
//  OpenAIProvider+Inference.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

extension OpenAIProvider: InferenceProvider {
    /// Stores the selected model for future OpenAI requests.
    /// - Parameter model: The model to use for future OpenAI requests.
    public func bootstrap(withModel model: any AIModel) async {
        self.model = model
    }

    /// Sends the prediction request to the OpenAI Responses API.
    /// - Parameter request: The prediction request to execute.
    /// - Returns: The prediction response returned by OpenAI.
    public func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        do {
            let response = try await restClient.send(makeResponsesRequest(for: request))
            let content = response.outputText

            guard !content.isEmpty else {
                throw CoreError.predictionFailed
            }
            return PredictionResponse(content: content)
        }
        catch {
            throw error
        }
    }

    public func stream(for request: PredictionRequest) async throws -> AsyncThrowingStream<InferenceStreamEvent, any Error> {
        let apiRequest = try makeResponsesRequest(for: request, stream: true)
        let bytes = try await restClient.stream(apiRequest)
        return AsyncThrowingStream { continuation in
            Task { [weak self] in
                guard let self else {
                    continuation.finish(throwing: CoreError.invalidSession)
                    return
                }
                do {
                    for try await line in bytes.lines {
                        let event = try self.decoder.decode(from: line)
                        guard let sdkEvent = OpenAIStreamEventMapper.map(event) else {
                            continue
                        }
                        continuation.yield(sdkEvent)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

private extension OpenAIProvider {
    /// Builds an OpenAI Responses API REST request from a prediction request.
    /// - Parameter request: The prediction request to convert.
    /// - Returns: A REST request targeting the OpenAI Responses API.
    func makeResponsesRequest(for request: PredictionRequest, stream: Bool = false) throws -> RESTRequest<OpenAIResponsesResponse> {
        var input = [OpenAIResponsesRequest.Message]()

        if let instructions = request.prompt?.instructions, !instructions.isEmpty {
            input.append(
                OpenAIResponsesRequest.Message(
                    role: .developer,
                    content: instructions
                )
            )
        }

        input.append(
            OpenAIResponsesRequest.Message(
                role: .user,
                content: request.query.question
            )
        )

        let body = OpenAIResponsesRequest(
            model: model.name,
            reasoning: OpenAIResponsesRequest.Reasoning(effort: request.reasoning.openAIValue),
            input: input,
            temperature: request.temperature,
            maxOutputTokens: request.maxTokens,
            stream: stream
        )

        return try RESTRequest(
            path: OpenAIAPIConfiguration.responsesPath,
            method: .post,
            jsonBody: body
        )
    }
}

private extension ReasoningEffort {
    /// OpenAI Responses API value for the reasoning effort.
    /// - Returns: The OpenAI reasoning effort value.
    var openAIValue: String {
        switch self {
        case .low:
            return "low"
        case .medium:
            return "medium"
        case .high:
            return "high"
        case .deep:
            return "xhigh"
        }
    }
}
