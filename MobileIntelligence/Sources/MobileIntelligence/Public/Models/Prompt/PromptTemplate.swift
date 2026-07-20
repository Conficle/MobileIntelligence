//
//  PromptTemplate.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 20/07/26.
//

public protocol PromptTemplate: Sendable {
    func buildPrompt() -> Prompt
}
