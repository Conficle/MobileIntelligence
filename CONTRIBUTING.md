# Contributing to MobileIntelligence

Thank you for your interest in contributing to MobileIntelligence!

Whether you're reporting a bug, improving documentation, fixing an issue, or implementing a new feature, your contributions are greatly appreciated.

---

# Code of Conduct

By participating in this project, you agree to follow our
[Code of Conduct](CODE_OF_CONDUCT.md).

Please help us maintain a welcoming, respectful, and collaborative community.

---

# Getting Started

## Requirements

- macOS
- Xcode with Swift 6 support
- iOS 18 SDK or later
- iOS 26 SDK (required only when working with Apple Foundation Models)

## Clone the Repository

```bash
git clone https://github.com/<owner>/MobileIntelligence.git
cd MobileIntelligence
```

## Build

Using Swift Package Manager:

```bash
swift build
```

Or open the project in Xcode and build the package or demo application.

## Run Tests

```bash
swift test
```

Please ensure all tests pass before opening a Pull Request.

---

# Branching Strategy

MobileIntelligence follows the branching strategy below.

```
main
  ↑
integration
  ↑
development
  ↑
feature/<feature-name>
```

## Branch Responsibilities

### main

Contains production-ready releases.

Only release-ready code should be merged into this branch.

---

### integration

Used for release stabilization and integration testing.

Changes from `development` are promoted here before a release.

---

### development

Primary branch for active development.

All feature development should be based on this branch.

---

## Contributing Workflow

1. Create a feature branch from `development`

```text
feature/<feature-name>
```

Example:

```text
feature/prompt-builder
feature/gemini-provider
bugfix/cache-key
```

2. Implement your changes.

3. Add or update unit tests.

4. Update documentation if required.

5. Ensure the project builds successfully.

6. Submit a Pull Request targeting **`development`**.

Please do not submit Pull Requests directly to `main`.

---

# Ways to Contribute

## Report Bugs

Before creating a bug report:

- Search existing issues.
- Include clear reproduction steps.
- Include expected and actual behavior.
- Include your environment details.

---

## Suggest Features

Feature requests are welcome.

Please describe:

- The problem you're solving.
- Why the feature belongs in MobileIntelligence.
- A proposed API, if applicable.

---

## Request a Provider Integration

If you'd like support for another AI provider (such as Gemini, Anthropic, Azure OpenAI, Ollama, or Mistral), please use the **Provider Integration** issue template.

Include:

- Official API documentation
- Authentication method
- Streaming support
- Supported capabilities
- Example API usage

---

## Improve Documentation

Documentation contributions are always appreciated.

Examples include:

- README improvements
- Tutorials
- Sample code
- Architecture documentation
- API documentation

---

# Coding Guidelines

## Swift

- Prefer Swift Concurrency (`async`/`await`).
- Prefer actors over manual synchronization.
- Favor value types where appropriate.
- Follow the Swift API Design Guidelines.
- Write expressive, well-documented APIs.

---

## Architecture Principles

MobileIntelligence is designed to be **vendor agnostic**.

When contributing:

- Keep the public API provider agnostic.
- Avoid exposing provider-specific APIs unless they can be generalized.
- Keep networking isolated from provider implementations.
- Preserve the separation of responsibilities between:
  - `DefaultAIClient`
  - `InferenceEngine`
  - `InferenceProvider`
  - `RESTClient`
  - Cache

When adding new functionality, prefer extending existing abstractions instead of introducing provider-specific behavior.

---

# Pull Requests

Before submitting a Pull Request:

- Ensure the project builds successfully.
- Ensure all tests pass.
- Add tests for new functionality.
- Update documentation if needed.
- Keep Pull Requests focused on a single logical change.

---

# Development Roadmap

The project roadmap is maintained in the README.

Before implementing larger features, please open an issue to discuss the design.

This helps avoid duplicate work and ensures the implementation aligns with the project's long-term architecture.

---

# Questions

If you have questions about the project or its architecture, please open a GitHub Discussion or Issue.

We're happy to help.

---

Thank you for helping make MobileIntelligence better!