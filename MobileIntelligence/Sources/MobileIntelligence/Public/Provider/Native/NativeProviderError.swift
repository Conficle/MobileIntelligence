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
//  NativeProviderError.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 12/07/26.
//

public enum NativeProviderError: Error, MobileIntelligenceError {
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case unknown
    
    public var code: Int {
        switch self {
        case .deviceNotEligible:
            return 001
        case .appleIntelligenceNotEnabled:
            return 002
        case .modelNotReady:
            return 003
        case .unknown:
            return 004
        }
    }
    
    public var message: String {
        switch self {
        case .deviceNotEligible:
            return "Device is not eligible"
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligence is not enabled"
        case .modelNotReady:
            return "Model is not ready"
        case .unknown:
            return "Unknown"
        }
    }
}
