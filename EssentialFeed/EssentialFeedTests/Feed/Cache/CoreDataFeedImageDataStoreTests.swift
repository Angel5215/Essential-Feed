//
// CoreDataFeedImageDataStoreTests.swift
// Copyright © 2026 Ángel Vázquez. All rights reserved.
//

import EssentialFeed
import XCTest

@MainActor
final class CoreDataFeedImageDataStoreTests: XCTestCase, FeedImageDataStoreSpecs {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() throws {
        try makeSUT { sut, imageDataURL in
            self.assertThatRetrieveImageDataDeliversNotFoundOnEmptyCache(on: sut, imageDataURL: imageDataURL)
        }
    }

    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() throws {
        try makeSUT { sut, imageDataURL in
            self.assertThatRetrieveImageDataDeliversNotFoundWhenStoredDataURLDoesNotMatch(on: sut, imageDataURL: imageDataURL)
        }
    }

    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() throws {
        try makeSUT { sut, imageDataURL in
            self.assertThatRetrieveImageDataDeliversFoundDataWhenThereIsAStoredImageDataMatchingURL(on: sut, imageDataURL: imageDataURL)
        }
    }

    func test_retrieveImageData_deliversLastInsertedValue() throws {
        try makeSUT { sut, imageDataURL in
            self.assertThatRetrieveImageDataDeliversLastInsertedValueForURL(on: sut, imageDataURL: imageDataURL)
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        _ test: @escaping (CoreDataFeedStore, URL) -> Void,
        file: StaticString = #filePath,
        line: UInt = #line,
    ) throws {
        let storeURL = URL(filePath: "/dev/null")
        let sut = try CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)

        let exp = expectation(description: "wait for operation")
        sut.perform {
            let imageDataURL = URL(string: "https://a-url.com")!
            insertFeedImage(with: imageDataURL, into: sut, file: file, line: line)
            test(sut, imageDataURL)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
    }
}

private func insertFeedImage(
    with url: URL,
    into sut: CoreDataFeedStore,
    file: StaticString = #filePath,
    line: UInt = #line,
) {
    do {
        let image = LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
        try sut.insert([image], timestamp: .now)
    } catch {
        XCTFail("Failed to insert feed image with url \(url) - error: \(error)", file: file, line: line)
    }
}
