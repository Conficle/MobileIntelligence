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
//  Error.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

/// Common shape for MobileIntelligence errors.
public protocol MobileIntelligenceError {
    /// Stable error code.
    /// - Returns: The numeric code for the error.
    var code: Int { get }

    /// Human-readable error message.
    /// - Returns: The message describing the error.
    var message: String { get }
}

/// Core package errors.
public enum CoreError: Error, MobileIntelligenceError {
    case invalidSession
    case invalidProviderConfiguration
    case predictionFailed
    case cacheMiss

    /// Stable error code.
    /// - Returns: The numeric code for the core error.
    public var code: Int {
        switch self {
        case .invalidProviderConfiguration:
            return 1001
        case .predictionFailed:
            return 1002
        case .invalidSession:
            return 1003
        case .cacheMiss:
            return 1004
        }
    }

    /// Human-readable error message.
    /// - Returns: The message describing the core error.
    public var message: String {
        switch self {
        case .invalidProviderConfiguration:
            return "Invalid provider configuration"
        case .predictionFailed:
            return "Prediction failed"
        case .invalidSession:
            return "Invalid session"
        case .cacheMiss:
            return "Cache miss"
        }
    }
}
