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

/// Describes a typed REST request and its expected response type.
struct RESTRequest<Response: Decodable & Sendable>: Sendable {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let headers: [String: String]
    let body: Data?
    let timeoutInterval: TimeInterval?

    /// Creates a REST request from raw request components.
    /// - Parameters:
    ///   - path: The endpoint path for the request.
    ///   - method: The HTTP method to use.
    ///   - queryItems: Query items to include in the request URL.
    ///   - headers: Request-specific headers.
    ///   - body: Optional raw request body data.
    ///   - timeoutInterval: Optional request timeout interval.
    init(path: String,
         method: HTTPMethod = .get,
         queryItems: [URLQueryItem] = [],
         headers: [String: String] = [:],
         body: Data? = nil,
         timeoutInterval: TimeInterval? = nil) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
        self.timeoutInterval = timeoutInterval
    }

    /// Creates a REST request by encoding an Encodable JSON body.
    /// - Parameters:
    ///   - path: The endpoint path for the request.
    ///   - method: The HTTP method to use.
    ///   - queryItems: Query items to include in the request URL.
    ///   - headers: Request-specific headers.
    ///   - body: The encodable body to serialize as JSON.
    ///   - encoder: The encoder used to serialize the body.
    ///   - timeoutInterval: Optional request timeout interval.
    init<Body: Encodable>(path: String,
                          method: HTTPMethod = .post,
                          queryItems: [URLQueryItem] = [],
                          headers: [String: String] = [:],
                          jsonBody body: Body,
                          encoder: JSONEncoder = JSONEncoder(),
                          timeoutInterval: TimeInterval? = nil) throws {
        self.init(
            path: path,
            method: method,
            queryItems: queryItems,
            headers: headers,
            body: try encoder.encode(body),
            timeoutInterval: timeoutInterval
        )
    }
}

/// Represents a successful REST response with no response body.
struct EmptyRESTResponse: Decodable, Equatable, Sendable {
    /// Creates an empty response value.
    init() {}

    /// Decodes an empty response value from any decoder input.
    /// - Parameter decoder: The decoder supplied by Swift's Decodable system.
    init(from decoder: Decoder) throws {}
}
