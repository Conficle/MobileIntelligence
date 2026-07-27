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

public extension ZeroShotPrompt {
    struct Builder {
        var instructions: String = ""
        
        @discardableResult
        public mutating func instructions(_ value: String) -> Self {
            instructions = value
            return self
        }

        public func build() throws -> PromptTemplate {
            return ZeroShotPrompt(systemInstruction: instructions)
        }
    }
}

extension ZeroShotPrompt: PromptTemplate {
    public func buildPrompt() throws -> Prompt {
        return .init(instructions: systemInstruction)
    }
}
