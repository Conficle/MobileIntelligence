# MobileIntelligence

MobileIntelligence is an open-source Swift SDK for adding AI prediction capabilities to iOS applications through a provider-oriented architecture.

The package is designed around small, actor-safe contracts for clients, providers, requests, and responses. It currently includes a native Apple FoundationModels path for supported platforms, plus provider shells for OpenAI and Anthropic integrations.

## Highlights

- Provider-oriented API for routing predictions through native, OpenAI, Anthropic, or custom providers.
- Swift Concurrency first, with actor-based clients and providers.
- Native Apple inference support using `FoundationModels` on supported iOS versions.
- Typed prediction requests with prompt instructions, query text, context, token limits, temperature, and reasoning level.
- Lightweight response model for returning generated content.
- Demo SwiftUI app for exercising provider selection and prediction flow.

## Requirements

- Swift 6.0+
- iOS 18+
- Xcode with Swift Package Manager support
- iOS 26+ for Apple FoundationModels-backed native inference

## Installation

Add MobileIntelligence to your app with Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/<owner>/MobileIntelligence.git", branch: "main")
]
```

Then add the package product to your target:

```swift
.product(name: "MobileIntelligence", package: "MobileIntelligence")
```

## Quick Start

```swift
import MobileIntelligence

let client = DefaultAIClient()
let provider = OpenAIProvider()

await client.bootstrapInference(provider)

let request = PredictionRequest(
    prompt: Prompt(instructions: "Answer clearly and concisely."),
    context: Context(),
    query: Query(question: "What is MobileIntelligence?"),
    temperature: 0.7,
    maxTokens: 500,
    reasoning: .medium
)

let response = try await client.predict(forRequest: request)
print(response.content)
```

## Native Apple Inference

Native inference is available through `NativeAIProvider` on iOS 26 and later.

```swift
import MobileIntelligence

if #available(iOS 26.0, *) {
    let client = DefaultAIClient()
    let provider = NativeAIProvider()

    await client.bootstrapInference(provider)

    let request = PredictionRequest(
        prompt: Prompt(instructions: "Respond as a helpful mobile assistant."),
        context: Context(),
        query: Query(question: "Summarize the benefits of on-device AI."),
        temperature: 0.7,
        maxTokens: 300,
        reasoning: .medium
    )

    let response = try await client.predict(forRequest: request)
    print(response.content)
}
```

For typed FoundationModels generation, use the Apple-specific client and provider APIs with `Generable` response types.

## Core Concepts

### `DefaultAIClient`

The primary entry point for applications. It owns the inference engine and exposes prediction APIs through `InferenceClient`.

### `InferenceProvider`

The provider contract used by prediction backends. Providers are actors and expose lifecycle and prediction methods.

### `PredictionRequest`

The request payload passed into providers. It contains:

- `Prompt` for system instructions.
- `Context` for future contextual state.
- `Query` for the user question.
- `temperature` for sampling behavior.
- `maxTokens` for output limits.
- `Reasoning` for reasoning depth.

### `PredictionResponse`

The normalized response returned from prediction calls. It currently exposes generated text through `content`.

## Providers

| Provider | Status | Notes |
| --- | --- | --- |
| Native Apple | In progress | Uses `FoundationModels` and requires iOS 26+. |
| OpenAI | Scaffolded | Public provider type and inference contract are present. |
| Anthropic | Scaffolded | Public provider type and inference contract are present. |
| Custom | Supported by design | Implement `InferenceProvider` to add your own backend. |

## Demo App

The repository includes a SwiftUI demo app under:

```text
Demo/MobileIntelligenceDemo
```

The demo app shows:

- Provider selection.
- Prompt and query input.
- Request construction.
- Client bootstrapping.
- Prediction response rendering.

Open the Xcode project to run it locally:

```text
Demo/MobileIntelligenceDemo/MobileIntelligenceDemo.xcodeproj
```

## Project Layout

```text
MobileIntelligence/
  Sources/MobileIntelligence/
    Public/
      Client/
      Inference/
      Models/
      Provider/
    Private/
Demo/
  MobileIntelligenceDemo/
```

## Roadmap

- Complete OpenAI provider implementation.
- Complete Anthropic provider implementation.
- Expand native Apple inference support.
- Add richer context handling.
- Add structured response helpers.
- Add provider authentication configuration.
- Add stronger unit and integration test coverage.

## License

MobileIntelligence is released under the Apache License 2.0. See [LICENSE](LICENSE) for details.
