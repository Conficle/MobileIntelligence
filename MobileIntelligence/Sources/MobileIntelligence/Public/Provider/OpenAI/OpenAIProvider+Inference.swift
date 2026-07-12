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
//  OpenAIProvider+Inference.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

extension OpenAIProvider: InferenceProvider {
    public func bootstrap(withModel model: any AIModel) async {
        self.model = model
    }

    public func predict(forRequest request: PredictionRequest) async throws -> PredictionResponse {
        let response = try await restClient.send(makeResponsesRequest(for: request))
        let content = response.outputText

        guard !content.isEmpty else {
            throw CoreError.predictionFailed
        }

        return PredictionResponse(content: content)
    }
}

private extension OpenAIProvider {
    func makeResponsesRequest(for request: PredictionRequest) throws -> RESTRequest<OpenAIResponsesResponse> {
        let body = OpenAIResponsesRequest(
            model: model.name,
            reasoning: OpenAIResponsesRequest.Reasoning(effort: request.reasoning.openAIValue),
            input: [
                OpenAIResponsesRequest.Message(
                    role: .developer,
                    content: request.prompt.instructions
                ),
                OpenAIResponsesRequest.Message(
                    role: .user,
                    content: request.query.question
                )
            ],
            temperature: request.temperature,
            maxOutputTokens: request.maxTokens
        )

        return try RESTRequest(
            path: OpenAIAPIConfiguration.responsesPath,
            method: .post,
            jsonBody: body
        )
    }
}

private extension ReasoningEffort {
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
