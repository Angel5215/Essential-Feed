//
// FeedPresenterTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import XCTest

final class FeedPresenter {
    let view: FeedPresenterTests.ViewSpy

    init(view: FeedPresenterTests.ViewSpy) {
        self.view = view
    }
}

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()

        _ = FeedPresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    // MARK: - Helpers

    final class ViewSpy {
        let messages = [Any]()
    }
}
