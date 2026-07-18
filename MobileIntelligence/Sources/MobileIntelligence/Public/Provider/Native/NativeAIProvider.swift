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
//  OpenAIProvider.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//


import FoundationModels

@available(iOS 26.0, macOS 26.0, *)
/// Native Apple FoundationModels inference provider.
public final actor NativeAIProvider: AIProvider {
    var session: LanguageModelSession?
    internal var availabilityOverride: SystemLanguageModel.Availability?

    /// Current system model availability, optionally overridden for tests.
    /// - Returns: The active system model availability.
    internal var availability: SystemLanguageModel.Availability {
        return availabilityOverride ?? SystemLanguageModel.default.availability
    }

    /// Overrides system model availability for tests.
    /// - Parameter override: Optional availability value to use instead of the system value.
    internal func setAvailabilityOverride(_ override: SystemLanguageModel.Availability?) {
        availabilityOverride = override
    }

    /// Creates a native Apple inference provider.
    public init() {}

    /// Configuration for native provider setup.
    public struct Configuration {}
}
