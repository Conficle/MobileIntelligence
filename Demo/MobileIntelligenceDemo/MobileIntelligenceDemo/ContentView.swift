//
//  ContentView.swift
//  MobileIntelligenceDemo
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

import SwiftUI
import MobileIntelligence

struct ContentView: View {
    @AppStorage("selectedAIProvider") private var selectedAIProvider = AIProviderOption.native.rawValue
    @State private var promptText = ""
    @State private var queryText = ""
    @State private var responseText = ""
    @State private var errorMessage: String?
    @State private var isPredicting = false

    private var provider: AIProviderOption {
        AIProviderOption(rawValue: selectedAIProvider) ?? .native
    }

    private var canPredict: Bool {
        !queryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isPredicting
    }

    var body: some View {
        NavigationStack {
            List {
                providerSection
                promptSection
                querySection
                actionSection
                responseSection
            }
            .navigationTitle("Mobile Intelligence")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
    }

    private var providerSection: some View {
        Section {
            HStack(spacing: 12) {
                Image(systemName: provider.symbolName)
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Provider")
                        .font(.headline)
                    Text(provider.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 6)
        }
    }

    private var promptSection: some View {
        Section("Prompt") {
            TextEditor(text: $promptText)
                .frame(minHeight: 96)
                .overlay(alignment: .topLeading) {
                    if promptText.isEmpty {
                        Text("Enter system instructions or behavior guidance")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
                .accessibilityLabel("Prompt")
        }
    }

    private var querySection: some View {
        Section("User Query") {
            TextEditor(text: $queryText)
                .frame(minHeight: 120)
                .overlay(alignment: .topLeading) {
                    if queryText.isEmpty {
                        Text("Ask a question")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
                .accessibilityLabel("User query")
        }
    }

    private var actionSection: some View {
        Section {
            Button {
                Task {
                    await getPrediction()
                }
            } label: {
                HStack {
                    if isPredicting {
                        ProgressView()
                    }

                    Text(isPredicting ? "Getting Prediction" : "Get Prediction")
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!canPredict)
        }
    }

    private var responseSection: some View {
        Section("Prediction Response") {
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else if responseText.isEmpty {
                Text("No response yet")
                    .foregroundStyle(.secondary)
            } else {
                Text(responseText)
                    .textSelection(.enabled)
            }
        }
    }

    private func getPrediction() async {
        let trimmedQuery = queryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        isPredicting = true
        errorMessage = nil
        responseText = ""

        do {
            let client = DefaultAIClient()
            let inferenceProvider = try provider.makeInferenceProvider()
            await client.bootstrapInference(inferenceProvider)

            let request = PredictionRequest(
                prompt: Prompt(instructions: promptText),
                context: Context(),
                query: Query(question: trimmedQuery),
                temperature: 0.7,
                maxTokens: 500,
                reasoning: .medium
            )

            let response = try await client.predict(forRequest: request)
            responseText = response.content.isEmpty ? "PredictionResponse received." : response.content
        } catch {
            errorMessage = error.localizedDescription
        }

        isPredicting = false
    }
}

struct SettingsView: View {
    @AppStorage("selectedAIProvider") private var selectedAIProvider = AIProviderOption.native.rawValue

    var body: some View {
        Form {
            Section("AI Provider") {
                Picker("Provider", selection: $selectedAIProvider) {
                    ForEach(AIProviderOption.allCases) { provider in
                        Label(provider.displayName, systemImage: provider.symbolName)
                            .tag(provider.rawValue)
                    }
                }
                .pickerStyle(.inline)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private enum AIProviderOption: String, CaseIterable, Identifiable {
    case native
    case openAI
    case anthropic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .native:
            "Native"
        case .openAI:
            "OpenAI"
        case .anthropic:
            "Anthropic"
        }
    }

    var symbolName: String {
        switch self {
        case .native:
            "iphone"
        case .openAI:
            "sparkles"
        case .anthropic:
            "brain.head.profile"
        }
    }

    func makeInferenceProvider() throws -> any InferenceProvider {
        switch self {
        case .native:
            if #available(iOS 26.0, *) {
                return NativeAIProvider()
            } else {
                throw PredictionDemoError.providerUnavailable("Native provider requires iOS 26 or later.")
            }
        case .openAI:
            return OpenAIProvider()
        case .anthropic:
            return AnthropicAIProvider()
        }
    }
}

private enum PredictionDemoError: LocalizedError {
    case providerUnavailable(String)

    var errorDescription: String? {
        switch self {
        case .providerUnavailable(let message):
            message
        }
    }
}

#Preview {
    ContentView()
}
