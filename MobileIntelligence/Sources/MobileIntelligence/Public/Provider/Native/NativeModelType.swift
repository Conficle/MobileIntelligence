//
//  NativeModelType.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

public enum NativeModelType: AIModel {
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
