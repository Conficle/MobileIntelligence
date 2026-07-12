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

protocol HTTPSession: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: HTTPSession {}

protocol RESTClient: Sendable {
    func send<Response: Decodable & Sendable>(_ request: RESTRequest<Response>) async throws -> Response
}

actor DefaultRESTClient: RESTClient {
    private let baseURL: String
    private let defaultHeaders: [String: String]
    private let decoder: JSONDecoder
    private let session: any HTTPSession

    init(baseURL: String,
         defaultHeaders: [String: String] = [:],
         decoder: JSONDecoder = JSONDecoder(),
         session: any HTTPSession = URLSession.shared) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.decoder = decoder
        self.session = session
    }

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

    func send<Response: Decodable & Sendable>(_ request: RESTRequest<Response>) async throws -> Response {
        let urlRequest = try makeURLRequest(from: request)
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RESTError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw RESTError.unacceptableStatusCode(httpResponse.statusCode, data)
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
}
