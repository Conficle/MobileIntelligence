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

/// OpenAI-backed inference provider.
public final actor OpenAIProvider: AIProvider {
    let configuration: Configuration
    let restClient: any RESTClient
    var model: any AIModel = OpenAIModelType.gpt5_6

    /// Creates an OpenAI provider using the default REST client.
    /// - Parameter configuration: Configuration containing the OpenAI API key.
    public init(configuration: OpenAIProvider.Configuration) {
        self.configuration = configuration
        self.restClient = DefaultRESTClient(
            configuration: OpenAIAPIConfiguration.restClientConfiguration(
                apiKey: configuration.apiKey
            )
        )
    }

    /// Creates an OpenAI provider with a custom REST client for tests or alternate transport.
    /// - Parameters:
    ///   - configuration: Configuration containing the OpenAI API key.
    ///   - restClient: REST client used to send OpenAI requests.
    init(configuration: OpenAIProvider.Configuration,
         restClient: any RESTClient) {
        self.configuration = configuration
        self.restClient = restClient
    }

    /// Configuration required to call OpenAI APIs.
    public struct Configuration {
        let apiKey: String

        /// Creates OpenAI provider configuration.
        /// - Parameter apiKey: API key used to authenticate OpenAI requests.
        public init(apiKey: String) {
            self.apiKey = apiKey
        }
    }
}
