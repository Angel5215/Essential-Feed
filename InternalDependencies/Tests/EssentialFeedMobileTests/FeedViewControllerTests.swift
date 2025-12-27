//
// FeedViewControllerTests.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeedMobile
import XCTest

final class FeedViewController {
    private let loader: FeedViewControllerTests.LoaderSpy

    init(loader: FeedViewControllerTests.LoaderSpy) {
        self.loader = loader
    }
}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    // MARK: - Helpers

    final class LoaderSpy {
        private(set) var loadCallCount = 0
    }
}
