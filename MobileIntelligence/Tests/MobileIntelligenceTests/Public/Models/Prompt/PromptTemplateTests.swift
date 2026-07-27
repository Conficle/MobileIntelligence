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

import Testing
@testable import MobileIntelligence

/// Verifies prompt error codes and messages.
@Test func promptErrorCodeAndMessageValuesAreCorrect() {
    let emptyInstructions = PromptError.emptyInstructions
    #expect(emptyInstructions.code == 2001)
    #expect(emptyInstructions.message == "Empty instructions")

    let emptyExamples = PromptError.emptyExamples
    #expect(emptyExamples.code == 2002)
    #expect(emptyExamples.message == "Empty examples")
}

/// Verifies zero-shot builders produce prompts from their instructions.
@Test func zeroShotPromptBuilderBuildsPromptWithInstructions() throws {
    var builder = ZeroShotPrompt.Builder()
    let template = try builder
        .instructions("Answer in one sentence.")
        .build()

    let prompt = try template.buildPrompt()

    #expect(prompt.instructions == "Answer in one sentence.")
}

/// Verifies few-shot builders concatenate instructions and examples in order.
@Test func fewShotPromptBuilderBuildsPromptWithInstructionsAndExamples() throws {
    var builder = FewShotPrompt.Builder()
    builder.instructions("Classify each review sentiment.")
    builder.example(input: "Review: Loved it", output: "positive")
    builder.example(input: "Review: Too slow", output: "negative")
    let template = try builder.build()

    let prompt = try template.buildPrompt()

    #expect(
        prompt.instructions ==
            """
            Classify each review sentiment.
            Review: Loved it
            positive
            Review: Too slow
            negative
            """
    )
}

/// Verifies few-shot prompts fail when examples are provided without instructions.
@Test func fewShotPromptThrowsWhenInstructionsAreEmpty() throws {
    var builder = FewShotPrompt.Builder()
    let template = try builder
        .example(input: "Question", output: "Answer")
        .build()

    do {
        _ = try template.buildPrompt()
        Issue.record("Expected few-shot prompt to throw on empty instructions")
    } catch PromptError.emptyInstructions {
        // Expected
    } catch {
        Issue.record("Expected PromptError.emptyInstructions, received \(error)")
    }
}

/// Verifies few-shot prompts fail when instructions are provided without examples.
@Test func fewShotPromptThrowsWhenExamplesAreEmpty() throws {
    let template = FewShotPrompt(
        systemInstruction: "Answer with the label only.",
        examples: []
    )

    do {
        _ = try template.buildPrompt()
        Issue.record("Expected few-shot prompt to throw on empty examples")
    } catch PromptError.emptyExamples {
        // Expected
    } catch {
        Issue.record("Expected PromptError.emptyExamples, received \(error)")
    }
}

/// Verifies prompt factories expose the few-shot builder entry point.
@Test func promptFactoryCreatesFewShotBuilder() throws {
    var builder = PromptFactory.fewShot()
    builder.instructions("Translate to Spanish.")
    builder.example(input: "Hello", output: "Hola")
    let template = try builder.build()

    let prompt = try template.buildPrompt()

    #expect(prompt.instructions == "Translate to Spanish.\nHello\nHola")
}
