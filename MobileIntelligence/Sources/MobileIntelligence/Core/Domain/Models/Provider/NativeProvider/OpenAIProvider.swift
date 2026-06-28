//
//  OpenAIProvider.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

public extension MobileIntelligence.Core {
    enum OpenAIProvider {
    }
}
public extension MobileIntelligence.Core.OpenAIProvider {
    struct Configuration: MobileIntelligence.Core.ProviderConfiguration {
        public var providerType: MobileIntelligence.Core.ProviderType {
            return .openAI
        }
        public var model: any MobileIntelligence.Core.AIModel

        public init(model: any MobileIntelligence.Core.AIModel) {
            self.model = model
        }
    }
}

public extension MobileIntelligence.Core.NativeProvider {
    enum OpenAIModel: String, MobileIntelligence.Core.AIModel {

        // MARK: - GPT 4.1

        case gpt4_1 = "gpt-4.1"
        case gpt4_1_mini = "gpt-4.1-mini"
        case gpt4_1_nano = "gpt-4.1-nano"

        // MARK: - GPT 5

        case gpt5 = "gpt-5"
        case gpt5_mini = "gpt-5-mini"
        case gpt5_nano = "gpt-5-nano"
        case gpt5_pro = "gpt-5-pro"

        // MARK: - GPT 5.1

        case gpt5_1 = "gpt-5.1"

        // MARK: - GPT 5.2

        case gpt5_2 = "gpt-5.2"

        // MARK: - GPT 5.3

        // GPT-5.3 was primarily released as Codex models.
        // No general-purpose GPT-5.3 model.

        // MARK: - GPT 5.4

        case gpt5_4 = "gpt-5.4"
        case gpt5_4_pro = "gpt-5.4-pro"
        case gpt5_4_mini = "gpt-5.4-mini"
        case gpt5_4_nano = "gpt-5.4-nano"

        // MARK: - GPT 5.5

        case gpt5_5 = "gpt-5.5"
        case gpt5_5_pro = "gpt-5.5-pro"

        public var name: String {
            return rawValue
        }
    }
}
