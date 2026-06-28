//
//  InferenceOptions.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

public extension MobileIntelligence.Inference {
    protocol ProviderOptions: Sendable {}
}

public extension MobileIntelligence.Inference {
    struct NativeOptions: ProviderOptions {
    }
}

public extension MobileIntelligence.Inference {
    struct OpenAIOptions: ProviderOptions {
    }
}

public extension MobileIntelligence.Inference {
    struct AnthropicOptions: ProviderOptions {
    }
}
