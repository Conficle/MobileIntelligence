//
//  InferenceError.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

public extension MobileIntelligence.Inference {
    enum InferenceError: Error, MobileIntelligence.Core.MobileIntelligenceError {
        case coundNotCreateInferncePrpvider
        case invalidProviderOptions

        public var code: Int {
            switch self {
            case .coundNotCreateInferncePrpvider:
                return 1001
            case .invalidProviderOptions:
                return 1002
            }
            
        }
        
        public var message: String {
            switch self {
            case .coundNotCreateInferncePrpvider:
                return "Could not create inference provider"
            case .invalidProviderOptions:
                return "Invalid provider options"
            }
        }
    }
}
