//
//  Query.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 28/06/26.
//

public struct Query: Sendable {
    let question: String

    public init(question: String) {
        self.question = question
    }
}
