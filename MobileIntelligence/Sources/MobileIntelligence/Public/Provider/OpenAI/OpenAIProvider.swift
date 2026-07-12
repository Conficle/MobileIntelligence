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

public final actor OpenAIProvider: AIProvider {
    let configuration: Configuration
    let restClient: any RESTClient
    var model: any AIModel = OpenAIModelType.gpt5_6

    public init(configuration: OpenAIProvider.Configuration) {
        self.configuration = configuration
        self.restClient = DefaultRESTClient(
            configuration: OpenAIAPIConfiguration.restClientConfiguration(
                apiKey: configuration.apiKey
            )
        )
    }

    init(configuration: OpenAIProvider.Configuration,
         restClient: any RESTClient) {
        self.configuration = configuration
        self.restClient = restClient
    }

    public struct Configuration {
        let apiKey: String

        public init(apiKey: String) {
            self.apiKey = apiKey
        }
    }
}
