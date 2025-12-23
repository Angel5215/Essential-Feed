//
// XCTestCase+FeedStoreSpecs.swift
// Copyright © 2025 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(
        _ cache: (feed: [LocalFeedImage], timestamp: Date),
        to sut: any FeedStore,
    ) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    func expect(
        _ sut: any FeedStore,
        toRetrieve expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line,
    ) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (retrievedResult, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break

            case let (.found(retrievedFeed, retrievedTimestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)

            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func expect(
        _ sut: any FeedStore,
        toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line,
    ) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    @discardableResult
    func deleteCache(from sut: any FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        return deletionError
    }
}
