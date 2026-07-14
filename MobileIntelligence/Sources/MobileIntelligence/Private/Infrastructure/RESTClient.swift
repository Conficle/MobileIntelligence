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

/// Abstracts URL loading so REST clients can be tested with custom sessions.
protocol HTTPSession: Sendable {
    /// Loads data for the provided URL request.
    /// - Parameter request: The URL request to send.
    /// - Returns: The response data and URL response.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Allows URLSession to satisfy the package's HTTP session abstraction.
extension URLSession: HTTPSession {}

/// Sends typed REST requests and decodes typed responses.
protocol RESTClient: Sendable {
    /// Sends a REST request and decodes the expected response type.
    /// - Parameter request: The typed REST request to send.
    /// - Returns: The decoded response value.
    func send<Response: Decodable & Sendable>(_ request: RESTRequest<Response>) async throws -> Response
}

/// Default REST client backed by an HTTP session and JSON decoder.
actor DefaultRESTClient: RESTClient {
    private let baseURL: String
    private let defaultHeaders: [String: String]
    private let decoder: JSONDecoder
    private let session: any HTTPSession

    /// Creates a REST client from explicit transport configuration values.
    /// - Parameters:
    ///   - baseURL: The base URL used for all requests.
    ///   - defaultHeaders: Headers applied to every request unless overridden.
    ///   - decoder: The decoder used for response bodies.
    ///   - session: The HTTP session used to load requests.
    init(baseURL: String,
         defaultHeaders: [String: String] = [:],
         decoder: JSONDecoder = JSONDecoder(),
         session: any HTTPSession = URLSession.shared) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.decoder = decoder
        self.session = session
    }

    /// Creates a REST client from a reusable configuration value.
    /// - Parameters:
    ///   - configuration: The base URL and default headers for the client.
    ///   - decoder: The decoder used for response bodies.
    ///   - session: The HTTP session used to load requests.
    init(configuration: RESTClientConfiguration,
         decoder: JSONDecoder = JSONDecoder(),
         session: any HTTPSession = URLSession.shared) {
        self.init(
            baseURL: configuration.baseURL,
            defaultHeaders: configuration.defaultHeaders,
            decoder: decoder,
            session: session
        )
    }

    /// Sends the request, validates the HTTP response, and decodes the response body.
    /// - Parameter request: The typed REST request to send.
    /// - Returns: The decoded response value.
    func send<Response: Decodable & Sendable>(_ request: RESTRequest<Response>) async throws -> Response {
        let urlRequest = try makeURLRequest(from: request)
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RESTError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw makeAPIError(statusCode: httpResponse.statusCode, data: data)
        }

        if Response.self == EmptyRESTResponse.self, data.isEmpty {
            guard let response = EmptyRESTResponse() as? Response else {
                throw RESTError.decodingFailed("Unable to create empty response")
            }
            return response
        }

        guard !data.isEmpty else {
            throw RESTError.emptyResponse
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw RESTError.decodingFailed(error.localizedDescription)
        }
    }

    /// Converts a typed REST request into a URLRequest.
    /// - Parameter request: The typed REST request to convert.
    /// - Returns: A URLRequest ready to send.
    private func makeURLRequest<Response>(from request: RESTRequest<Response>) throws -> URLRequest {
        let url = try makeURL(path: request.path, queryItems: request.queryItems)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        if let timeoutInterval = request.timeoutInterval {
            urlRequest.timeoutInterval = timeoutInterval
        }

        let headers = defaultHeaders.merging(request.headers) { _, requestValue in
            requestValue
        }

        for (field, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }

        if request.body != nil, urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if urlRequest.value(forHTTPHeaderField: "Accept") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        return urlRequest
    }

    /// Builds the final URL by combining the base URL, path, and query items.
    /// - Parameters:
    ///   - path: The endpoint path to append to the base URL.
    ///   - queryItems: Query items to include in the URL.
    /// - Returns: The fully constructed URL.
    private func makeURL(path: String, queryItems: [URLQueryItem]) throws -> URL {
        guard let baseURL = URL(string: baseURL) else {
            throw RESTError.invalidURL
        }

        let trimmedPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let url = trimmedPath
            .split(separator: "/")
            .reduce(baseURL) { partialURL, pathComponent in
                partialURL.appendingPathComponent(String(pathComponent))
            }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw RESTError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = (components.queryItems ?? []) + queryItems
        }

        guard let url = components.url else {
            throw RESTError.invalidURL
        }

        return url
    }

    /// Creates a REST error from an unsuccessful HTTP response.
    /// - Parameters:
    ///   - statusCode: The HTTP status code returned by the server.
    ///   - data: The response body returned by the server.
    /// - Returns: A REST error representing the failed response.
    private func makeAPIError(statusCode: Int, data: Data) -> RESTError {
        if let message = decodeAPIErrorMessage(from: data), !message.isEmpty {
            return .apiError(statusCode: statusCode, message: message, data: data)
        }

        guard let body = String(data: data, encoding: .utf8), !body.isEmpty else {
            return .unacceptableStatusCode(statusCode, data)
        }

        return .apiError(statusCode: statusCode, message: body, data: data)
    }

    /// Attempts to decode common API error payload shapes into a message.
    /// - Parameter data: The response body containing a possible API error.
    /// - Returns: A decoded error message when one is available.
    private func decodeAPIErrorMessage(from data: Data) -> String? {
        guard !data.isEmpty else {
            return nil
        }

        if let response = try? decoder.decode(APIErrorResponse.self, from: data) {
            return response.message
        }

        if let response = try? decoder.decode(APIStringErrorResponse.self, from: data) {
            return response.error
        }

        if let response = try? decoder.decode(APIMessageResponse.self, from: data) {
            return response.message
        }

        return nil
    }
}

/// Decodes nested API error payloads shaped as `{ "error": { "message": ... } }`.
private struct APIErrorResponse: Decodable {
    let error: APIError

    /// The nested API error message.
    /// - Returns: The message contained in the nested error object.
    var message: String {
        error.message
    }

    /// Decodes the nested error object from an API error payload.
    struct APIError: Decodable {
        let message: String
    }
}

/// Decodes API error payloads shaped as `{ "error": ... }`.
private struct APIStringErrorResponse: Decodable {
    let error: String
}

/// Decodes API error payloads shaped as `{ "message": ... }`.
private struct APIMessageResponse: Decodable {
    let message: String
}
