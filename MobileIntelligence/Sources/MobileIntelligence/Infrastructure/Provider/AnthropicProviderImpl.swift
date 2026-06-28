//
//  AnthropicProvider.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

extension MobileIntelligence.Infrastructure {
    final actor AnthropicProvider: MobileIntelligence.Inference.InferenceCapable {
        private let configuration: MobileIntelligence.Core.AnthropicAIProvider.Configuration

        init (configuration: MobileIntelligence.Core.AnthropicAIProvider.Configuration) {
            self.configuration = configuration
        }

        func predict(forRequest request: MobileIntelligence.Inference.Request) async throws -> MobileIntelligence.Inference.Response {
            guard let nativeOptions: MobileIntelligence.Inference.AnthropicOptions = request.options as? MobileIntelligence.Inference.AnthropicOptions else {
                throw MobileIntelligence.Inference.InferenceError.invalidProviderOptions
            }
            return MobileIntelligence.Inference.Response()
        }
    }
    
}
