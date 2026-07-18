# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.0] - 2026-07-18

### Added

#### Core Inference
- Vendor-agnostic inference API for Apple platforms.
- Unified `DefaultAIClient` for prediction and streaming.
- Provider abstraction through `InferenceProvider`.
- Strongly typed prediction request and response models.

#### Providers
- Apple Foundation Models provider for on-device inference.
- OpenAI provider using the Responses API.
- Support for custom provider implementations.

#### Streaming
- Streaming inference using `AsyncThrowingStream`.
- Normalized streaming events across supported providers.

#### Prediction Caching
- Shared in-memory prediction cache.
- Actor-safe cache implementation.
- Configurable cache policies:
  - `automatic`
  - `reload`
  - `cacheOnly`
- Deterministic cache keys based on provider, model, and request parameters.

#### Networking
- Lightweight REST client for provider communication.
- Server-Sent Events (SSE) support for OpenAI streaming responses.

#### Swift Concurrency
- Actor-based architecture.
- Async/await APIs throughout the SDK.

#### Demo Application
- SwiftUI sample application.
- Provider selection.
- Model selection.
- Cache policy selection.
- Streaming demonstration.

#### Testing
- Unit tests covering:
  - Client APIs
  - Inference engine
  - Providers
  - REST infrastructure
  - Streaming
  - Prediction cache

#### Documentation
- Comprehensive README.
- Architecture overview.
- Internal architecture diagrams.
- Usage examples.