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
//  AnthropicModelType.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

public enum AnthropicModelType: String, AIModel {

        // MARK: - Claude 3

        case claude3_opus = "claude-3-opus"
        case claude3_sonnet = "claude-3-sonnet"
        case claude3_haiku = "claude-3-haiku"

        // MARK: - Claude 3.5

        case claude3_5_sonnet = "claude-3-5-sonnet"
        case claude3_5_haiku = "claude-3-5-haiku"

        // MARK: - Claude 3.7

        case claude3_7_sonnet = "claude-3-7-sonnet"

        // MARK: - Claude 4

        case claude4_opus = "claude-4-opus"
        case claude4_sonnet = "claude-4-sonnet"
        case claude4_haiku = "claude-4-haiku"

        // MARK: - Claude 4.5

        case claude4_5_opus = "claude-4.5-opus"
        case claude4_5_sonnet = "claude-4.5-sonnet"

        public var name: String {
            return rawValue
        }
    }
