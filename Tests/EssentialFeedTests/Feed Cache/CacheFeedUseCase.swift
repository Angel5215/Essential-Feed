//
// CacheFeedUseCase.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import XCTest

final class FeedStore {
    var deleteCachedFeedCallCount = 0
}

final class LocalFeedLoader {
    private let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }
}

final class CacheFeedUseCase: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)

        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
