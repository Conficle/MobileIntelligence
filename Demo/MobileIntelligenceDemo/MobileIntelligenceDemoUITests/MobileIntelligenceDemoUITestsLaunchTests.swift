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
//  MobileIntelligenceDemoUITestsLaunchTests.swift
//  MobileIntelligenceDemoUITests
//
//  Created by Nitin Bhagwan Manghwani on 05/07/26.
//

import XCTest

/// UI launch screenshot test suite for the demo app.
final class MobileIntelligenceDemoUITestsLaunchTests: XCTestCase {

    /// Indicates that launch tests run for each UI configuration.
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    /// Prepares each launch test.
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    /// Launches the app and captures a launch screenshot attachment.
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
