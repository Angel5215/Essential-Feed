//
// XCTestCase+FeedStoreSpecs.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import XCTest

func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: .success(.none), file: file, line: line)
}

func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
}

func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    insert((feed, timestamp), to: sut)

    expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
}

func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    insert((feed, timestamp), to: sut)

    expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
}

func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

    XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
}

func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)

    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

    XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
}

func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)

    let latestFeed = uniqueImageFeed().local
    let latestTimestamp = Date()
    insert((latestFeed, latestTimestamp), to: sut)

    expect(sut, toRetrieve: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
}

func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let deletionError = deleteCache(from: sut)

    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
}

func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    deleteCache(from: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
}

func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)

    let deletionError = deleteCache(from: sut)

    XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
}

func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)

    deleteCache(from: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
}

// MARK: - Helpers

@discardableResult
func insert(
    _ cache: (feed: [LocalFeedImage], timestamp: Date),
    to sut: any FeedStore,
) -> Error? {
    do {
        try sut.insert(cache.feed, timestamp: cache.timestamp)
        return nil
    } catch {
        return error
    }
}

@discardableResult
func deleteCache(from sut: any FeedStore) -> Error? {
    do {
        try sut.deleteCachedFeed()
        return nil
    } catch {
        return error
    }
}

func expect(
    _ sut: any FeedStore,
    toRetrieve expectedResult: Result<CachedFeed?, Error>,
    file: StaticString = #filePath,
    line: UInt = #line,
) {
    let retrievedResult = Result { try sut.retrieve() }

    switch (retrievedResult, expectedResult) {
    case (.success(.none), .success(.none)), (.failure, .failure):
        break

    case let (.success(retrievedCache?), .success(expectedCache?)):
        XCTAssertEqual(retrievedCache.feed, expectedCache.feed, file: file, line: line)
        XCTAssertEqual(retrievedCache.timestamp, expectedCache.timestamp, file: file, line: line)

    default:
        XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead.", file: file, line: line)
    }
}

func expect(
    _ sut: any FeedStore,
    toRetrieveTwice expectedResult: Result<CachedFeed?, Error>,
    file: StaticString = #filePath,
    line: UInt = #line,
) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
}
