//
//  NativeProviderConfiguration.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

public extension MobileIntelligence.Core {
    enum NativeProvider {
    }
}
public extension MobileIntelligence.Core.NativeProvider {
    struct Configuration: MobileIntelligence.Core.ProviderConfiguration {
        public var providerType: MobileIntelligence.Core.ProviderType {
            return .native
        }
        public var model: any MobileIntelligence.Core.AIModel

        public init(model: any MobileIntelligence.Core.AIModel) {
            self.model = model
        }
    }
}

public extension MobileIntelligence.Core.NativeProvider {
    enum NativeModelType: MobileIntelligence.Core.AIModel {
        case afm3Core
        case afm3CoreAdvanced

        public var name: String {
            switch self {
                case .afm3Core:
                return "afm3_core"
            case .afm3CoreAdvanced:
                return "afm3_core_advanced"
            }
        }
    }
}
