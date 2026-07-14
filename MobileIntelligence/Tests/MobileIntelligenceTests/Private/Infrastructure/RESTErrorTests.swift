//  MobileIntelligence
//
//  Copyright (c) 2026 Nitin Bhagwan Manghwani
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

/// Verifies localized descriptions for each REST error case.
@Test func restErrorLocalizedDescriptionsMatchCases() {
    let decodingFailed = RESTError.decodingFailed("Broken")
    #expect(decodingFailed.errorDescription == "Broken")

    let emptyResponse = RESTError.emptyResponse
    #expect(emptyResponse.errorDescription == "Response body was empty")

    let invalidResponse = RESTError.invalidResponse
    #expect(invalidResponse.errorDescription == "Invalid response")

    let invalidURL = RESTError.invalidURL
    #expect(invalidURL.errorDescription == "Invalid URL")

    let unacceptableStatusCode = RESTError.unacceptableStatusCode(500, Data())
    #expect(unacceptableStatusCode.errorDescription == "Request failed with status code 500")

    let apiError = RESTError.apiError(statusCode: 400, message: "Bad request", data: Data())
    #expect(apiError.errorDescription == "Bad request")
}
