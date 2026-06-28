//
//  ProviderConfiguration.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

public extension MobileIntelligence.Core {
    protocol ProviderConfiguration: Sendable {
        var model: AIModel { get set }
        var providerType: ProviderType { get }
    }
}
