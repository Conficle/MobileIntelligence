//
//  InferenceStreamEvent.swift
//  MobileIntelligence
//
//  Created by Nitin Bhagwan Manghwani on 14/07/26.
//

public enum InferenceStreamEvent: Sendable {
    case started
    case textDelta(String)
    case completed(PredictionResponse)
}
