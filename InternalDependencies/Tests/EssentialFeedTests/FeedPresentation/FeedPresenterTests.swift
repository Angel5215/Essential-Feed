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
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    final class ViewSpy {
        let messages = [Any]()
    }
}
