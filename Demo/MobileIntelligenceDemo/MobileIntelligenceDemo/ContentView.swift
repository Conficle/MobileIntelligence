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
//  ContentView.swift
//  MobileIntelligenceDemo
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

import SwiftUI
import MobileIntelligence

/// Main demo screen for entering prompts, queries, and viewing predictions.
struct ContentView: View {
    @AppStorage("selectedAIProvider") private var selectedAIProvider = AIProviderOption.native.rawValue
    @AppStorage("selectedOpenAIModel") private var selectedOpenAIModel = OpenAIModelType.gpt5_6.rawValue
    @AppStorage("selectedAnthropicModel") private var selectedAnthropicModel = AnthropicModelType.claude4_5_sonnet.rawValue
    @AppStorage("openAIAPIKey") private var openAIAPIKey = ""
    @State private var promptText = ""
    @State private var queryText = ""
    @State private var responseText = ""
    @State private var errorMessage: String?
    @State private var isPredicting = false

    /// Currently selected provider option.
    private var provider: AIProviderOption {
        AIProviderOption(rawValue: selectedAIProvider) ?? .native
    }

    /// Indicates whether the current UI state can start a prediction.
    private var canPredict: Bool {
        !queryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && provider.isConfigured(openAIAPIKey: openAIAPIKey)
            && !isPredicting
    }

    /// Root view content for the prediction demo.
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

    /// Displays the currently selected provider and model.
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
                    Text(provider.selectedModelName(openAIModelID: selectedOpenAIModel,
                                                    anthropicModelID: selectedAnthropicModel))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let configurationMessage = provider.configurationMessage(openAIAPIKey: openAIAPIKey) {
                        Text(configurationMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.vertical, 6)
        }
    }

    /// Displays the system prompt editor.
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

    /// Displays the user query editor.
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

    /// Displays the prediction action button.
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

    /// Displays the latest prediction response or error.
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

    /// Builds and sends a prediction request from the current UI state.
    private func getPrediction() async {
        let trimmedQuery = queryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        isPredicting = true
        errorMessage = nil
        responseText = ""

        do {
            let client = DefaultAIClient()
            let inferenceProvider = try provider.makeInferenceProvider(openAIAPIKey: openAIAPIKey)
            await client.bootstrapInference(
                inferenceProvider,
                model: provider.selectedModel(
                    openAIModelID: selectedOpenAIModel,
                    anthropicModelID: selectedAnthropicModel
                )
            )

            let request = PredictionRequest(
                prompt: Prompt(instructions: promptText),
                context: Context(),
                query: Query(question: trimmedQuery),
                temperature: nil,
                maxTokens: nil,
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

/// Settings screen for selecting providers, models, and credentials.
struct SettingsView: View {
    @AppStorage("selectedAIProvider") private var selectedAIProvider = AIProviderOption.native.rawValue
    @AppStorage("selectedOpenAIModel") private var selectedOpenAIModel = OpenAIModelType.gpt5_6.rawValue
    @AppStorage("selectedAnthropicModel") private var selectedAnthropicModel = AnthropicModelType.claude4_5_sonnet.rawValue
    @AppStorage("openAIAPIKey") private var openAIAPIKey = ""

    /// Root view content for demo settings.
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

            modelSection

            if selectedAIProvider == AIProviderOption.openAI.rawValue {
                Section("OpenAI") {
                    SecureField("API Key", text: $openAIAPIKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text("The key is stored locally for the demo app and used to configure OpenAIProvider.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    /// Displays provider-specific model selection controls.
    private var modelSection: some View {
        switch AIProviderOption(rawValue: selectedAIProvider) ?? .native {
        case .native:
            Section("Model") {
                LabeledContent("Model", value: NativeModelType.system.name)
            }
        case .openAI:
            Section("Model") {
                Picker("Model", selection: $selectedOpenAIModel) {
                    ForEach(DemoModelCatalog.openAI, id: \.rawValue) { model in
                        Text(model.name)
                            .tag(model.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }
        case .anthropic:
            Section("Model") {
                Picker("Model", selection: $selectedAnthropicModel) {
                    ForEach(DemoModelCatalog.anthropic, id: \.rawValue) { model in
                        Text(model.name)
                            .tag(model.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
}

/// Provider choices available in the demo app.
private enum AIProviderOption: String, CaseIterable, Identifiable {
    case native
    case openAI
    case anthropic

    /// Stable identifier used by SwiftUI lists and pickers.
    var id: String { rawValue }

    /// Display name shown in the demo UI.
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

    /// SF Symbol name shown in the demo UI.
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

    /// Resolves the selected provider-specific model.
    func selectedModel(openAIModelID: String, anthropicModelID: String) -> any AIModel {
        switch self {
        case .native:
            NativeModelType.system
        case .openAI:
            OpenAIModelType(rawValue: openAIModelID) ?? .gpt5_6
        case .anthropic:
            AnthropicModelType(rawValue: anthropicModelID) ?? .claude4_5_sonnet
        }
    }

    /// Resolves the selected provider-specific model name.
    func selectedModelName(openAIModelID: String, anthropicModelID: String) -> String {
        selectedModel(openAIModelID: openAIModelID, anthropicModelID: anthropicModelID).name
    }

    /// Indicates whether the provider has enough configuration to run.
    func isConfigured(openAIAPIKey: String) -> Bool {
        switch self {
        case .native, .anthropic:
            true
        case .openAI:
            !openAIAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    /// Returns a configuration warning message when the provider is not ready.
    func configurationMessage(openAIAPIKey: String) -> String? {
        switch self {
        case .native, .anthropic:
            nil
        case .openAI:
            isConfigured(openAIAPIKey: openAIAPIKey) ? nil : "Add an OpenAI API key in Settings."
        }
    }

    /// Creates an inference provider for the selected option.
    func makeInferenceProvider(openAIAPIKey: String) throws -> any InferenceProvider {
        switch self {
        case .native:
            if #available(iOS 26.0, *) {
                return NativeAIProvider()
            } else {
                throw PredictionDemoError.providerUnavailable("Native provider requires iOS 26 or later.")
            }
        case .openAI:
            let apiKey = openAIAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !apiKey.isEmpty else {
                throw PredictionDemoError.providerUnavailable("OpenAI API key is required.")
            }
            return OpenAIProvider(configuration: .init(apiKey: apiKey))
        case .anthropic:
            return AnthropicAIProvider()
        }
    }
}

/// Model lists used by the demo model pickers.
private enum DemoModelCatalog {
    static let openAI: [OpenAIModelType] = [
        .gpt5_6,
        .gpt5_5,
        .gpt5_5_pro,
        .gpt5_4,
        .gpt5_4_pro,
        .gpt5_4_mini,
        .gpt5_4_nano,
        .gpt5_2,
        .gpt5_1,
        .gpt5,
        .gpt5_pro,
        .gpt5_mini,
        .gpt5_nano,
        .gpt4_1,
        .gpt4_1_mini,
        .gpt4_1_nano
    ]

    static let anthropic: [AnthropicModelType] = [
        .claude4_5_sonnet,
        .claude4_5_opus,
        .claude4_sonnet,
        .claude4_opus,
        .claude4_haiku,
        .claude3_7_sonnet,
        .claude3_5_sonnet,
        .claude3_5_haiku,
        .claude3_opus,
        .claude3_sonnet,
        .claude3_haiku
    ]
}

/// Errors surfaced by the demo app before prediction starts.
private enum PredictionDemoError: LocalizedError {
    case providerUnavailable(String)

    /// User-facing error description.
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
