//
//  ZeroShotPrompt.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 20/07/26.
//

public struct ZeroShotPrompt {
    private let systemInstruction: String

    static func system(_ systemInstruction: String) -> Self {
        .init(systemInstruction: systemInstruction)
    }
}

extension ZeroShotPrompt: PromptTemplate {
    public func buildPrompt() -> Prompt {
        return .init(instructions: systemInstruction)
    }
}
