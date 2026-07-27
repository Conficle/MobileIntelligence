//  MobileIntelligence
//
//  Copyright (c) 2026 Nitin Manghwani
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

//
//  FewShotPrompt.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 27/07/26.
//

public struct FewShotPrompt {
    private let systemInstruction: String
    private var examples: [PromptExample] = []

    init(systemInstruction: String, examples: [PromptExample]) {
        self.systemInstruction = systemInstruction
        self.examples = examples
    }

    mutating func addExample(_ example: PromptExample) {
        examples.append(example)
    }
}

public extension FewShotPrompt {
    
    struct Builder: PromptTemplateBuilder {
        
        private var instructions: String = ""
        private var examples: [PromptExample] = []
        
        public init() {}
        
        @discardableResult
        public mutating func instructions(_ value: String) -> Self {
            instructions = value
            return self
        }
        
        @discardableResult
        public mutating func example(
            input: String,
            output: String
        ) -> Self {
            examples.append(
                PromptExample(
                    input: input,
                    output: output
                )
            )
            return self
        }
        
        public func build() throws -> PromptTemplate {
            precondition(
                !examples.isEmpty,
                "FewShotPrompt requires at least one example."
            )
            
            return FewShotPrompt(
                systemInstruction: instructions,
                examples: examples
            )
        }
    }
}

extension FewShotPrompt: PromptTemplate {
    public func buildPrompt() throws -> Prompt {
        guard !systemInstruction.isEmpty else {
            throw PromptError.emptyInstructions
        }
        guard !examples.isEmpty else {
            throw PromptError.emptyExamples
        }

        var lines: [String] = []
        
        if !systemInstruction.isEmpty {
            lines.append(systemInstruction)
        }
        
        for example in examples {
            lines.append(example.input)
            lines.append(example.output)
        }
        
        return Prompt(
            instructions: lines.joined(separator: "\n")
        )
    }
}
