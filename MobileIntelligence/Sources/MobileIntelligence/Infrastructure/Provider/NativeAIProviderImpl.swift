//
//  NativeAIProvider.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

extension MobileIntelligence.Infrastructure {
    final actor NativeAIProvider: MobileIntelligence.Inference.InferenceCapable {
        private let configuration: MobileIntelligence.Core.NativeProvider.Configuration

        init(configuration: MobileIntelligence.Core.NativeProvider.Configuration) {
            self.configuration = configuration
        }

        func predict(forRequest request: MobileIntelligence.Inference.Request) async throws -> MobileIntelligence.Inference.Response {
            guard let nativeOptions: MobileIntelligence.Inference.NativeOptions = request.options as? MobileIntelligence.Inference.NativeOptions else {
                throw MobileIntelligence.Inference.InferenceError.invalidProviderOptions
            }
            return MobileIntelligence.Inference.Response()
        }
    }
    
}
