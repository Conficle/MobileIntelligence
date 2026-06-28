//
//  AIModel.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 27/06/26.
//

public extension MobileIntelligence.Core {
    protocol AIModel: Sendable {
        var name: String { get }
    }
}
