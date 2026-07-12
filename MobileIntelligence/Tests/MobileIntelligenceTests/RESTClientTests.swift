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

@Test func restClientBuildsRequestAndDecodesResponse() async throws {
    let recorder = RequestRecorder()
    let session = MockHTTPSession { request in
        await recorder.record(request)

        let response = HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        return (Data(#"{"message":"pong"}"#.utf8), try #require(response))
    }

    let client: any RESTClient = DefaultRESTClient(
        baseURL: "https://api.example.com/v1",
        defaultHeaders: ["Authorization": "Bearer token", "X-Default": "default"],
        session: session
    )

    let body = TestBody(message: "ping")
    let request = try RESTRequest<TestResponse>(
        path: "/chat/completions",
        method: .post,
        queryItems: [URLQueryItem(name: "stream", value: "false")],
        headers: ["X-Default": "override"],
        jsonBody: body
    )

    let response = try await client.send(request)
    let capturedRequest = try await #require(recorder.firstRequest)

    #expect(response == TestResponse(message: "pong"))
    #expect(capturedRequest.url?.absoluteString == "https://api.example.com/v1/chat/completions?stream=false")
    #expect(capturedRequest.httpMethod == "POST")
    #expect(capturedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer token")
    #expect(capturedRequest.value(forHTTPHeaderField: "X-Default") == "override")
    #expect(capturedRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
    #expect(capturedRequest.value(forHTTPHeaderField: "Accept") == "application/json")
    #expect(capturedRequest.httpBody == Data(#"{"message":"ping"}"#.utf8))
}

@Test func restClientThrowsForUnsuccessfulStatusCode() async throws {
    let session = MockHTTPSession { request in
        let response = HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )

        return (Data(#"{"error":"unauthorized"}"#.utf8), try #require(response))
    }

    let client: any RESTClient = DefaultRESTClient(
        baseURL: "https://api.example.com",
        session: session
    )

    do {
        let request = RESTRequest<TestResponse>(path: "/models")
        _ = try await client.send(request)
        Issue.record("Expected request to throw")
    } catch RESTError.apiError(let statusCode, let message, let data) {
        #expect(statusCode == 401)
        #expect(message == "unauthorized")
        #expect(data == Data(#"{"error":"unauthorized"}"#.utf8))
    } catch {
        Issue.record("Expected RESTError.apiError, received \(error)")
    }
}

@Test func restClientThrowsNestedAPIErrorMessage() async throws {
    let session = MockHTTPSession { request in
        let response = HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )

        return (Data(#"{"error":{"message":"Invalid model requested","type":"invalid_request_error"}}"#.utf8), try #require(response))
    }

    let client: any RESTClient = DefaultRESTClient(
        baseURL: "https://api.example.com",
        session: session
    )

    do {
        let request = RESTRequest<TestResponse>(path: "/responses")
        _ = try await client.send(request)
        Issue.record("Expected request to throw")
    } catch RESTError.apiError(let statusCode, let message, _) {
        #expect(statusCode == 400)
        #expect(message == "Invalid model requested")
    } catch {
        Issue.record("Expected RESTError.apiError, received \(error)")
    }
}

@Test func restClientSupportsEmptyResponses() async throws {
    let session = MockHTTPSession { request in
        let response = HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 204,
            httpVersion: nil,
            headerFields: nil
        )

        return (Data(), try #require(response))
    }

    let client: any RESTClient = DefaultRESTClient(
        baseURL: "https://api.example.com",
        session: session
    )

    let request = RESTRequest<EmptyRESTResponse>(path: "/cache", method: .delete)
    let response = try await client.send(request)

    #expect(response == EmptyRESTResponse())
}

private struct TestBody: Encodable {
    let message: String
}

private struct TestResponse: Decodable, Equatable, Sendable {
    let message: String
}

private actor RequestRecorder {
    private(set) var firstRequest: URLRequest?

    func record(_ request: URLRequest) {
        firstRequest = request
    }
}

private final class MockHTTPSession: HTTPSession, @unchecked Sendable {
    private let handler: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    init(handler: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)) {
        self.handler = handler
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await handler(request)
    }
}
