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

/// Groups common REST client configuration values.
struct RESTClientConfiguration: Sendable {
    let baseURL: String
    let defaultHeaders: [String: String]

    /// Creates a REST client configuration.
    /// - Parameters:
    ///   - baseURL: The base URL used for all requests.
    ///   - defaultHeaders: Headers applied to every request unless overridden.
    init(baseURL: String,
         defaultHeaders: [String: String] = [:]) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
    }
}
