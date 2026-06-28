//
//  OpenAIProvider.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

extension MobileIntelligence.Infrastructure {
    final actor OpenAIProvider: MobileIntelligence.Inference.InferenceCapable {
        private let configuration: MobileIntelligence.Core.OpenAIProvider.Configuration

        init(configuration: MobileIntelligence.Core.OpenAIProvider.Configuration) {
            self.configuration = configuration
        }

        func predict(forRequest request: MobileIntelligence.Inference.Request) async throws -> MobileIntelligence.Inference.Response {
            guard let nativeOptions: MobileIntelligence.Inference.OpenAIOptions = request.options as? MobileIntelligence.Inference.OpenAIOptions else {
                throw MobileIntelligence.Inference.InferenceError.invalidProviderOptions
            }
            return MobileIntelligence.Inference.Response()
        }
    }
    
}
