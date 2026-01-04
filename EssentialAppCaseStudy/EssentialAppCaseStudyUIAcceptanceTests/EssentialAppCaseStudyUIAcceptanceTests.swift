//
// EssentialAppCaseStudyUIAcceptanceTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import XCTest

final class EssentialAppCaseStudyUIAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()

        app.launch()

        XCTAssertEqual(app.cells.count, 22)
        XCTAssertGreaterThanOrEqual(app.images.count, 1)
    }
}
