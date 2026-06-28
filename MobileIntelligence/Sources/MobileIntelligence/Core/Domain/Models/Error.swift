//
//  Error.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

public extension MobileIntelligence.Core {
    protocol MobileIntelligenceError {
        var code: Int { get }
        var message: String { get }
    }
}

public extension MobileIntelligence.Core {
    enum CoreError: Error, MobileIntelligenceError {
        case invalidProviderConfiguration
        case predictionFailed

        public var code: Int {
            switch self {
            case .invalidProviderConfiguration:
                return 1001
            case .predictionFailed:
                return 1002
            }
        }

        public var message: String {
            switch self {
            case .invalidProviderConfiguration:
                return "Invalid provider configuration"
            case .predictionFailed:
                return "Prediction failed"
            }
        }
    }
}
