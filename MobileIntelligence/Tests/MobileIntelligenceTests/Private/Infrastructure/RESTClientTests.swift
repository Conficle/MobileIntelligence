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

/// Verifies that the REST client builds a request and decodes a response.
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

/// Verifies that unsuccessful HTTP status codes produce API errors.
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

/// Verifies that nested API error messages are decoded.
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

/// Verifies that string API error payloads are decoded.
@Test func restClientThrowsForStringAPIErrorResponse() async throws {
    let session = MockHTTPSession { request in
        let response = HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )

        return (Data(#"{"error":"bad auth"}"#.utf8), try #require(response))
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
        #expect(statusCode == 400)
        #expect(message == "bad auth")
        #expect(data == Data(#"{"error":"bad auth"}"#.utf8))
    } catch {
        Issue.record("Expected RESTError.apiError, received \(error)")
    }
}

/// Verifies that message API error payloads are decoded.
@Test func restClientThrowsForMessageAPIErrorResponse() async throws {
    let session = MockHTTPSession { request in
        let response = HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )

        return (Data(#"{"message":"bad request"}"#.utf8), try #require(response))
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
        #expect(statusCode == 400)
        #expect(message == "bad request")
        #expect(data == Data(#"{"message":"bad request"}"#.utf8))
    } catch {
        Issue.record("Expected RESTError.apiError, received \(error)")
    }
}

/// Verifies that empty unsuccessful responses produce unacceptable status errors.
@Test func restClientThrowsForUnacceptableStatusCodeWithEmptyBody() async throws {
    let session = MockHTTPSession { request in
        let response = HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        return (Data(), try #require(response))
    }

    let client: any RESTClient = DefaultRESTClient(
        baseURL: "https://api.example.com",
        session: session
    )

    do {
        let request = RESTRequest<TestResponse>(path: "/models")
        _ = try await client.send(request)
        Issue.record("Expected request to throw")
    } catch RESTError.unacceptableStatusCode(let statusCode, let data) {
        #expect(statusCode == 500)
        #expect(data.isEmpty)
    } catch {
        Issue.record("Expected RESTError.unacceptableStatusCode, received \(error)")
    }
}

/// Verifies that non-HTTP responses are rejected.
@Test func restClientThrowsForInvalidResponseType() async throws {
    let session = MockHTTPSession { request in
        let response = URLResponse(
            url: try #require(request.url),
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )

        return (Data(#"{"message":"pong"}"#.utf8), response)
    }

    let client: any RESTClient = DefaultRESTClient(
        baseURL: "https://api.example.com",
        session: session
    )

    do {
        let request = RESTRequest<TestResponse>(path: "/models")
        _ = try await client.send(request)
        Issue.record("Expected request to throw")
    } catch RESTError.invalidResponse {
        // Expected
    } catch {
        Issue.record("Expected RESTError.invalidResponse, received \(error)")
    }
}

/// Verifies that empty success responses can be decoded explicitly.
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

/// Verifies that empty bodies fail when a non-empty response is expected.
@Test func restClientThrowsForEmptyBodyOnNonEmptyResponse() async throws {
    let session = MockHTTPSession { request in
        let response = HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        return (Data(), try #require(response))
    }

    let client: any RESTClient = DefaultRESTClient(
        baseURL: "https://api.example.com",
        session: session
    )

    do {
        let request = RESTRequest<TestResponse>(path: "/cache")
        _ = try await client.send(request)
        Issue.record("Expected request to throw")
    } catch RESTError.emptyResponse {
        // Expected
    } catch {
        Issue.record("Expected RESTError.emptyResponse, received \(error)")
    }
}

/// Verifies that malformed base URLs fail request construction.
@Test func restClientThrowsInvalidURLForMalformedBaseURL() async throws {
    let session = MockHTTPSession { request in
        let response = HTTPURLResponse(
            url: try #require(request.url),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        return (Data(), try #require(response))
    }

    let client: any RESTClient = DefaultRESTClient(
        baseURL: "ht!tp://bad-url",
        session: session
    )

    do {
        let request = RESTRequest<TestResponse>(path: "/test")
        _ = try await client.send(request)
        Issue.record("Expected request to throw")
    } catch RESTError.invalidURL {
        // Expected
    } catch {
        Issue.record("Expected RESTError.invalidURL, received \(error)")
    }
}

/// Encodable request body used by REST client tests.
private struct TestBody: Encodable {
    let message: String
}

/// Decodable response body used by REST client tests.
private struct TestResponse: Decodable, Equatable, Sendable {
    let message: String
}

/// Records the first URL request received by a mock session.
private actor RequestRecorder {
    private(set) var firstRequest: URLRequest?

    /// Stores a captured URL request.
    /// - Parameter request: The URL request to record.
    func record(_ request: URLRequest) {
        firstRequest = request
    }
}

/// Mock HTTP session backed by a supplied request handler.
private final class MockHTTPSession: HTTPSession, @unchecked Sendable {
    private let handler: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    /// Creates a mock session with a request handler.
    /// - Parameter handler: The handler used to produce data and responses.
    init(handler: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse)) {
        self.handler = handler
    }

    /// Handles a URL request using the supplied handler.
    /// - Parameter request: The URL request to handle.
    /// - Returns: The data and URL response produced by the handler.
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await handler(request)
    }
}
