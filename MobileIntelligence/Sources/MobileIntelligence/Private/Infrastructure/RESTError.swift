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

/// Represents failures produced while building, sending, or decoding REST requests.
enum RESTError: Error, Sendable {
    case apiError(statusCode: Int, message: String, data: Data)
    case decodingFailed(String)
    case emptyResponse
    case invalidResponse
    case invalidURL
    case unacceptableStatusCode(Int, Data)
}

/// Provides user-facing descriptions for REST failures.
extension RESTError: LocalizedError {
    /// A localized message describing the REST failure.
    /// - Returns: The localized error description.
    var errorDescription: String? {
        switch self {
        case .apiError(_, let message, _):
            return message
        case .decodingFailed(let message):
            return message
        case .emptyResponse:
            return "Response body was empty"
        case .invalidResponse:
            return "Invalid response"
        case .invalidURL:
            return "Invalid URL"
        case .unacceptableStatusCode(let statusCode, _):
            return "Request failed with status code \(statusCode)"
        }
    }
}
