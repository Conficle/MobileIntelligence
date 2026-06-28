//
//  ProviderFactory.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

extension MobileIntelligence.Infrastructure {
    protocol ProviderFactory: Actor {
        func makeInferenceProvider(forproviderConfiguration configuration: MobileIntelligence.Core.ProviderConfiguration) throws -> any MobileIntelligence.Inference.InferenceCapable
    }
}

extension MobileIntelligence.Infrastructure {
    final actor DefaultProviderFactory: ProviderFactory {
        private var nativeProvider: MobileIntelligence.Infrastructure.NativeAIProvider?
        private var openAIProvider: MobileIntelligence.Infrastructure.OpenAIProvider?
        private var antropicProvider: MobileIntelligence.Infrastructure.AnthropicProvider?

        func makeInferenceProvider(forproviderConfiguration configuration: MobileIntelligence.Core.ProviderConfiguration) throws -> any MobileIntelligence.Inference.InferenceCapable {
            guard let inferenceProvider = try makeProvider(forproviderConfiguration: configuration) as? (any MobileIntelligence.Inference.InferenceCapable) else {
                throw MobileIntelligence.Inference.InferenceError.coundNotCreateInferncePrpvider
            }
            return inferenceProvider
        }

        private func makeProvider(forproviderConfiguration configuration: MobileIntelligence.Core.ProviderConfiguration) throws -> MobileIntelligence.Core.AIProvider {
            switch configuration.providerType {
            case .openAI:
                if let openAIProvider = self.openAIProvider {
                    return openAIProvider
                }
                guard let openAIConfiguration = configuration as? MobileIntelligence.Core.OpenAIProvider.Configuration else {
                    throw MobileIntelligence.Core.CoreError.invalidProviderConfiguration
                }
                let openAIProvider = OpenAIProvider(configuration: openAIConfiguration)
                self.openAIProvider = openAIProvider
                return openAIProvider
            case .anthropic:
                guard let anthropicConfiguration = configuration as? MobileIntelligence.Core.AnthropicAIProvider.Configuration else {
                    throw MobileIntelligence.Core.CoreError.invalidProviderConfiguration
                }
                let antropicProvider = AnthropicProvider(configuration: anthropicConfiguration)
                self.antropicProvider = antropicProvider
                return antropicProvider
            case .native:
                guard let nativeConfiguration = configuration as? MobileIntelligence.Core.NativeProvider.Configuration else {
                    throw MobileIntelligence.Core.CoreError.invalidProviderConfiguration
                }
                let nativeProvider = NativeAIProvider(configuration: nativeConfiguration)
                self.nativeProvider = nativeProvider
                return nativeProvider
            }
        }
    }
}
