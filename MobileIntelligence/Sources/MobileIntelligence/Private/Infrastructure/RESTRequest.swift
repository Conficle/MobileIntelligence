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

struct RESTRequest<Response: Decodable & Sendable>: Sendable {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let headers: [String: String]
    let body: Data?
    let timeoutInterval: TimeInterval?

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

struct EmptyRESTResponse: Decodable, Equatable, Sendable {
    init() {}

    init(from decoder: Decoder) throws {}
}
