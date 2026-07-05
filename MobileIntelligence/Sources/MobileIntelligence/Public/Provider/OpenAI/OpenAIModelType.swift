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
//  OpenAIModelType.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

public enum OpenAIModelType: String, AIModel {

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
