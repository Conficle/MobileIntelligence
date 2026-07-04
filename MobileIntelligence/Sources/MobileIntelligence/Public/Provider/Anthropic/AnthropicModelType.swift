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
